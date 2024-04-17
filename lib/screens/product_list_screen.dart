import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_app/models/cart_item.dart';
import 'package:order_app/models/product.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:order_app/providers/socket_provider.dart';
import 'package:order_app/screens/order_screen.dart';
import 'package:order_app/screens/product_detail_screen.dart';
import 'package:order_app/screens/product_type_list_screen.dart';
import 'package:order_app/screens/review_screen.dart';
import 'package:order_app/services/api/product_service.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class ProductListScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  TextEditingController searchController = TextEditingController();
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      final List<Product> data = await ProductService.fetchProductData();
      setState(() {
        products = data;
      });
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  Future<void> _searchProducts(String keyword) async {
    try {
      final List<Product> searchData =
          await ProductService.searchProducts(keyword);
      setState(() {
        products = searchData;
      });
    } catch (e) {
      print('Error searching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var socketProvider = Provider.of<SocketProvider>(context, listen: false);
    CartProvider cartProvider = context.watch<CartProvider>();
    int totalQuantity = cartProvider.calculateTotalQuantity();
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        print('Quay về từ ProductListScreen được chặn');
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Text('Danh sách sản phẩm'),
          actions: [
            badges.Badge(
              position: badges.BadgePosition.topEnd(end: 15),
              badgeContent: Text(totalQuantity.toString()),
              child: const Icon(Icons.shopping_cart),
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
            )
          ],
        ),
        drawer: _buildDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: searchController,
                  onChanged: (String keyword) {
                    if (keyword.isEmpty) {
                      fetchProductData();
                    } else {
                      _searchProducts(keyword);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProductTypeListScreen(type: 'food'),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.fastfood_outlined, size: 32.0),
                        Text('Đồ ăn'),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProductTypeListScreen(type: 'drink'),
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.local_drink_outlined, size: 32.0),
                        Text('Đô uống'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Số cột trong mỗi dòng
                crossAxisSpacing: 8.0, // Khoảng cách giữa các cột
                mainAxisSpacing: 8.0, // Khoảng cách giữa các dòng
                childAspectRatio:
                    0.7, // Tỷ lệ giữa chiều rộng và chiều cao của mỗi item
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  Product product = products[index];
                  return _buildProductItem(product);
                },
                childCount: products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      shadowColor: Colors.grey[400],
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.network(
                product.img,
                height: 130.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    currencyFormat.format(product.price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      CartProvider cartProvider = context.read<CartProvider>();

                      CartItem cartItem = CartItem(
                        productId: product.id,
                        productName: product.name,
                        price: product.price,
                        image: product.img,
                        quantity: 1,
                      );

                      cartProvider.addToCart(cartItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product.name} đã được thêm vào giỏ hàng.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Thêm món",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 154, // Đặt chiều cao mong muốn
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyan,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Đặt kích thước chữ mong muốn
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Trang chủ'),
            onTap: () {
              // Xử lý khi người dùng chọn Trang chủ
              Navigator.pop(context); // Đóng Drawer
            },
          ),
          ListTile(
            title: const Text('Đánh giá'),
            onTap: () {
              // Xử lý khi người dùng chọn Đơn hàng
              Navigator.pop(context); // Đóng Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Đơn hàng của bạn'),
            onTap: () {
              // Xử lý khi người dùng chọn Đơn hàng
              Navigator.pop(context); // Đóng Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderListScreen(),
                ),
              );
            },
          ),
          // Thêm các mục menu khác tùy theo nhu cầu
        ],
      ),
    );
  }
}
