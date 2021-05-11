
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:untitled1/Screens/adDetails_screen.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
Widget mDrawerButton({@required mtext, @required func, @required icondata,String sub=''}){
  return RelativeBuilder(builder: (ctx,height,width,sy,sx)=>Row(
    children: [
      SizedBox(width: sx(20),),
      Icon(icondata,color:Colors.white ,size: sx(30),),
      SizedBox(width: sx(20),),
      TextButton(onPressed: func, child: Text(mtext,style: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: 'fonts/hemihead_bold.ttf',
         // fontWeight: FontWeight.bold,
         // fontSize:sx(30),
          color: Colors.white),),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(20),
          //tapTargetSize: MaterialTapTargetSize.padded,
          overlayColor: MaterialStateProperty.all(Colors.cyan.withOpacity(0.4)),
          textStyle: MaterialStateProperty.all(TextStyle(
            decoration: TextDecoration.none,
            fontFamily: 'fonts/hemihead_bold.ttf',
            fontWeight: FontWeight.bold,
            fontSize: sx(28),)),
        ),),

    ],
  ));
}
Widget mElevatedButton(
    {@required mtext, @required func, @required icondata,String sub=''}) {
  ///not using
  return RelativeBuilder(builder: (ctx,height,width,sy,sx)=>Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(20),
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: MaterialStateProperty.all(TextStyle(
              decoration: TextDecoration.none,
              fontFamily: 'fonts/hemihead_bold.ttf',
              fontWeight: FontWeight.bold,
              fontSize: sx(28),
              color: Colors.white)),

        ),
        onPressed: func,
        icon: Icon(icondata),
        label:Text(mtext),

      ),
    ),
  );

}

