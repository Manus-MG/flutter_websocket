// import 'dart:convert';
// import 'dart:io';
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
//
//
// void main() {
//   connectToWebSocket();
// }
//
// void connectToWebSocket() async {
//   final WebSocket socket = await WebSocket.connect('ws://192.168.43.117:8085/server1');
//
//   print('Connected to WebSocket');
//
//   // Subscribe to the WebSocket topic
//   subscribeToTopic(socket);
//
//   // Send a sample message
//   sendMessage(socket, 'Hello, WebSocket!');
// }
//
// void subscribeToTopic(WebSocket socket) {
//   // Subscribe logic
//   socket.add(jsonEncode({'subscribe': '/topic/return-to'}));
//   print('Subcribed');
//
//   // Listen for topic messages
//   socket.listen(
//         (dynamic data) {
//           print(data.toString());
//       final message = jsonDecode(data);
//       print('Received: ${message.toString()}');
//       // Handle the received message as needed
//     },
//     onDone: () {
//       print('WebSocket closed');
//     },
//     onError: (error) {
//       print('Error: $error');
//     },
//     cancelOnError: true,
//   );
// }
//
//
// void conttosubsribe(){
//   StompClient client = StompClient(
//       config: StompConfig(
//           url: 'wss://yourserver',
//           onConnect: onConnectCallback
//       )
//   );
// }
//
// void sendMessage(WebSocket socket, String message) {
//   // Send message logic
//   socket.add(jsonEncode({'message': message}));
// }
//
//
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:stomp_dart_client/stomp.dart';
// import 'package:stomp_dart_client/stomp_config.dart';
// import 'package:stomp_dart_client/stomp_frame.dart';
//
// void onConnect(StompFrame frame) {
//   stompClient.subscribe(
//     destination: '/topic/return-to',
//     callback: (frame) {
//       List<dynamic>? result = json.decode(frame.body!);
//       print(result);
//       print("Subsribed");
//     },
//   );
//
//   // Timer.periodic(const Duration(seconds: 10), (_) {
//   //   stompClient.send(
//   //     destination: '/app/test/endpoints',
//   //     body: json.encode({'a': 123}),
//   //   );
//   // });
// }
//
// final stompClient = StompClient(
//   config: StompConfig(
//     url: 'ws://192.168.43.117:8085/server1',
//     onConnect: onConnect,
//     beforeConnect: () async {
//       print('waiting to connect...');
//       await Future.delayed(const Duration(milliseconds: 10));
//       print('connecting...');
//     },
//
//     onWebSocketError: (dynamic error) => print(error.toString()),
//     // stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
//     // webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'},
//   ),
// );
//
//
//
//
// void main() {
//   stompClient.activate();
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

// If Server is using SockJs
final socketUrl = 'http://192.168.1.7:8085/server1';
// If Server is not using SockJs
// final socketUrl = 'ws://192.168.43.117:8085/server1';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter WebSocket Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StompClient stompClient;
  String name = 'name';
  int rate = -1;

  @override
  void initState() {
    super.initState();

    // // If Server is using SockJs
    stompClient = StompClient(
      config: StompConfig.sockJS(
        url: socketUrl,
        onConnect: onConnect,
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    // If Server is not using SockJs
    // stompClient = StompClient(
    //   config: StompConfig(
    //     url: socketUrl,
    //     onConnect: onConnect,
    //     onWebSocketError: (dynamic error) => print(error.toString()),
    //   ),
    // );

    print("connected");
    stompClient.activate();
  }

  onConnect(StompFrame frame) {
    print('running');
    stompClient.subscribe(
        destination: '/topic/return-to',
        callback: (StompFrame frame) {
          print(frame.body);
          if (frame.body != null) {
            Map<String, dynamic> result = json.decode(frame.body.toString());
            setState(() {
              name = result['name'];
              rate = result['rate'];
            });
          }
        });
    print("subscribed");
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.deepPurpleAccent,
    title: Text(
      widget.title,
      style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
    ),
  ),
  body: Expanded(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blueAccent, Colors.redAccent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your message from server:',
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${name.substring(0, name.length)} $rate',
              style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    ),
  ),
);
  }

  // @override
  // void dispose() {
  //   stompClient.deactivate();
  //   super.dispose();
  // }
}
