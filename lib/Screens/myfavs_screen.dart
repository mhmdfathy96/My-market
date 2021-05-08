import 'package:flutter/material.dart';
import 'package:untitled1/model/auth.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/widgets/mWidgets.dart';

import '../myTools.dart';

class MyFavsScreen extends StatefulWidget {
  final User mUser;

  const MyFavsScreen({@required this.mUser});
  @override
  _MyFavsScreenState createState() => _MyFavsScreenState();
}

class _MyFavsScreenState extends State<MyFavsScreen> {
  List<Product> myProducts=[];


  @override
  Widget build(BuildContext context) {
    final prodprov=context.watch<Products>();
    myProducts=prodprov.mListproducts.where((element) => prodprov.mFav.containsKey(element.id)).toList();
    final t = mT(context);
    return Scaffold(
      appBar: mAppbar('My Favourites',),
      body:mAdslist(myProducts, widget.mUser),

    );
}
}
