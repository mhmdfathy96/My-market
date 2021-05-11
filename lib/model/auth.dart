import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
import 'package:provider/provider.dart';

class Auth with ChangeNotifier{
  String _token;
  DateTime _expiresDate;
  String _userId;
  String _userEmail;
  String _username;
  String _password;
  String _phone;
  String _location;
  Timer _authtimer;

  User get mUser{
    return User(email: _userEmail, id: _userId,idtoken:_token,phone:_phone,username: _username,password: _password,location: _location);
  }

  bool get isauth{
    return token !=null;
  }
  String get token{
    if(_expiresDate != null && _expiresDate.isAfter(DateTime.now()) && _token != null){
        return _token;
    }return null;
  }

  Future<void> _auth(String email,String password,String inorup,{String username,String phone,String location, bool staylogin =false})async{
    final url=Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$inorup?key=AIzaSyDhIdQbkxKtFtixD79jasxzqp2J7JkOHzg');
   try {
   final res=  await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resdata=jsonDecode(res.body);
      if(resdata["error"] != null ){
        throw "${resdata["error"]["message"]}";
      }
      _token=resdata["idToken"];
  _expiresDate=DateTime.now().add(Duration(seconds:int.parse(resdata["expiresIn"])));
     _userId=resdata["localId"];
   _userEmail=resdata["email"];
   if(inorup=='signUp') {
     await FirebaseFirestore.instance.collection('users').doc(_userId).set({
       'username':username,
       'password':password,
       'phone':phone,
       'location':location,
       'id':_userId,
       'email':_userEmail,

     });
     _username=username;
     _password=password;
     _phone=phone;
     _location=location;
   }else{
     ////login
     final result= await FirebaseFirestore.instance.collection('users').doc(_userId).get();
     final docs= result.data();
      _username=docs['username'];
       _password=docs['password'];
       _phone=docs['phone'];
       _location=docs['location'];
      // _userId=docs['id'];

   }
     autologout();
   final pref = await SharedPreferences.getInstance();
   notifyListeners();
   if(staylogin) {
     final userdata = jsonEncode({
       '_token': _token,
       '_expiresDate': _expiresDate.toIso8601String(),/////////////////////////////
       '_userId': _userId,
       '_userEmail': _userEmail,
       '_username':_username,
       '_password':_password,
       '_phone':_phone,
       '_location':_location,
     });
     pref.setString('userdata', userdata);
    }
    }catch(e){
     throw e;
   }
  }

  deleteuser(User mUser)async{
    final url=Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:delete?key=AIzaSyDhIdQbkxKtFtixD79jasxzqp2J7JkOHzg');
try{
   final res = await http.post(url,body: json.encode({
     "idToken":mUser.idtoken,
   }));
    await FirebaseFirestore.instance.collection('users').doc(mUser.id).delete();
   final resdata=jsonDecode(res.body);
   if(resdata["error"] != null ){
     throw "${resdata["error"]["message"]}";
   }
   await logout();
}catch(e){
  throw e;
}
  }

  change(String newentry,bool ispassword,User mUser) async{////////////////////////////////need edit
    await signin(_userEmail, _password, false);
    final url=Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyDhIdQbkxKtFtixD79jasxzqp2J7JkOHzg');
    try {
       final res=  await http.post(url,
          body: json.encode(ispassword?{
            'idToken': _token,
            'password': newentry,
            'returnSecureToken': true,
          }:{
            'idToken': _token,
            'email': newentry,
            'returnSecureToken': true,
          } ));
       final resdata=jsonDecode(res.body);
       if(resdata["error"] != null ){
         throw "${resdata["error"]["message"]}";
       }
       _token=resdata["idToken"];
       _expiresDate=DateTime.now().add(Duration(seconds:int.parse(resdata["expiresIn"])));
       _userEmail=resdata["email"];
       _userId=resdata["localId"];
      autologout();
       notifyListeners();
       await FirebaseFirestore.instance.collection('users').doc(_userId).update(
           ispassword?{
         'password':newentry,
       }:{
             'email':newentry,
           });
       final pref = await SharedPreferences.getInstance();
       if(pref.containsKey("userdata")) {
         await pref.remove('userdata').then((value) {
           if(ispassword){
             _password=newentry;
           }
          final userdata = jsonEncode({
             '_token': _token,
             '_expiresDate': _expiresDate.toIso8601String(),
             '_userId': _userId,
             '_userEmail': _userEmail,
             '_username':_username,
             '_password':_password,
             '_phone':_phone,
             '_location':_location,
           });
           pref.setString('userdata',userdata);
         });
       }


    }catch(e){
        throw e;
    }

}
  changeit(String type,String val,)async{
    try {
      await FirebaseFirestore.instance.collection('users').doc(mUser.id).update(
              {
                type:val,
              });
      switch(type){
        case 'username': _username=val; break;
        case 'phone':_phone=val; break;
        case 'location':_location=val; break;
      }
      final pref=await SharedPreferences.getInstance();
      if(pref.containsKey("userdata")) {
        await pref.remove('userdata').then((value) {
          final userdata = jsonEncode({
            '_token': _token,
            '_expiresDate': _expiresDate.toIso8601String(),
            '_userId': _userId,
            '_userEmail': _userEmail,
            '_username':_username,
            '_password':_password,
            '_phone':_phone,
            '_location':_location,
          });
          pref.setString('userdata',userdata);
        });
      }
    } catch (e) {
      throw e.toString();
    }
  }

   Future<bool> tryautologin()async{
    final pref= await SharedPreferences.getInstance();
   if(!pref.containsKey('userdata')){
     return false;
   }
     final extracteddata=jsonDecode(pref.get("userdata")) as Map<String,Object>;
     final expirydate=DateTime.tryParse(extracteddata["_expiresDate"]);
     if(!expirydate.isAfter(DateTime.now())){
    return false;
      }
     _token=extracteddata['_token'];
     _expiresDate=expirydate;
     _userEmail=extracteddata['_userEmail'];
     _userId=extracteddata['_userId'];
    _username=extracteddata['_username'];
     _password=extracteddata['_password'];
     _phone=extracteddata['_phone'];
    _location=extracteddata['_location'];
     autologout();
     notifyListeners();
     return true;
  }
  Future<void> signup(String email,String password,String username,String phone,String location)async{
    return await _auth(email, password,'signUp',username: username,phone:phone,location: location);
  }
  Future<void> signin(String email,String password,bool staylogin)async{
   return await _auth(email, password,'signInWithPassword',staylogin: staylogin);
  }
  Future<void> logout() async{
    _token=null;
    _expiresDate=null;
    _userEmail=null;
    _userId=null;
    _phone=null;
    _location=null;
    _username=null;
    _password=null;

    if(_authtimer!=null){ //???
      _authtimer.cancel();
      _authtimer =null;
    }
    final pref= await SharedPreferences.getInstance();
    pref.clear();
    notifyListeners();
  }

 void autologout(){
      if(_authtimer!=null){ //???
        _authtimer.cancel();
      }
      final timetoexpire=_expiresDate.difference(DateTime.now()).inSeconds;
      _authtimer=Timer.periodic(Duration(seconds: timetoexpire),(_)=>logout());
  }

  }
