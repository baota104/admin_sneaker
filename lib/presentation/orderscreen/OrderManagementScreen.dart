import 'package:adminsneaker/presentation/Widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../datasource/model/OrderModel.dart';
import 'order_detail.dart';
import 'order_provider.dart';


class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.orders;

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Order"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<OrderStatus>(
              value: _selectedStatus,
              hint: Text("Select status"),
              onChanged: (OrderStatus? newStatus) {
                setState(() {
                  _selectedStatus = newStatus;
                });
              },
              items: OrderStatus.values.map((OrderStatus status) {
                return DropdownMenuItem<OrderStatus>(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: orders.isEmpty
          ? Center(child: LoadingWidet())
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          // Lọc các đơn hàng theo trạng thái
          if (_selectedStatus != null &&
              order.status != _selectedStatus!.name) {
            return Container();
          }

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text("ID: ${order.orderId}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer: ${order.userId}"),
                  Text("Status: ${order.status}"),
                  Text("Total: ${order.totalAmount} Dollar"),
                ],
              ),
              trailing: PopupMenuButton<OrderStatus>(
                onSelected: (OrderStatus value) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text("Confirm"),
                      content: Text("Are you sure you want to change this order's status?"),
                      actions: [
                        TextButton(
                          child: Text("cancel"),
                          onPressed: () => Navigator.pop(ctx, false),
                        ),
                        ElevatedButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(ctx, true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final success = await provider.updateOrderStatus(order.orderId, value);

                    if (success) {
                      await provider.createOrderNotification(
                        orderId: order.orderId,
                        userId: order.userId,
                        newStatus: value,
                        imageUrl: order.orderDetails.first.imageUrl,
                      );
                      provider.loadOrders();
                    }
                  }
                }
                ,
                itemBuilder: (context) {
                  List<PopupMenuItem<OrderStatus>> menuItems = [];

                  // Thêm các lựa chọn trạng thái vào menu tùy vào trạng thái hiện tại của đơn hàng
                  switch (order.status) {
                    case 'pending':
                      menuItems = [
                        PopupMenuItem(value: OrderStatus.confirmed, child: Text("confirmed")),
                        PopupMenuItem(value: OrderStatus.cancelled, child: Text("cancelled")),
                      ];
                      break;
                    case 'confirmed':
                      menuItems = [
                        PopupMenuItem(value: OrderStatus.shipping, child: Text("shipping")),
                      ];
                      break;
                    case 'shipping':
                      menuItems = [
                        PopupMenuItem(value: OrderStatus.completed, child: Text("completed")),
                        PopupMenuItem(value: OrderStatus.cancelled, child: Text("cancelled")),
                      ];
                      break;
                    case 'completed':
                      menuItems = [
                        PopupMenuItem(value: OrderStatus.cancelled, child: Text("cancelled")),
                      ];
                      break;
                    case 'cancelled':
                      menuItems = []; // Không có lựa chọn khi đơn hàng đã hủy
                      break;
                    default:
                      menuItems = [];
                  }
                  return menuItems;
                },
                child: Icon(Icons.edit),
              ),
              onTap: () {
                // Chuyển sang màn hình chi tiết đơn hàng
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(order: order),
                  ),
                );
              },
              onLongPress: () async {
                if (order.status == 'completed') {
                  // Cho phép xóa đơn hàng nếu trạng thái là completed
                  await provider.deleteOrder(order.orderId);
                } else if (order.status == 'cancelled') {
                  // Nếu trạng thái là cancelled, cập nhật lại stock
                  await provider.updateStockWhenCancelled(order.orderId);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
