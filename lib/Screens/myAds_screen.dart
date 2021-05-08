import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
import 'package:untitled1/widgets/mWidgets.dart';

import '../myTools.dart';

class MyAdsScreen extends StatefulWidget {
  final User mUser;
  const MyAdsScreen({@required this.mUser});
  @override
  _MyAdsScreenState createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  List<Product> myProducts=[];

  @override
  Widget build(BuildContext context) {
    myProducts=context.watch<Products>().mListproducts.where((element) => element.publisherid==widget.mUser.id).toList();
    final t = mT(context);
    return Scaffold(
      appBar: mAppbar('My Ads',actions:(myProducts.length<=0)?[]:[
          InkWell(child: Icon(Icons.delete_outline),onTap:()=> context.read<Products>().removeallforuser(context),)
      ]),
      body: mAdslist(myProducts, widget.mUser),
    );
  }
}
