
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:untitled1/Screens/auth_screen.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
import 'package:untitled1/widgets/mWidgets.dart';

import '../myTools.dart';

class ChangeInfoScreen extends StatefulWidget {
  final User mUser;

  const ChangeInfoScreen({ this.mUser});

  @override
  _ChangeInfoScreenState createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey2 = GlobalKey();
  final GlobalKey<FormState> _formKey3 =GlobalKey();
  final GlobalKey<FormState> _formKey4 =GlobalKey();
 var t;
   String newentry;
  // bool switchval=true;
 //  String error='';
 //  String perror='';
  var mController=TextEditingController();
  var conController=TextEditingController();
  var mailController=TextEditingController();
  var phoneController=TextEditingController();
  var usernameController=TextEditingController();

  var isLoading=false;

  bool passObs=true;
  bool edituser=false;
  bool editphone=false;
  bool editmail=false;
  bool locedited=false;

  @override
  void initState() {
    final Me=context.read<Auth>().mUser;
   mailController.text=Me.email;
    phoneController.text=Me.phone;
    usernameController.text=Me.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     t = mT(context);
  //  final deviceSize = MediaQuery.of(context).size;
   // var passorem= switchval? "Email":"Password";
    return Scaffold(
      appBar: mAppbar('Personal Information'),
      body: RelativeBuilder(
        builder: (ctx,heigth,width,sy,sx)=>Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.all(20),
          child:Form(
            key:_formKey ,
            child: SingleChildScrollView(
              child: Column(

                children: [
      /*            Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Text("Change Your $passorem",style: TextStyle(color: Colors.black,fontSize: sx(15)),
                    ),
                    FlutterSwitch(
                      value: switchval,
                      onToggle: (newval){
                        setState(() {
                          switchval=newval;
                          mController.text='';
                        });
                      },
                      inactiveColor:Colors.lightBlue ,
                      activeColor: Colors.lightBlue,
                    ),
                  ],),

       */
                  SizedBox(
                    height: sy(10),
                  ),
              Form(
                  key: _formKey4,
                  child: mEditStack(sx(20),'Email', mailController, editmail, TextInputType.emailAddress)),
                  Divider(thickness: sy(3) ,),
                  Stack(
                    children: [
                      Form(
                          key: _formKey2,
                          child: mEditStack(sx(20),'Phone', phoneController, editphone, TextInputType.phone),
                      ),
                      if(isLoading)Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  Divider(thickness: sy(3) ,),
                  Form(
                      key: _formKey3,
                      child: mEditStack(sx(20),'Username',usernameController,edituser,TextInputType.name),
                  ),
                  Divider(thickness: sy(3) ,),
                  mLocationDropdown((newval) {
                    setState(() {
                      context.read<Products>().selectedlocation=newval;
                    });
                  },edit: (Provider.of<Products>(context).selectedlocation != Provider.of<Auth>(context).mUser.location)?IconButton(icon:Icon(Icons.check),onPressed: (){
                    btnConfirmit('location', Provider.of<Products>(context,listen: false).selectedlocation);
                  },):SizedBox()),
                  Divider(thickness: sy(3) ,),
                  Column(children: [
                    mInput('Password', (String value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                      return null;
                    },mController,obscure: passObs,
                        msuffix: IconButton(
                            onPressed: () {
                              setState(() {
                                passObs = !passObs;
                              });
                            }, icon: Icon(passObs? Icons.visibility:Icons.visibility_off))
                    ),
                    mInput( 'Confirm Password',(String value) {
                      if (value != mController.text) {
                        return 'Passwords do not match!';
                      } return null;
                    },conController,obscure: passObs,
                        msuffix: IconButton(
                            onPressed: () {
                              setState(() {
                                passObs = !passObs;
                              });
                            }, icon: Icon(passObs? Icons.visibility:Icons.visibility_off))),
                    ElevatedButton(
                      child:
                      Text('Confirm',style: TextStyle(color:Theme.of(context).primaryTextTheme.button.color, ),),
                      onPressed:()=>btnConfirm(),
                      style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(30),  )),
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: sx(30.0), vertical: sy(8.0)),),
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                        ,
                      ),
                    ),
                  ],) ,

                  Divider(thickness: sy(3) ,),
                  TextButton(onPressed: btnDeactive, child: Text("Deactive your account")),
                ],
              ),
            ),
          )

        ),
      ),
    );
  }

  Stack mEditStack(pos,String type,TextEditingController controller,bool edit,TextInputType textinputtype) {
    return Stack(
                      children: [
                        mInput(type, (String value) {
                          if (value.length == 0) {
                            return 'Please enter you $type!';
                          }else if(type=='Phone' && value.length != 11){
                            return 'Invalid Phone number!';
                          }else if (type=='Email' && (value.isEmpty || !value.contains('@') || !value.endsWith('.com'))) {
                            return 'Invalid email!';
                          } return null;
                        },controller,mtextinputtype:textinputtype,
                          enabled: edit,
                        ),
                        Positioned(
                          right: pos,
                          child: IconButton(icon: Icon(edit?Icons.check:Icons.edit), onPressed: (){
                            setState(() {
                              if(type=='Phone'){
                                if(editphone) btnConfirmit(type.toLowerCase(), controller.text);
                                editphone = !editphone;
                                edit=editphone;
                              }else if(type=='Username'){
                                if(edituser) btnConfirmit(type.toLowerCase(), controller.text);
                                edituser = !edituser;
                                edit=edituser;
                              }else if(type=='Email'){
                                if(editmail) btnConfirmit(type.toLowerCase(), controller.text);
                                editmail = !editmail;
                                edit=editmail;
                              }

                            });
                          }
                          ),
                        )
                      ],
                    );
  }

  btnDeactive() async{
   await t.mDialog('Are you sure to delete your account?',(){
                Navigator.of(context).pop();
              t.mDialog("Please enter your password to delete your account ..",
                  () => deleteuser(mController.text),
                  mWidget: mInput('Password', (String value) {
                    if (value.isEmpty) {
                      return 'Please enter your Password !';
                    }
                    return null;
                  },mController, obscure: true,
                  )
              );
            });

  }



  deleteuser(String password) async {
    Navigator.of(context).pop();
    setState(() {
      isLoading=true;
    });
      try{
       await context.read<Products>().removeallforuser( context);
      await context.read<Auth>().logout();
        await context.read<Auth>().signin(widget.mUser.email, password,false);
        await context.read<Auth>().deleteuser(widget.mUser);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>AuthScreen()));
        Toast.show('${widget.mUser.email} \n has been deleted', context);
      }catch(e) {
        Toast.show(e.toString(), context);
      }
    mController.text='';
    setState(() {
      isLoading=false;
    });
  }

  btnConfirmit(String type,String val)async{
   if(type=='phone'){
     if (!_formKey2.currentState.validate()) {
       // Invalid!
       return;
     }
     _formKey2.currentState.save();
   }else if(type=='username'){
     if (!_formKey3.currentState.validate()) {
       // Invalid!
       return;
     }
     _formKey3.currentState.save();
   }else if(type=='email'){
     if (!_formKey4.currentState.validate()) {
       // Invalid!
       return;
     }
     _formKey4.currentState.save();
   }
    setState(() {
      isLoading=true;
    });
    try{
      if(type=='email'){
        await Provider.of<Auth>(context,listen: false).change(val,false,widget.mUser);
      }else{
        await Provider.of<Auth>(context,listen: false).changeit(type, val);
      }
      //firebasestore
      Toast.show('$type has changed to $val', context,duration: 3);
    }catch(e){
      Toast.show(e.toString(), context,duration: 3);
      if(e.toString()=='Invalid argument(s): The source must not be null'){
        Toast.show('This Email is already exist', context,duration: 3);
      }
    }
    setState(() {
      isLoading=false;
    });
  }

  btnConfirm() async{
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      isLoading=true;
    });
    var entry=mController.text;
    try {
            // change password
         await context.read<Auth>().change(entry, true, widget.mUser);
      mController.text='';
      conController.text='';
      Toast.show('Your Password changed successfully', context,duration: 5);
    } catch (e) {
      Toast.show(e.toString(), context,duration: 5);
    }
    setState(() {
      isLoading = false;
    });
  }

}
