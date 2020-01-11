import 'package:OrangeChat/models/user_model.dart';

class Chat {
  final int id;
  final User sender;
  final String time;
  final String text;
  final bool unread;
  final bool isLiked;

  Chat({
    this.id,
    this.sender,
    this.time,
    this.text,
    this.unread,
    this.isLiked,
  });
}
