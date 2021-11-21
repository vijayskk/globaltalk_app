// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket/chat.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List messages = [];
  int count = 0;
  String typing = "";
  bool isConnected = false;
  String name = "";
  IO.Socket socket =
      IO.io('https://agile-cliffs-19297.herokuapp.com/', <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": false
  });

  connect() {
    socket.connect();
    print(socket.connected);
    socket.on('typing', (value) {
      setState(() {
        typing = value;
      });
    });
    socket.on('chat', (value) {
      setState(() {
        messages = [
          ...messages,
          {...jsonDecode(value), "me": false}
        ];
      });
      // print(jsonDecode(value));
    });
    socket.on('count', (value) {
      setState(() {
        count = value;
      });
      print(value);
    });
    socket.onConnect((data) {
      print("Connected");
      socket.on('name', (data) {
        print(data);
        if (data != "") {
          setState(() {
            name = data;
            isConnected = true;
          });
        } else {
          setState(() {
            name = "annoying-dog";
            isConnected = true;
          });
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(
          name: name,
          count: count,
          messages: messages,
          socket: socket,
          typing: typing,
          isConnected: isConnected,
        ));
  }
}

class Home extends StatefulWidget {
  IO.Socket socket;
  String typing;
  bool isConnected = false;
  String name;
  Home(
      {Key? key,
      required this.count,
      required this.messages,
      required this.socket,
      required this.typing,
      required this.isConnected,
      required this.name})
      : super(key: key);

  final int count;
  List messages;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool popshown = false;
  TextEditingController _messageController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  scroll() async {
    await Future.delayed(Duration(milliseconds: 300));
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  showpop() async {
    await Future.delayed(Duration(milliseconds: 200));
    showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF02002b)),
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                children: [
                  Text(
                    "You are now talking as",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FlatButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      icon: Icon(
                        Icons.thumb_up_sharp,
                        color: Colors.white70,
                      ),
                      label: Text(
                        "Cool!",
                        style: TextStyle(color: Colors.white70),
                      ))
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isNotEmpty) {
      scroll();
    }
    if (widget.messages.isEmpty && widget.name != "" && !popshown) {
      showpop();
      popshown = true;
    }

    final rightpad = MediaQuery.of(context).size.width * 0.4;
    return (widget.isConnected)
        ? Scaffold(
            backgroundColor: Colors.black54,
            appBar: AppBar(
              backgroundColor: Colors.green[600],
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Global talk",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    (widget.typing != "")
                        ? widget.typing
                        : "${widget.count} peeps online",
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      Text(
                        widget.name,
                        textScaleFactor: 1.2,
                      )
                    ],
                  ),
                )
              ],
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 88.0),
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: widget.messages.length,
                        itemBuilder: (ctx, index) {
                          if (widget.messages[index]["me"]) {
                            return Padding(
                              padding: EdgeInsets.only(left: rightpad),
                              child: ChatTile(
                                handle: widget.messages[index]["handle"],
                                message: widget.messages[index]["message"],
                                me: true,
                              ),
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.only(right: rightpad),
                              child: ChatTile(
                                handle: widget.messages[index]["handle"],
                                message: widget.messages[index]["message"],
                                me: false,
                              ),
                            );
                          }
                        },
                      ),
                      (widget.count < 2)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "You are alone",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 40),
                                  ),
                                  Text(
                                    "Are you scared?",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 30),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: 0,
                            )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Container(
                              height: 65,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.all(15),
                              child: TextField(
                                controller: _messageController,
                                onChanged: (e) {
                                  if (e != "") {
                                    widget.socket.emit('typing',
                                        "${widget.name} is typing...");
                                  } else {
                                    widget.socket.emit('typing', "");
                                  }
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: (widget.count < 2)
                                      ? "Talk Yourself"
                                      : "Send Message to ${widget.count} peeps",
                                  hintStyle: TextStyle(color: Colors.white70),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: IconButton(
                                onPressed: () {
                                  if (_messageController.text != "") {
                                    widget.socket.emit(
                                        'chat',
                                        jsonEncode({
                                          "message": _messageController.text,
                                          "handle": widget.name
                                        }));
                                    setState(() {
                                      widget.messages = [
                                        ...widget.messages,
                                        {
                                          "message": _messageController.text,
                                          "handle": widget.name,
                                          "me": true
                                        }
                                      ];
                                    });
                                    _messageController.text = "";
                                  }
                                },
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white70,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Color(0xFF231F20),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: Image.asset('assets/chatlogo.png')),
                CircularProgressIndicator(color: Colors.lime)
              ],
            ),
          );
  }
}
