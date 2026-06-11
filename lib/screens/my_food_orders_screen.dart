import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyFoodOrdersScreen extends StatelessWidget {
  const MyFoodOrdersScreen({super.key});

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

  Future<void> cancelOrder(
      BuildContext context,
      String docId,
      ) async {
    await FirebaseFirestore.instance
        .collection('food_orders')
        .doc(docId)
        .update({'status': 'cancelled'});
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
  }

  Widget buildList(
      BuildContext context,
      List<QueryDocumentSnapshot> docs,
      String? filter,
      ) {
    final filtered = filter == null
        ? docs
        : docs.where((doc) => doc['status'] == filter).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final doc = filtered[index];
        final data = doc.data() as Map<String, dynamic>;

        final status = data['status'] ?? '';
        final foodImage = (data['foodImage'] ?? '').toString();
        final foodName = data['foodName'] ?? 'Không rõ';
        final fieldName = data['fieldName'] ?? 'Không rõ sân';

        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🖼 FOOD IMAGE + NAME
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

                // 📦 INFO
                Text("Số lượng: ${data['quantity']}"),
                Text("Tổng tiền: ${data['totalPrice']} VNĐ"),

                if (data['createdAt'] != null)
                  Text(
                    "Ngày đặt: ${formatDate(data['createdAt'])}",
                  ),

                const SizedBox(height: 6),

                Text(
                  getStatusText(status),
                  style: TextStyle(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ❌ CANCEL BUTTON
                if (status == 'waiting_confirm')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => cancelOrder(context, doc.id),
                      child: const Text(
                        "Huỷ",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Vui lòng đăng nhập")),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đơn đồ ăn của tôi"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Đang xử lý"),
              Tab(text: "Đã huỷ"),
            ],
          ),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('food_orders')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text("Bạn chưa có đơn đồ ăn nào"),
              );
            }

            return TabBarView(
              children: [
                buildList(context, docs, null),
                buildList(context, docs, 'waiting_confirm'),
                buildList(context, docs, 'cancelled'),
              ],
            );
          },
        ),
      ),
    );
  }
}