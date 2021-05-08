import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String id;
    final String msg;
    final Timestamp at;
    final String from;
    final String to;

  Message(this.id,this.msg, this.at, this.from, this.to );


}