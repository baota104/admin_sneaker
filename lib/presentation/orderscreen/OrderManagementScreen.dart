import 'package:adminsneaker/presentation/Widget/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_detail.dart';
import '../../domains/Controller/order_provider.dart';

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.orders;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Management", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: DropdownButton<OrderStatus>(
                  isExpanded: true,
                  value: _selectedStatus,
                  hint: Text("Filter by status", style: theme.textTheme.bodyLarge),
                  underline: Container(),
                  icon: Icon(Icons.filter_alt_outlined),
                  borderRadius: BorderRadius.circular(12),
                  onChanged: (OrderStatus? newStatus) {
                    setState(() {
                      _selectedStatus = newStatus;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text("All Orders", style: theme.textTheme.bodyLarge),
                    ),
                    ...OrderStatus.values.map((OrderStatus status) {
                      return DropdownMenuItem<OrderStatus>(
                        value: status,
                        child: Text(
                          status.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _getStatusColor(status.name),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(child: LoadingWidet())
                : RefreshIndicator(
              onRefresh: () async {
                await provider.loadOrders();
              },
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: orders.length,
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  if (_selectedStatus != null &&
                      order.status != _selectedStatus!.name) {
                    return SizedBox();
                  }

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order #${order.orderId.substring(0, 8)}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order.status)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _getStatusColor(order.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Customer: ${order.userId ?? 'Unknown'}",
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "${order.orderDetails.length} items",
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${order.totalAmount.toStringAsFixed(2)}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                if (order.status != 'cancelled' &&
                                    order.status != 'completed')
                                  PopupMenuButton<OrderStatus>(
                                    icon: Icon(Icons.more_vert),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: (OrderStatus value) async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text("Confirm Status Change"),
                                          content: Text(
                                            "Change order status to ${value.name}?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () => Navigator.pop(ctx, false),
                                            ),
                                            ElevatedButton(
                                              child: Text("Confirm"),
                                              onPressed: () => Navigator.pop(ctx, true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final success = await provider
                                            .updateOrderStatus(order.orderId, value);

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
                                    },
                                    itemBuilder: (context) {
                                      List<PopupMenuItem<OrderStatus>> menuItems = [];
                                      switch (order.status) {
                                        case 'pending':
                                          menuItems = [
                                            _buildStatusMenuItem(
                                              OrderStatus.confirmed,
                                              "Confirm Order",
                                              Icons.check_circle_outline,
                                            ),
                                            _buildStatusMenuItem(
                                              OrderStatus.cancelled,
                                              "Cancel Order",
                                              Icons.cancel_outlined,
                                            ),
                                          ];
                                          break;
                                        case 'confirmed':
                                          menuItems = [
                                            _buildStatusMenuItem(
                                              OrderStatus.shipping,
                                              "Mark as Shipping",
                                              Icons.local_shipping_outlined,
                                            ),
                                          ];
                                          break;
                                        case 'shipping':
                                          menuItems = [
                                            _buildStatusMenuItem(
                                              OrderStatus.completed,
                                              "Mark as Completed",
                                              Icons.done_all_outlined,
                                            ),
                                            _buildStatusMenuItem(
                                              OrderStatus.cancelled,
                                              "Cancel Order",
                                              Icons.cancel_outlined,
                                            ),
                                          ];
                                          break;
                                        default:
                                          menuItems = [];
                                      }
                                      return menuItems;
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<OrderStatus> _buildStatusMenuItem(
      OrderStatus status, String label, IconData icon) {
    return PopupMenuItem<OrderStatus>(
      value: status,
      child: Row(
        children: [
          Icon(icon, color: _getStatusColor(status.name)),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}