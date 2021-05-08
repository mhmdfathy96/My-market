
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:untitled1/model/user.dart';
import 'package:untitled1/myTools.dart';

enum Category{
Vehicles,
  Electronics,
  Furnitures,
  Homemades,
  Fashions,
  pets,
}


class Product {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String datetime;
  final String location;
  final String price;
  final String publisherid;
  final String pubemail;
  final String category;
  final String pubphone;
  final String pubusername;


  Product( {
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.category,
    @required this.imageUrl,
    @required this.datetime,
    @required this.location,
    @required this.price,
    @required this.publisherid,
    @required this.pubemail,
    @required this.pubphone,
    @required this.pubusername,
  });
}


class Products with ChangeNotifier {
  User mUser;
  bool isloading=false;
  String selectedlocation;

  List<Product> mListproducts = [];
  Map<String,String> mFav=Map();
/*
  getdata(String mUser.idtoken, List<Product> previousproducts){
    this.mUser.idtoken=mUser.idtoken;
    this.mListproducts=this.mListproducts+previousproducts;
    notifyListeners();
  }


 */
  Future<bool> add(context,{
    @required title,
    @required description,
    @required category,
    @required imageUrl,
    @required datetime,
    @required location,
    @required price,
    @required publisherid,
    @required pubemail,
    @required pubphone,
    @required pubusername,
  }) async {
    bool issuccess=false;
    try {
      final url = Uri.parse(
          'https://flutter02-25e57-default-rtdb.firebaseio.com/products.json?auth=${mUser.idtoken}');
      await http
              .post(url,
                  body: jsonEncode({
                    'title': title,
                    'description': description,
                    'category':category,
                    'imageUrl': imageUrl,
                    'datetime': datetime,
                    'location': location,
                    'price': price,
                    'publisherid': publisherid,
                    'pubemail':pubemail,
                    'pubphone':pubphone,
                    'pubusername':pubusername,
                  }))
              .then((value) {
        issuccess=true;
            mListproducts.add(Product(
              id: json.decode(value.body)['name'],
              title: title,
              description: description,
              category: category,
              imageUrl: imageUrl,
              datetime: datetime,
              location: location,
              price: price,
              publisherid: publisherid,
              pubemail: pubemail,
                pubphone:pubphone,
              pubusername: pubusername
            ));
          });
      notifyListeners();
       } catch (e) {
      Toast.show(e.toString(), context);
       }
    return issuccess;
  }

  Future<bool> removeallforuser(context) async{
   final mprods= mListproducts.where((element) => element.publisherid==mUser.id).toList();
   for(Product i in mprods){
   await  remove(i.id, context);
   }
  }

   likeprod(Product mprod)async{
     try {
       final url = Uri.parse(
                'https://flutter02-25e57-default-rtdb.firebaseio.com/${mUser.id}.json?auth=${mUser.idtoken}');
       final res=await http.post(url,body: jsonEncode({
              'adId':mprod.id,
            })).then((value) {
        final key= jsonDecode(value.body)['name'] ;
         if (key != null) {
           mFav.addAll({
             '${mprod.id}':'$key'
           });
           notifyListeners();
         }
       } );
       
     } catch (e) {
      throw e;
     }
  }
  
  unlikeprod(Product mprod)async{
    try {
      final url = Uri.parse(
          'https://flutter02-25e57-default-rtdb.firebaseio.com/${mUser.id}/${mFav[mprod.id]}.json?auth=${mUser.idtoken}');
      await http.delete(url,body: jsonEncode(mFav[mprod.id])).then((_) {
       mFav.remove(mprod.id);
       notifyListeners();
      } );
    } catch (e) {
      throw e;
    }
  }
  fetchfav()async{
    try {
      final url = Uri.parse(
          'https://flutter02-25e57-default-rtdb.firebaseio.com/${mUser.id}.json?auth=${mUser.idtoken}');
      final res=await http.get(url);
      final data=jsonDecode(res.body) as Map<String,dynamic>;
      if(data==null) return;
      data.forEach((key, value) async { 
       final id= value['adId'];
       var exist = mFav.containsKey(id); 
       if (!exist) {
         //add
         mFav.addAll({
           id: key
         }
         );
         notifyListeners();
       }});
      
    } catch (e) {
      throw e;
    }
    
  }

