import 'package:cloud_firestore/cloud_firestore.dart';

class Chat{
  final String id;
  final String lastmsg;
  final Timestamp at;
  final String username;
  final bool isme;
  final String adId;

  Chat(this.id, this.lastmsg, this.at, this.username, this.isme, this.adId);

}