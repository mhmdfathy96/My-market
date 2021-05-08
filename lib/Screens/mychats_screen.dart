import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:untitled1/model/Chat.dart';
import 'package:untitled1/widgets/mWidgets.dart';

import '../model/user.dart';
import '../myTools.dart';
import '../Screens/chat_screen.dart';

class MyChatsScreen extends StatefulWidget {
  final User mUser;

  const MyChatsScreen({ this.mUser}) ;
  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {

 Future<User> getOtherUser(String otherUserid)async{
  final result=await FirebaseFirestore.instance.collection('users').doc(otherUserid).get();
  final docs= result.data();
 return User(email: docs['email'], id: docs['id'], idtoken: '', phone: docs['phone'], username: docs['username'], password: '');
}

  @override
  Widget build(BuildContext context) {
    List<Chat> mChats=[];
    User otherUser;
    final me=widget.mUser;
    final t=mT(context);
    return Scaffold(
      appBar: mAppbar('My Chats'),
      body: RelativeBuilder(
        builder: (ctx,heigth,width,sy,sx)=> StreamBuilder(
          stream: FirebaseFirestore.instance.collection('chats').orderBy('at').snapshots(),
          builder:(ctx,snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              CircularProgressIndicator();
            }

            if(snapshot.data == null) return Text('No Chats available..');
            final docs=snapshot.data.docs as List<DocumentSnapshot>;
            if(docs != null){
              bool isme;
              docs.forEach((docelement) async {
                if(docelement['to']==me.id || docelement['from']==me.id){
                  if(docelement['from']==me.id){
                    otherUser=User(id:docelement['to'],username: docelement['tousername']);
                    isme=true;
                  }else{
                    otherUser=User(id:docelement['from'],username: docelement['fromusername']);
                    isme=false;
                  }
                  final existindex=mChats.indexWhere((element) => (element.id==docelement['from'])||(element.id==docelement['to']));
                  final newchat=Chat(otherUser.id,docelement['msg'],docelement['at'],otherUser.username,isme,docelement['adId']);
                  if(existindex >= 0){
                   mChats.removeAt(existindex);
                //  mChats[existindex]=newchat;
                  }
                    mChats.add(newchat);



                }
              });
            }
            if(mChats.length==0) {
              return Center(
                child: Text('No Chats Available..'),
              );
            }else{
              //final lastmsgtime =DateFormat('dd/MM/yyyy HH:mm a').format(DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch));
              return ListView.builder(
                itemCount: mChats.length,
                itemBuilder: (ctx,index){
                  final thischat=mChats[mChats.length-1-index];
                  final adId=thischat.adId;
                  final sub=thischat.isme? 'Me: ${thischat.lastmsg}':thischat.lastmsg;
                  final other=User(id:thischat.id,username:thischat.username);
                       return ListTile(
                    title: Text(thischat.username,style: TextStyle(fontSize: sx(22),fontWeight: FontWeight.bold),),
                    subtitle:Text(sub) ,
                    trailing: Text(t.readTimestamp(thischat.at.microsecondsSinceEpoch)),
                    onTap:()=> Navigator.of(context).push(MaterialPageRoute( builder: (_)=> ChatScreen(mUser: me, otherUser: other,adId: adId,))),
                  );
                },
              );
            }
          } ,
        ),
      ),
    );


  }

}
