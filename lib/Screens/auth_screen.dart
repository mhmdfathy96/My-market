import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:untitled1/main.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/widgets/mWidgets.dart';

import '../myTools.dart';

enum AuthMode {SignUp, Login}

class AuthScreen extends StatelessWidget {
 // static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return RelativeBuilder(
      builder: (ctx,height,width,sy,sx)=> Scaffold(
        // resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(15, 180, 200, 1).withOpacity(0.9),
                    Color.fromRGBO(15, 117, 255, 1).withOpacity(0.5),
                    Color.fromRGBO(15, 18, 200, 1).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
               //   stops: [0,1],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: height,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                       // margin: EdgeInsets.all(5),
                        padding:
                        EdgeInsets.symmetric(vertical: sy(6.0), horizontal: sx(35.0)),
                        transform: Matrix4.rotationZ(-8 * pi / 180)
                          ..translate(sx(-10.0),sy(-20.0)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade700,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          'My Market',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sy(37),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: width > 600 ? 3 : 2,
                      child: AuthCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool staylogin=false;
 AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'username':'',
    'phone':'',
    'location':'',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  bool passwordObs=true;
  bool confirmObs=true;
  String _selectedlocation;

  void _submit() async{
    //check for textformfield validation
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    FocusScope.of(context).unfocus(); //to close the keyboard
    _formKey.currentState.save(); //for fun (onsave)..textformfield

    setState(() {
      _isLoading = true;
    });
    try{
      if (_authMode == AuthMode.Login) {
       await  Provider.of<Auth>(context, listen: false)
            .signin(_authData['email'], _authData['password'],staylogin);
      } else {
        if(context.read<Products>().selectedlocation==null) {
          Toast.show('Please select your Location', context);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        await  Provider.of<Auth>(context, listen: false)
            .signup(_authData['email'], _authData['password'],_authData['username'],_authData['phone'],_authData['location']);
      }
    }catch(e){
      final er=e.toString();
      String merror='';
      if(er.contains('EMAIL_EXISTS')){
       merror="this email address is already in use " ;
      }else if(er.contains('INVALID_EMAIL')){
        merror= 'this is not a valid email adress';
      }else if(er.contains('WEAK_PASSWORD')){
        merror='password is too weak ';
      }else if(er.contains('EMAIL_NOT_FOUND')){
        merror= 'could not find a user with that email';
      }else if(er.contains('INVALID_PASSWORD')){
        merror= 'this password is incorrect';
      }else{
        merror=er;
      }
      Toast.show("$merror", context,duration: 3);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final t =mT(context);
    final deviceSize = MediaQuery.of(context).size;
    return RelativeBuilder(
      builder: (ctx,height,width,sy,sx)=>Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Container(
          height:  height * 0.3,
          constraints:
          BoxConstraints(
              minHeight: _authMode == AuthMode.SignUp ? height * 0.8 : height * 0.41 ),
          width: width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      } return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value.trim();
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password',
                     suffixIcon:  IconButton(
                          onPressed: () {
                          setState(() {
                            passwordObs = !passwordObs;
                          });
                        }, icon: Icon(passwordObs? Icons.visibility:Icons.visibility_off))
                    ),
                    obscureText: passwordObs,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      } return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value.trim();
                    },
                  ),
                 (_authMode == AuthMode.SignUp)?
                    Column(
                      children: [
                        TextFormField(
                          enabled: _authMode == AuthMode.SignUp,
                          decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                setState(() {
                                  confirmObs = !confirmObs;
                                });
                              }, icon: Icon(confirmObs? Icons.visibility:Icons.visibility_off))
                          ),
                          obscureText: confirmObs,
                          validator: _authMode == AuthMode.SignUp
                              ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            } return null;
                          }
                              : null,
                        ),
                        TextFormField(
                          enabled: _authMode == AuthMode.SignUp,
                          decoration: InputDecoration(labelText: 'Username'),
                          controller: _usernameController,
                          validator: _authMode == AuthMode.SignUp
                              ? (value) {
                            if (value.length==0) {
                              return 'please enter Username..';
                            }else if(value.length > 20){
                              return 'Username must be 20 characters or less';
                            } return null;
                          }
                              : null,
                          onSaved: (newval)=>_authData['username']=_usernameController.text.trim(),
                        ),
                        TextFormField(
                          enabled: _authMode == AuthMode.SignUp,
                          decoration: InputDecoration(labelText: 'Phone Number'),
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: _authMode == AuthMode.SignUp
                              ? (value) {
                            if (!value.startsWith('01')) {
                              return 'phone number must start with 01..';
                            }else if(value.length != 11){
                              return 'phone number must be 11 numbers';
                            } return null;
                          }
                              : null,
                          onSaved: (newval)=>_authData['phone']=_phoneController.text.trim(),
                        ),
                        mLocationDropdown(
                          (newval){
                          setState(() {
                            context.read<Products>().selectedlocation=newval;
                            _authData['location']=newval;
                          });
                          },)
                      ],
                    ):CheckboxListTile(value: staylogin, onChanged: (val) {
                   setState(() {
                     staylogin = val;
                   });

                 },title: Text('stay login'),),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                   RaisedButton(
                      child:
                      Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                      onPressed:()=> _submit(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryTextTheme.button.color,
                    ),
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'Create new account' : 'Already have an account'} ',
                    style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 15),),
                    onPressed: _switchAuthMode,
                   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
