import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:untitled1/Screens/filter_screen.dart';
import 'package:untitled1/Screens/mychats_screen.dart';
import '../Screens/addnewad_screen.dart';
import '../widgets/mWidgets.dart';
import 'package:residemenu/residemenu.dart';
import '../Screens/changeinfo_screen.dart';
import '../Screens/myAds_screen.dart';
import '../Screens/myfavs_screen.dart';
import '../model/user.dart';
import '../model/auth.dart';
import '../model/product.dart';
import '../myTools.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<Product> myProducts;
  User mUser;

  int timenow = DateTime.now().hour;
  MenuController _mMenucontroller;

  String get welcome {
    if (timenow < 11 && timenow > 5) {
      return "Good Morning";
    } else if (timenow > 11 && timenow < 17) {
      return "Good Afternoon";
    } else {
      return 'Good Evening';
    }
  }

  @override
  void initState() {
    super.initState();
    _mMenucontroller = MenuController(vsync: this);
    Provider.of<Products>(context,listen: false).selectedlocation=Provider.of<Auth>(context,listen: false).mUser.location;
    context.read<Products>().mUser=context.read<Auth>().mUser;
    mUser=context.read<Auth>().mUser;
    context.read<Products>().fetchdata(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = mT(context);
    myProducts = context.watch<Products>().mListproducts;
    return RelativeBuilder(
      builder:(ctx,height,width,sy,sx)=> ResideMenu.scaffold(
            leftScaffold: MenuScaffold(
              header: Card(
                elevation:sy(20) ,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.deepPurpleAccent.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.ac_unit ,
                          ),
                          Text(
                            '$welcome',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontFamily: 'fonts/Roboto-bold.ttf',
                                fontWeight: FontWeight.bold,
                                fontSize: sx(33),
                                color: Colors.white70),
                          ),
                          Icon(
                            Icons.ac_unit,
                          ),
                        ],
                      ),
                      Text(context.read<Auth>().mUser.username,
                          softWrap: true,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontFamily: 'fonts/hemihead_bold.ttf',
                              fontWeight: FontWeight.bold,
                              fontSize: sx(30),
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              footer: mDrawerButton(mtext: 'Logout', func: btnlogout, icondata: Icons.logout)
              ,
              children: [
              //  mElevatedButton(mtext: 'Home', func: btnhome, icondata: Icons.home),
                mDrawerButton(
                    mtext: 'My Favourites', func: btnmyfavs, icondata: Icons.star),
                mDrawerButton(
                    mtext: 'My Ads', func: btnmyAds, icondata: Icons.emoji_flags),
                mDrawerButton(mtext: 'Chats', func: btnmyChats, icondata: Icons.chat),
                mDrawerButton(
                    mtext: 'add new Ad', func: fbtnaddAd, icondata: Icons.add),
                Divider(thickness: 3, color: Colors.indigoAccent),
                mDrawerButton(
                    mtext: 'Edit Personal Info', func: btnchangepass, icondata: Icons.person),
                mDrawerButton(
                    mtext: 'Filter', func: btnFilters, icondata: Icons.settings),
              ],
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.blueAccent,
                  Colors.blueGrey,
                ],
              ),
            ),
            controller: _mMenucontroller,
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.deepPurpleAccent,
                onPressed: fbtnaddAd,
              ),
              appBar: mAppbar('Home',leading:  InkWell(
                onTap: () {
                  _mMenucontroller.openMenu(true);
                },
                child: Icon(Icons.menu),
              ),),
              body: mAdslist(myProducts, mUser),
            ),
          ),
    );
  }

  btnchangepass() => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>ChangeInfoScreen(mUser: context.read<Auth>().mUser,)));

  btnmyAds() {
  Navigator.of(context).push(MaterialPageRoute(builder: (_)=> MyAdsScreen(mUser:context.read<Auth>().mUser,)));
  }

  btnlogout() {
    context.read<Auth>().logout();
  }

  btnhome() {}

  btnmyfavs() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => MyFavsScreen(mUser: context.read<Auth>().mUser)));
  }

  btnFilters() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => FilterScreen()));
  }

  btnmyChats() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => MyChatsScreen(mUser: context.read<Auth>().mUser) ));
  }

  fbtnaddAd() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => addnewadscreen(mUser: context.read<Auth>().mUser,)));
  }
}