Widget mAppbar(String text, {List<Widget> actions,Widget leading}) {
  return  AppBar(
    backgroundColor: Colors.deepPurpleAccent,
    title: RelativeBuilder(builder: (ctx,height,width,sy,sx)=>Text(
      '$text',
      style: TextStyle(
          fontSize: sx(29),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'fonts/Roboto-Bold.ttf'),
    )),
    actions: actions ?? [],
    leading: leading,
  );
}
btnAdontap(context, String adId) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          adDetailsscreen(
            adID: adId, mUser: Provider
              .of<Auth>(context, listen: false)
              .mUser,
          )));
}
Widget mAdslist(List<Product> myProducts, User mUser) {
  return RelativeBuilder(builder: (ctx,height,width,sy,sx)=>Center(
    child: Provider
        .of<Products>(ctx)
        .isloading
        ? CircularProgressIndicator()
        : RefreshIndicator(
      onRefresh: () =>
          Provider.of<Products>(ctx, listen: false).fetchdata(ctx),
      child: (myProducts.length == 0)
          ? SingleChildScrollView(child: Column(
        children: [
          Text('There is no Ads Available'),
        ],
      ))
          : ListView.builder(
        itemCount: myProducts.length,
        itemBuilder: (ctx, index) {
          final thisproduct = myProducts[myProducts.length-1-index];
          return InkWell(
            onTap: () => btnAdontap(ctx, thisproduct.id),
            child: Card(
              margin: EdgeInsets.symmetric(vertical: sy(5),horizontal: sx(5)),
              shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft:Radius.circular(20),
                  )
              ) ,
              color: Colors.white54,
              elevation: 20,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Stack(children: [
                      ClipRRect(
                          borderRadius:
                          BorderRadius.circular(20),
                          child: Hero(
                            tag: thisproduct.id,
                            child: (Image.network(
                              thisproduct.imageUrl,
                              fit: BoxFit.cover,
                              width: sx(280),
                              height: sy(142),
                            )),
                          )),
                      (mUser.id == thisproduct.publisherid)
                          ? SizedBox()
                          : myStar(thisproduct),
                    ]),
                    SizedBox(
                      width: sx(20),
                    ),
                    Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: sy(15),
                          ),
                          mCardtext(thisproduct.title,
                              fontsize: sx(40)),
                          SizedBox(
                            height: sy(10),
                          ),
                          mCardtext('${thisproduct.price} EGP',
                              fontsize: sx(45)),
                          SizedBox(
                            height: sy(10),
                          ),
                          mCardtext( thisproduct.datetime.substring(10).trim()
                          ),
                          SizedBox(
                            height: sy(10),
                          ),
                          mCardtext(thisproduct.datetime
                              .substring(0, 10)),
                          SizedBox(
                            height: sy(10),
                          ),
                          mCardtext(thisproduct.location),
                          SizedBox(
                            height: sy(15),
                          ),
                        ]),
                  ]),
            ),
          );
        },
      ),
    ),
  ));
}
Widget mCardtext(String text, {double fontsize = 25}) {
  return RelativeBuilder(builder: (ctx,height,width,sy,sx)=> Text(
    text,
    style: TextStyle(
        fontSize: sx(fontsize), fontWeight: FontWeight.bold, color: Colors.black),
  ));
}
Widget mInput(String labeltext,
    Function(String) mValidator,
    TextEditingController controller,
    {TextInputType mtextinputtype = TextInputType
        .text, int maxlines = 1, bool obscure = false, String hint = '', Widget mIcon, Widget mprefix,Widget msuffix,bool enabled=true}) {
  return RelativeBuilder(builder: (ctx,height,width,sy,sx)=> Container(
    height: maxlines==1?sy(50):sy(80),
    margin: EdgeInsets.only(
      bottom: sy(5),
      left: sx(10),
      right: sx(10),
    ),
    child: TextFormField(
      enabled:enabled ,
  validator: mValidator,
  obscureText: obscure,
  controller: controller,
  maxLines: maxlines,
  keyboardType: mtextinputtype,
  decoration: InputDecoration(
  labelText: labeltext,
  hintText: hint,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
  contentPadding: EdgeInsets.symmetric(vertical: sy(11), horizontal: sx(15)),
  prefixIcon: mprefix ?? SizedBox(),
  suffixIcon: msuffix ?? SizedBox(),
  icon: mIcon ?? SizedBox(),
  labelStyle: TextStyle(
  fontWeight: FontWeight.bold, fontSize: sx(18), color: Colors.black),
  ),
    ),
  ));
}
Widget myStar(Product mprod) {
  return RelativeBuilder(builder: (ctx,height,width,sy,sx)=>LikeButton
    (
    isLiked: Provider
        .of<Products>(ctx)
        .mFav
        .containsKey(mprod.id),
    onTap: (isliked) async {
      if (isliked) {
        await Provider.of<Products>(ctx, listen: false).unlikeprod(mprod);
        return false;
      } else {
        await Provider.of<Products>(ctx, listen: false).likeprod(mprod);
        return true;
      }
    },
    likeBuilder: (isliked) {
      return Icon(
        isliked ? Icons.star : Icons.star_border, color: Colors.deepOrange,
        size: sy(25),);
    },

  ));
}
Widget mLocationDropdown(Function(dynamic) onchange,{Widget edit}){
  List<String> locations=['Alexandria',
    'Ismailiya',
    'Aswan',
    'Assiut',
    'Luxor',
    'la mar Roja',
    'Behira',
    'BaniSuwayf',
    'Port Said',
    'Sinai del sud',
    'Gizah',
    'Daqahliya',
    'Damietta',
    'Suhaj',
    'Suez',
    'Ash Sharqiyah',
    'Sinai del nord',
    'Gharbiya',
    'Faium',
    'Cairo',
    'Qalubiya',
    'Qena',
    'Kafr El-Sheikh',
    'Matrouh',
    'Menoufia',
    'Minya',
    'Wadi al-Jadid',];
  return RelativeBuilder(
    builder: (ctx,height,width,sy,sx)=> DropdownButton(
      icon: edit,
      hint:Text("Choose your Location"),
      value:Provider.of<Products>(ctx).selectedlocation,
      items: locations.map((e) {
        return DropdownMenuItem(
          value:e,
          child:Text(e),
        );
      }
      ).toList(),
      onChanged: onchange,
    ),
  );
}
Widget msg(String msg, bool ismymsg,Timestamp at) {
  return RelativeBuilder(
      builder: (ctx,heigth,width,sy,sx)=> Row(
    mainAxisAlignment: ismymsg ? MainAxisAlignment.end : MainAxisAlignment
        .start
    ,
    children: [
      Container(
        margin: EdgeInsets.symmetric(horizontal: sx(10),vertical: sy(5)),
        child:SelectableText(msg,
          style: TextStyle(color: Colors.black, fontSize: sx(17),),
          textAlign: ismymsg ? TextAlign.end : TextAlign.start,),
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: width * .8,
        ),
        decoration: BoxDecoration(
          color:ismymsg?Theme.of(ctx).primaryColor: Colors.deepPurple.withOpacity(0.9),
          borderRadius:BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: ismymsg?Radius.circular(20):Radius.circular(0),
            bottomRight: !ismymsg?Radius.circular(20):Radius.circular(0),
          ),
        ),)
      ,


    ]
    ,
  ));
}

Widget myDetailRow(String left, String right, {double fontsize = 22,}) {
  return RelativeBuilder(
    builder: (ctx,heigth,width,sy,sx)=>(left == 'Description:') ? Container(
       // height: sy(200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal:sx(5), vertical: sy(10)),
        color: Colors.white,
        child: SelectableText(
          right,
          style: TextStyle(color: Colors.black, fontSize: sx(22)),
          textAlign: TextAlign.justify,
        )) : Container(
      padding: EdgeInsets.symmetric(horizontal: sx(10), vertical: sy(5)),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$left', style: TextStyle(color: Colors.black54, fontSize: sx(20))),
          SelectableText('$right',
              style: TextStyle(color: Colors.black, fontSize: sx(fontsize))),
        ],
      ),
    )
  );
}

