
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
 var t;
   String newentry;
   bool switchval=false;
   String error='';
   String perror='';
  var mController=TextEditingController();
  var conController=TextEditingController();
  var phoneController=TextEditingController();

  var isLoading=false;

  var isLoading2 =false;


  @override
  Widget build(BuildContext context) {
     t = mT(context);
    final deviceSize = MediaQuery.of(context).size;
    var passorem= switchval? "Email":"Password";
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Text("Change Your $passorem",style: TextStyle(color: Colors.black,fontSize: sx(15)),
                    ),
                    FlutterSwitch(
                      value: switchval,
                      onToggle: (newval){
                        setState(() {
                          switchval=newval;
                        });
                      },
                      inactiveColor:Colors.lightBlue ,
                      activeColor: Colors.lightBlue,
                    ),
                  ],),
                  SizedBox(
                    height: sy(10),
                  ),
                  (!switchval)?Column(children: [
                    mInput('Password', (String value) {
                        if (value.isEmpty || value.length < 5) {
                          return 'Password is too short!';
                        }
                        return null;
                      },mController,obscure: true,),
                    mInput( 'Confirm Password',(String value) {
                      if (value != mController.text) {
                        return 'Passwords do not match!';
                      } return null;
                    },mController,obscure: true,),
                  ],) :Column(
                    children: [
                     mInput("Email", (String value) {
                       if (value.isEmpty || !value.contains('@') || !value.endsWith('.com')) {
                         return 'Invalid email!';
                       } return null;
                     },mController),
                    ],
                  ),
                  isLoading?
                    CircularProgressIndicator()
                     :
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
                  Divider(thickness: sy(3) ,),
                  Form(
                      key: _formKey2,
                      child: mInput("Phone Number", (String value) {
                    if (value.length != 11) {
                      return 'Invalid Phone number!';
                    } return null;
                  },phoneController,mtextinputtype:TextInputType.phone)),
                  isLoading2?
                  CircularProgressIndicator()
                      :
                  ElevatedButton(
                    child:
                    Text('Confirm',style: TextStyle(color:Theme.of(context).primaryTextTheme.button.color, ),),
                    onPressed:()=>btnConfirmphone(),
                    style: ButtonStyle(shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(30),  )),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: sx(30.0), vertical: sy(8.0)),),
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                      ,
                    ),
                  ),
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

  btnDeactive() async{
   await t.mDialog('Are you sure to delete your account?',(){
                Navigator.of(context).pop();
              t.mDialog("Please enter your password to delete your account ..",
                  () => deleteuser(mController.text),
                  mWidget: t.mInput('Password', (String value) {
                    if (value.isEmpty) {
                      return 'Please enter your Password !';
                    }
                    return null;
                  },mController, obscure: true,));
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

  btnConfirmphone()async{
    if (!_formKey2.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey2.currentState.save();
    setState(() {
      isLoading2=true;
    });
    try{
      final pref=await SharedPreferences.getInstance();
      if(pref.containsKey('phone')){
        pref.remove('phone');
      }
        pref.setString('phone', phoneController.text);
      //  context.read<Auth>().phone=phoneController.text;///changes
      Toast.show('Phone number has changed to ${phoneController.text}', context,duration: 3);
    }catch(e){
      Toast.show(e.toString(), context);
    }
    setState(() {
      isLoading2=false;
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
      var edited;

      if(!switchval){
          edited="Password";
            // change password
         await context.read<Auth>().change(entry, true, widget.mUser);
          }else{
            edited="Email";
            //change email
           await context.read<Auth>().change(entry, false, widget.mUser);
          }
      mController.text='';
      conController.text='';
      Toast.show('Your $edited changed successfully', context,duration: 5);
    } catch (e) {
      Toast.show(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }
}
