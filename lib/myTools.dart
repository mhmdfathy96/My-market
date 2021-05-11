import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:relative_scale/relative_scale.dart';

import 'Screens/adDetails_screen.dart';
import 'model/auth.dart';
import 'model/product.dart';
import 'model/user.dart';

class mytools with ChangeNotifier {
}

class mT {
  final context;

  mT(this.context);





  mDialog(String title, yes, {Widget mWidget,}) async {
    await showDialog(context: context, builder: (ctx) =>
        AlertDialog(
          title: Text(title,
          style: TextStyle(fontSize: 15),),
          content: mWidget,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: yes, child: Text("Yes")),
                TextButton(onPressed: () {
                  Navigator.of(ctx).pop();
                }, child: Text("No")),
              ],
            )
          ],
        ));
  }



  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {

        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }

}



