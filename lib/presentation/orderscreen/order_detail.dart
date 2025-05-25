import 'package:flutter/material.dart';

import '../../domains/datasource/model/OrderModel.dart';


class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  OrderDetailScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details #${order.orderId}')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Text('Order ID: ${order.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Customer: ${order.userId}'),
            Text('Status: ${order.status}'),
            Text('Total Amount: ${order.totalAmount} VND'),
            Text('Shipping Address: ${order.address}'),
            SizedBox(height: 10),
            Text('Product List:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.orderDetails.map((detail) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: Image.network(detail.imageUrl),
                  title: Text(detail.name),
                  subtitle: Text('Price: ${detail.price} VND\nDiscount: ${detail.discountPrice} VND'),
                  trailing: Text('Quantity: 1'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}