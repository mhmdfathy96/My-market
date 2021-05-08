import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

import './Screens/auth_screen.dart';
import './model/product.dart';

import './Screens/Myhomepage_screen.dart';
import './Screens/Splash_screen.dart';
import './model/auth.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
 // Provider.debugCheckInvalidValueType = null;

  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Auth>(
        create: (_) => Auth(),
      ),

     ChangeNotifierProvider<Products>(
        create: (_) => Products()
      ),


    ],


    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        seconds: 1,
        useLoader: false,
        gradientBackground: SweepGradient(
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.cyan,
            Colors.purple,
          ],
        ),
        navigateAfterSeconds:Consumer<Auth>(
          builder:(_,auth,__)=>auth.isauth?
           MyHomePage()
            : FutureBuilder<bool>(
                future: auth.tryautologin(),
                builder: (ctx, snapshot) =>
                    (snapshot.connectionState == ConnectionState.waiting)
                        ? Splashscreen()
                        : AuthScreen()),)));
  }
}
