// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  bool me;
  String handle;
  String message;
  ChatTile(
      {Key? key, required this.me, required this.handle, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: me ? Colors.green[700] : Colors.green[800],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            topLeft: Radius.circular(me ? 25 : 0),
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(me ? 0 : 25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  me ? "You" : handle,
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
