// import 'package:flutter/material.dart';
// import 'package:order_app/constants.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late io.Socket socket;

//   @override
//   void initState() {
//     super.initState();
//     // Kết nối với máy chủ Socket.IO
//     socket = io.io('http://$ip:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     // Lắng nghe sự kiện 'connect'
//     socket.on('connect', (_) {
//       print('Connected');
//     });

//     // Lắng nghe sự kiện 'message'
//     socket.on('orderStatusUpdate', (data) {
//       print('Message from server: $data');
//     });

//     // Kết nối Socket.IO
//     socket.connect();
//   }

//   @override
//   void dispose() {
//     // Ngắt kết nối khi widget bị hủy
//     socket.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Socket.IO Flutter Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Welcome to Socket.IO Flutter Example'),
//           ],
//         ),
//       ),
//     );
//   }
// }
