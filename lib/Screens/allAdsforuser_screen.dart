import 'package:flutter/material.dart';
import 'package:untitled1/model/product.dart';
import 'package:untitled1/model/user.dart';
import 'package:untitled1/myTools.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/widgets/mWidgets.dart';

class AllAdsforUser extends StatefulWidget {
  final User otherUser;
  final User mUser;
  const AllAdsforUser({ this.otherUser, this.mUser});
  @override
  _AllAdsforUserState createState() => _AllAdsforUserState();
}

class _AllAdsforUserState extends State<AllAdsforUser> {
  List<Product> myProducts=[];
  @override
  Widget build(BuildContext context) {
    myProducts=context.watch<Products>().mListproducts.where((element) => element.publisherid==widget.otherUser.id).toList();
    final t=mT(context);
    return Scaffold(
      appBar:mAppbar(widget.otherUser.username),
      body: mAdslist(myProducts, widget.mUser),
    );
  }
}
