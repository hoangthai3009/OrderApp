import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_app/models/order_item.dart';
import 'package:order_app/providers/cart_provider.dart';
import 'package:order_app/providers/socket_provider.dart';
import 'package:order_app/services/api/order_service.dart';
import 'package:order_app/services/api/table_service.dart';
import 'package:provider/provider.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    var socketProvider = Provider.of<SocketProvider>(context, listen: false);

    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách đơn hàng bàn ${cartProvider.tableRoom}'),
      ),
      body: _buildOrderList(context),
    );
  }

  Future<List<OrderItem>> _fetchOrders() async {
    try {
      return await OrderService.fetchOrders(context);
    } catch (error) {
      // Handle error, log, or display an error message
      print('Error fetching orders: $error');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();

    var socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socketProvider.socket.on('orderStatusUpdate', (data) {
      print('Received order status update: $data');
      // Kiểm tra xem widget có còn trong cây widget hay không trước khi gọi setState
      if (mounted) {
        setState(() {
          // Cập nhật trạng thái của widget
        });
      }
    });
  }

  Widget _buildOrderList(BuildContext context) {
    return FutureBuilder<List<OrderItem>>(
      future: _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hiện chưa có đơn hàng nào'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không có đơn hàng nào.'));
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final OrderItem order = snapshot.data![index];
                    return ListTile(
                      title: Text('Đơn hàng #${order.id}'),
                      subtitle: Text(
                        'Bàn ${order.tableNumber}, Trạng thái: ${order.status}',
                      ),
                      trailing: _buildTrailing(order),
                      onTap: () {
                        _showOrderDetails(order);
                      },
                    );
                  },
                ),
              ),
              _buildTotalAndOrderButton(context),
            ],
          );
        }
      },
    );
  }
Widget? _buildTrailing(OrderItem order) {
    // Thêm điều kiện dựa trên trạng thái của đơn hàng
    if (order.status == 'pending') {
      return IconButton(
        icon: Icon(Icons.cancel),
        onPressed: () {
          OrderService.cancelledOrder(order.id);
        },
      );
    } else {
      return null; // Trả về null nếu không có điều kiện nào được đáp ứng
    }
  }
  void _showOrderDetails(OrderItem order) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đơn hàng #${order.id}',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              Text('Bàn ${order.tableNumber}'),
              SizedBox(height: 8.0),
              Text('Trạng thái: ${order.status}'),
              SizedBox(height: 16.0),
              Text('Sản phẩm:'),
              Expanded(
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, itemIndex) {
                    var item = order.items[itemIndex];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            item["productInfo"]['img'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["productInfo"]['name'],
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Giá: ${currencyFormat.format(item["productInfo"]['price'])}',
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Số lượng: ${item["quantity"]}',
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalAndOrderButton(BuildContext context) {
    CartProvider cartProvider = context.watch<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<double>(
            future: _calculateTotalAmount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Lỗi khi tính tổng số tiền');
              } else {
                double totalAmount = snapshot.data ?? 0.0;
                return Text(
                  'Tổng tiền: ${currencyFormat.format(totalAmount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                );
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              // Kiểm tra trạng thái của tất cả các đơn hàng
              bool allOrdersCompleted = await _checkAllOrdersCompleted();

              if (allOrdersCompleted) {
                // Nếu tất cả các đơn hàng đã hoàn thành, thực hiện thanh toán
                TableService.releaseTable(cartProvider.tableRoom);
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                // Nếu có đơn hàng chưa hoàn thành, hiển thị thông báo hoặc thực hiện hành động phù hợp
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Có đơn hàng chưa hoàn thành. Không thể thanh toán.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }

  Future<double> _calculateTotalAmount() async {
    List<OrderItem> orders = await _fetchOrders();
    double totalAmount = orders
        .where((order) => order.status == 'completed')
        .fold(
            0.0,
            (sum, order) =>
                sum +
                order.items.fold<double>(
                    0.0,
                    (subtotal, item) =>
                        subtotal +
                        item['productInfo']['price'] * item['quantity']));
    return totalAmount;
  }

  Future<bool> _checkAllOrdersCompleted() async {
    List<OrderItem> orders = await _fetchOrders();
    return orders.every(
        (order) => order.status == 'completed' || order.status == 'cancelled');
  }
}
