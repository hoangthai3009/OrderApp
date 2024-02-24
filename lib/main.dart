import 'package:flutter/material.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:order_app/providers/socket_provider.dart'; // Import SocketProvider
import 'package:order_app/screens/cart_screen.dart';
import 'package:order_app/screens/product_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:order_app/screens/table_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => SocketProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Order App',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
        ),
        routes: {
          '/tableList': (context) => TableListScreen(),
          '/productList': (context) => ProductListScreen(),
          '/cart': (context) => CartScreen(),
        },
        home: TableListScreen(),
      ),
    );
  }
}
