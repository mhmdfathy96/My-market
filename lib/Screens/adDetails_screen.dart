
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:toast/toast.dart';
import 'package:untitled1/Screens/addnewad_screen.dart';
import 'package:untitled1/widgets/mWidgets.dart';
import '../Screens/chat_screen.dart';
import 'package:untitled1/model/user.dart';
import 'package:untitled1/myTools.dart';
import 'package:untitled1/model/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:untitled1/Screens/allAdsforuser_screen.dart';

class adDetailsscreen extends StatefulWidget {
  final String adID;
  final User mUser;


  const adDetailsscreen({this.adID, this.mUser});

  @override
  _adDetailsscreenState createState() => _adDetailsscreenState();
}

class _adDetailsscreenState extends State<adDetailsscreen> {
  bool isfloationpressed = false;
  var thisproduct;
  var mController=TextEditingController();
  var offerController=TextEditingController();

@override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context)  {
    final t = mT(context);

    reportdialog()async{
      await t.mDialog('Tell us why you reporting this Ad', ()=>reportfn(mController.text, t.mgetdatetime()),
          mWidget: mInput('..', (String value) {
          },mController,
          ));
    }
    makeoffer() async{
      await t.mDialog('Type your offer', ()=>startchatwithoffer(offerController.text),
          mWidget: mInput('..', (String value) {
          },offerController,
          ));
      }

    thisproduct = Provider.of<Products>(context,listen: false)
        .mListproducts
        .firstWhere((element) => element.id == widget.adID);
    return RelativeBuilder(
      builder: (ctx,heigth,width,sy,sx)=> Scaffold(
          bottomSheet: (widget.mUser.id==thisproduct.publisherid)?Row():BottomAppBar(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sy(20), horizontal: sx(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    onTap: () => chatwithowner(),
                    child: Text(
                      'Chat now',
                      style: TextStyle(
                          fontSize: sx(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                  ),
                  InkWell(
                    onTap: () => makeoffer(),
                    child: Text(
                      'Make an offer',
                      style: TextStyle(
                          fontSize: sx(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.pink),
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.white70,
          appBar: mAppbar(thisproduct.title,actions:  (widget.mUser.id==thisproduct.publisherid)?[
            PopupMenuButton<String>(
                onSelected: mPopupactions,
                itemBuilder:(_){
                  return ['Edit','Delete'].map((val) {
                    return PopupMenuItem(value: val,child: Text(val));
                  } ).toList();
                } ),
          ]: [],),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                        width: double.infinity,
                       // height: sy(200),
                        color: Colors.black12,
                        child: Hero(
                          placeholderBuilder: (ctx,size,_){
                            return SizedBox(width: sx(250),height: sy(250),);
                          },
                          tag: thisproduct.id,
                          child: Image.network(
                            thisproduct.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )),
                    (widget.mUser.id==thisproduct.publisherid)?SizedBox():Positioned(
                      top: 4,
                      left: 4,
                      child: myStar(thisproduct),
                    ),
                    (widget.mUser.id==thisproduct.publisherid)?SizedBox():Positioned(
                        bottom: 5,
                        right: 5,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          icon: Icon(
                            Icons.flag_outlined,
                            color: Colors.red,
                            size: sx(40),
                          ),
                          label: Text(
                            'Report',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: sx(15)),
                          ),
                          onPressed:()=> reportdialog(),
                        )),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                myDetailRow('Location:', thisproduct.location),
                myDetailRow('Time:', thisproduct.datetime.substring(10).trim()),
                myDetailRow('Date:', thisproduct.datetime.substring(0, 10)),
                myDetailRow('Category:', thisproduct.category),
                myDetailRow('Publisher:', thisproduct.pubusername,fontsize: 15),
                myDetailRow('Description:', thisproduct.description),
                myDetailRow('ID:', thisproduct.id, fontsize: 18),
                myDetailRow(
                  'Views:',
                  '1',
                ),
                (widget.mUser.id!=thisproduct.publisherid)? Column(
                  children:[
                    SizedBox(
                      height: sy(10),
                    ),
                    Text(
                      thisproduct.pubemail,
                      style: TextStyle(
                          fontSize: sx(25),
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: sy(5),
                    ),
                    TextButton(
                      onPressed:() => allAdsforuser(),
                      child: Text(
                        'All Ads from this user',
                        style: TextStyle(
                            fontSize: sx(20),
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),

                  ]
                ):SizedBox(
                  height: 5,
                ),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(top: sy(10)),
                  child: SelectableText(
                    "Important Safety Tips! \n  * Meet in public/crowded places.\n  * Never go alone to meet a buyer/seller. \n * Check and inspect the product properly before purchasing it. \n  * Never pay anything in advance.",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: sx(15),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height:(widget.mUser.id!=thisproduct.publisherid)? sy(50):sy(5),
                ),
              ],
            ),
          ),
          floatingActionButton:(widget.mUser.id!=thisproduct.publisherid)?
          FloatingActionButton(
            child: Icon(Icons.call),
            onPressed: () {
              slidecontactactions();
            },
          ):SizedBox(),
        ),
    );
  }

  allAdsforuser()=>Navigator.push(context, MaterialPageRoute(builder: (_)=> AllAdsforUser(otherUser:User(email:thisproduct.pubemail,id:thisproduct.publisherid,phone:thisproduct.pubphone,username:thisproduct.pubusername,idtoken:'',password: '',location:thisproduct.location) ,mUser: widget.mUser,) ));



  mPopupactions(String choice)async{
    if(choice=='Edit'){
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_)=>addnewadscreen(adId: widget.adID,mUser: widget.mUser,),
      ));
    }else{
     await Provider.of<Products>(context,listen: false).remove(widget.adID, context);
      Navigator.of(context).pop();
    }
  }


  chatwithowner({String offer}) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> ChatScreen(mUser: widget.mUser,otherUser:User(email:thisproduct.pubemail,id:thisproduct.publisherid,phone:thisproduct.pubphone,username:thisproduct.pubusername,idtoken:'',password: '',location:thisproduct.location),adId: thisproduct.id,offer: offer,),),);
  }


  slidecontactactions() async {
    await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "",
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (_, ___, __) {
          return RelativeBuilder(
            builder: (ctx,heigth,width,sy,sx)=> Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    contactaction(()=>calluser(), Icons.call, 'Call \n ${thisproduct.pubphone}'),
                    SizedBox(
                      height: sy(5),
                    ),
                    contactaction(()=>sendmsg2user(), Icons.message, 'Send a message'),
                    SizedBox(
                      height: sy(5),
                    ),
                    contactaction(()=>copynumber(), Icons.copy, 'Copy number'),
                  ],
                ),
          );

        },
        transitionBuilder: (_, anim, anim2, child) {

          return SlideTransition(
            position: Tween(begin: Offset(-0.03, .7), end: Offset(-0.03, 0.63))
                .animate(anim),
            child: child,
          );
        });
  }


  Widget contactaction(Function fun, IconData icondata, String text) {
    return RelativeBuilder(
      builder: (ctx,heigth,width,sy,sx)=>Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.yellowAccent,
            fontSize: sx(15),
            decoration: TextDecoration.none,
          ),
          textAlign: TextAlign.start,
        ),
        ElevatedButton(
          child: Icon(icondata),
          onPressed: fun,
          style: ButtonStyle(
              shape: MaterialStateProperty.all(CircleBorder()),
              padding: MaterialStateProperty.all(EdgeInsets.all(15))),
        )
      ]),
    );
  }

  copynumber() {
    FlutterClipboard.copy(thisproduct.pubphone);
    Toast.show("Copied to clipboard", context);
    Navigator.of(context).pop();
  }

  sendmsg2user() => launch('sms://${thisproduct.pubphone}');

  calluser() => launch('tel://${thisproduct.pubphone}');


Future<bool> btnlikeAd(bool isliked) async {
  return !isliked;
}

reportfn(String reason,String atTime)async {
  try {
    Navigator.of(context).pop();
    if(reason.isEmpty) return;
    await FirebaseFirestore.instance.collection('reports').add(
          {
            'adid':thisproduct.id,
            'pubid':thisproduct.publisherid,
            'why':reason,
            'date':atTime,
          });
    Toast.show('Thank you ${widget.mUser.username} for reporting this Ad \n We will try to react as soon as possible', context,duration: 3);
  } catch (e) {
    Toast.show(e.toString(), context,duration: 3);
  }
}

  startchatwithoffer(String offer){
      try{
        Navigator.of(context).pop();
        if(offer.isEmpty) return;
        chatwithowner(offer:'My offer is $offer \n I would like to know your respond');
      }catch(e){
        Toast.show(e.toString(), context,duration: 3);
      }
  }

}