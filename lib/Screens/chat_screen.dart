import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:untitled1/Screens/adDetails_screen.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/message.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
import 'package:untitled1/myTools.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/widgets/mWidgets.dart';

class ChatScreen extends StatefulWidget {
  final User mUser;
  final User otherUser; //username email id
  final String adId;

  const ChatScreen({@required this.mUser,@required this.otherUser, this.adId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<FormState> _formkey=GlobalKey();
  final mController =TextEditingController();
  String _entry='';
  List<Message> msgs=[];

  Sendmsg() async {
    FocusScope.of(context).unfocus(); //to close the keyboard
  await  FirebaseFirestore.instance.collection('chats').add(
        {
          'msg':mController.text,
          'at':Timestamp.now(),
          'from':widget.mUser.id,
          'fromusername':widget.mUser.username,
          'to':widget.otherUser.id,
          'tousername':widget.otherUser.username,
          'adId':widget.adId,
        });
    mController.clear();
    setState(() {
      _entry='';
    });

     }


  @override
  Widget build(BuildContext context) {
     final thisproduct=context.read<Products>().mListproducts.firstWhere((element) => element.id==widget.adId);
    final t= mT(context);
    return Scaffold(
      appBar:mAppbar(widget.otherUser.username) ,
      bottomSheet: Form(
           key:_formkey ,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Expanded(
                 child: TextField(
                   controller:mController,
                 decoration: InputDecoration(
                   contentPadding: EdgeInsets.all(10),
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                   labelText: 'Send a message..'
                 ),
                   onChanged: (newval){
                   setState(() {
                     _entry=newval;
                   });
                   },
                 ),
               ),
               IconButton(icon: Icon(Icons.send),color: Theme.of(context).primaryColor, onPressed: _entry.trim().isEmpty? null:()=>Sendmsg() ),]
         )),
      body: RelativeBuilder(
    builder: (ctx,heigth,width,sy,sx)=>Column(
        children: [
          ListTile(
            leading: Image.network(thisproduct.imageUrl,fit: BoxFit.cover,
              width: sx(100),
              height: sy(100),),
            title: Text(thisproduct.title),
            subtitle: Text(thisproduct.location),
            onTap: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>adDetailsscreen(adID: widget.adId,mUser: context.read<Auth>().mUser,))),
          ),
          SizedBox(height: 20,),
          StreamBuilder(
            stream:FirebaseFirestore.instance.collection('chats').orderBy('at').snapshots() ,
            builder: (ctx,snapshot){
    /*
          if(snapshot.connectionState==ConnectionState.waiting){
               return CircularProgressIndicator();
              }

     */
              if(snapshot.data == null) return Text('No Messages available..');
              final docs=snapshot.data.docs as List<DocumentSnapshot>;
              if(docs != null){
                docs.forEach((e) {
                  if((e['to']==widget.mUser.id && e['from']==widget.otherUser.id)||(e['from']==widget.mUser.id && e['to']==widget.otherUser.id)){
                    final existsindex=msgs.indexWhere((element) => element.id==e.id);
                    final newmsg=Message(e.id,e['msg'],e['at'],e['from'],e['to']);
                    if(existsindex<0){
                      msgs.add(newmsg);
                    }else{
                      msgs[existsindex]=newmsg;
                    }
                  }
                });
              }
              if(msgs.length==0) {
    return Center(
    child: Text('No messages Available..'),
    );
    }else{
              return ListView.builder(
                  shrinkWrap: true,
                    itemCount: msgs.length,
                  itemBuilder: (ctx,index){
                      final thismsg=msgs[index];
                    return msg(thismsg.msg, thismsg.from==widget.mUser.id,thismsg.at);
                  }
              );
            }
              },
          ),
        ],
      )),
      );
  }

}
