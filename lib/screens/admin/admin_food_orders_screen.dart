import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminFoodOrdersScreen extends StatelessWidget {
  const AdminFoodOrdersScreen({super.key});

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'waiting_confirm':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'waiting_confirm':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'cancelled':
        return 'Đã huỷ';
      default:
        return status;
    }
  }

  Future<void> confirmOrder(String docId) async {
    await FirebaseFirestore.instance
        .collection('food_orders')
        .doc(docId)
        .update({'status': 'confirmed'});
  }

  Future<void> cancelOrder(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('food_orders')
        .doc(docId)
        .update({'status': 'cancelled'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn đặt đồ ăn")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn hàng"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? '';

              final foodImage = (data['foodImage'] ?? '').toString();
              final foodName = data['foodName'] ?? '';
              final fieldName = data['fieldName'] ?? 'Không rõ sân';

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🍔 FOOD + IMAGE
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: foodImage.isNotEmpty
                                ? Image.network(
                              foodImage,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.fastfood, size: 50),
                            )
                                : const Icon(Icons.fastfood, size: 50),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              foodName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 🏟 FIELD
                      Text(
                        "🏟 Sân: $fieldName",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 5),

                      // 👤 USER INFO
                      Text(
                        "Khách: ${data['userName'] ?? 'N/A'}",
                      ),
                      Text(
                        "SĐT: ${data['userPhone'] ?? 'Chưa có'}",
                      ),
                      Text(
                        "Email: ${data['userEmail'] ?? ''}",
                      ),

                      const SizedBox(height: 5),

                      // ORDER INFO
                      Text("Số lượng: ${data['quantity'] ?? 0}"),
                      Text("Tổng tiền: ${data['totalPrice'] ?? 0} VNĐ"),

                      if (data['createdAt'] != null)
                        Text(
                          "Thời gian: ${formatDate(data['createdAt'])}",
                        ),

                      const SizedBox(height: 8),

                      Text(
                        "Trạng thái: ${getStatusText(status)}",
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ACTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 'waiting_confirm')
                            ElevatedButton(
                              onPressed: () => confirmOrder(doc.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("Xác nhận"),
                            ),

                          if (status != 'cancelled') const SizedBox(width: 10),

                          if (status != 'cancelled')
                            ElevatedButton(
                              onPressed: () => cancelOrder(context, doc.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Huỷ"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}