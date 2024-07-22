import 'package:flutter/material.dart';
import 'order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Pelanggan: ${order.customerName}',
                style: const TextStyle(fontSize: 18)),
            Text('Total Harga: ${order.totalPrice}',
                style: const TextStyle(fontSize: 18)),
            Text('Tanggal Order: ${order.orderDate}',
                style: const TextStyle(fontSize: 18)),
            Text('Status: ${order.status}', style: const TextStyle(fontSize: 18)),
            if (order.nomorFaktur != null)
              Text('Nomor Faktur: ${order.nomorFaktur}',
                  style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Item Order:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    title: Text(item.productName),
                    subtitle:
                        Text('Jumlah: ${item.quantity} - Harga: ${item.price}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