  Future<bool> remove(String id,context) async {
    bool issuccess=false;
    final myprod=mListproducts.firstWhere((element) => element.id==id);
    try {
      final imageurl=myprod.imageUrl;
      final url = Uri.parse(
          'https://flutter02-25e57-default-rtdb.firebaseio.com/products/${id}.json?auth=${mUser.idtoken}');
      isloading=true;
      mListproducts.removeWhere((element) => element.id==id);
      notifyListeners();
      await http.delete(url, body: jsonEncode(id)).then((_) async {
           await  mDatabase().deleteimage(imageurl).then((value) => issuccess=value);
            isloading=false;
          }
          );
    } catch (e) {
      add(context, title: myprod.title, description: myprod.description, category: myprod.category, imageUrl: myprod.imageUrl, datetime: myprod.datetime, location: myprod.location, price: myprod.price,publisherid: myprod.publisherid,pubemail: myprod.pubemail,pubphone:myprod.pubphone,pubusername: myprod.pubusername);
      Toast.show("something wrong \n check your connection \n ${e.toString()}", context);
      isloading=false;
      notifyListeners();
    }
    return issuccess;
  }

  Future<void> fetchdata(context) async {

    try {
      final url = Uri.parse(
          'https://flutter02-25e57-default-rtdb.firebaseio.com/products.json?auth=${mUser.idtoken}');
      isloading= true;
    var res = await http.get(url);
    final alldata = jsonDecode(res.body) as Map<String, dynamic>;
  if(
    alldata==null
    ){
      isloading=false;
      notifyListeners();
      return;
    }
      mListproducts=[];
      alldata.forEach((key, value) {
        mListproducts.add(Product(
          id: key,
          title: value['title'],
          description:value['description'],
          category: value['category'],
          imageUrl: value['imageUrl'],
          datetime: value['datetime'],
          location:value['location'] ,
          price: value['price'],
          publisherid: value['publisherid'],
          pubemail: value['pubemail'],
          pubphone: value['pubphone'],
          pubusername: value['pubusername'],
        ));
        notifyListeners();
        /*
            var indexexist = mListproducts.indexWhere((element) => element.id == key,);
            if (indexexist >= 0) {
              //redit if exist
              mListproducts[indexexist]=Product(
                id: key,
                title: value['title'],
                description:value['description'],
                category: value['category'],
                imageUrl: value['imageUrl'],
                datetime: value['datetime'],
                location:value['location'] ,
                price: value['price'],
                publisherid: value['publisherid'],
                pubemail: value['pubemail'],
                pubphone: value['pubphone'],
                pubusername: value['pubusername'],
              );
              notifyListeners();
            }else{
              //add if not exist
              mListproducts.add(Product(
                id: key,
                title: value['title'],
                description:value['description'],
                category: value['category'],
                imageUrl: value['imageUrl'],
                datetime: value['datetime'],
                location:value['location'] ,
                price: value['price'],
                publisherid: value['publisherid'],
                pubemail: value['pubemail'],
                pubphone: value['pubphone'],
                pubusername: value['pubusername'],
              ));
              notifyListeners();
            }

         */
          });

     await fetchfav();
    } catch (e) {
      print('There is no Internet connection \n please check your connection\n ${e.toString()}');
    }finally{
      isloading= false;
      notifyListeners();
    }

  }

  updateproduct(Product product,context)async{
    try {
      final url = Uri.parse(
              'https://flutter02-25e57-default-rtdb.firebaseio.com/products/${product.id}.json?auth=${mUser.idtoken}');
      final int  prodindex=mListproducts.indexWhere((element) => element.id==product.id);
      await http.patch(url,body: jsonEncode({
              'title': product.title,
              'description': product.description,
              'category':product.category,
              'imageUrl': product.imageUrl?? mListproducts[prodindex].imageUrl,
              'datetime': product.datetime,
              'location': product.location,
              'price': product.price,
              'publisherid': product.publisherid,
              'pubemail':product.pubemail,
              'pubphone':product.pubphone,
              'pubusername':product.pubusername,
              }))
              .then((value) {
            mListproducts[prodindex]=Product(
              id: product.id,
              title: product.title,
              description: product.description,
              category:product.category,
              imageUrl: product.imageUrl?? mListproducts[prodindex].imageUrl,
              datetime: product.datetime,
              location: product.location,
              price: product.price,
              publisherid: product.publisherid,
              pubemail:mUser.email,
              pubphone:mUser.phone,
              pubusername: mUser.username,
            );
          });
      notifyListeners();
    } catch (e) {
      Toast.show("something wrong \n check your connection", context);
    }
  }
}
