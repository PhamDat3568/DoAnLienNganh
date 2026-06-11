import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EquipmentPaymentScreen extends StatelessWidget {
  final String orderId;
  final int totalPrice;

  const EquipmentPaymentScreen({
    super.key,
    required this.orderId,
    required this.totalPrice,
  });

  Future<void> confirm(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('equipment_orders')
        .doc(orderId)
        .update({
      'status': 'waiting_confirm',
    });

    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán dụng cụ")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 250,
              color: Colors.grey[300],
              child: const Center(child: Text("QR CODE")),
            ),

            const SizedBox(height: 20),

            Text("Số tiền: $totalPrice VNĐ",
                style: const TextStyle(fontSize: 20, color: Colors.green)),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => confirm(context),
                child: const Text("Tôi đã chuyển khoản"),
              ),
            )
          ],
        ),
      ),
    );
  }
}