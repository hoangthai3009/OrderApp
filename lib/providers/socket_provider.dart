// socket_provider.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_app/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketProvider extends ChangeNotifier {
  late io.Socket socket;

  SocketProvider() {
    initSocket();
  }

  void initSocket() {
    // Kết nối với máy chủ Socket.IO
    socket = io.io('http://$ip:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Lắng nghe sự kiện 'connect'
    socket.on('orderStatusUpdate', (data) {
      print('Message from server: $data');
      showToast('Trạng thái đơn hàng đã được thay đổi');
    });

    // Kết nối Socket.IO
    socket.connect();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
