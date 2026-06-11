import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyEquipmentOrdersScreen extends StatelessWidget {
  const MyEquipmentOrdersScreen({super.key});

  // ✅ FIX: nhận cả Timestamp và String
  String formatDate(dynamic value) {
    if (value == null) return 'Không rõ ngày';

    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy')
          .format(value.toDate());
    }

    if (value is String) {
      return value; // ví dụ: 2026-06-11
    }

    return 'Không rõ ngày';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Chưa đăng nhập")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn thuê dụng cụ của tôi"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('equipment_orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải dữ liệu"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Text("Bạn chưa thuê dụng cụ nào"),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;

              final fieldName = data['fieldName'] ?? 'Không rõ sân';
              final totalPrice = data['totalPrice'] ?? 0;
              final status = data['status'] ?? 'unknown';

              final startHour = data['startHour'] ?? 0;
              final endHour = data['endHour'] ?? 0;

              final date = data['date']; // ✅ dynamic luôn

              final List items = data['items'] ?? [];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🏟 SÂN
                      Text(
                        "Sân: $fieldName",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 📅 NGÀY + ⏰ GIỜ
                      Text("📅 Ngày thuê: ${formatDate(date)}"),
                      Text("⏰ Giờ: $startHour:00 → $endHour:00"),

                      const SizedBox(height: 6),

                      // 💰
                      Text("Tổng tiền: $totalPrice VNĐ"),
                      Text("Trạng thái: $status"),

                      const Divider(),

                      const Text(
                        "Dụng cụ:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Column(
                        children: items.isEmpty
                            ? [const Text("Không có dữ liệu dụng cụ")]
                            : items.map<Widget>((item) {
                          final e =
                          Map<String, dynamic>.from(item);

                          final image = e['image'] ?? '';
                          final name = e['name'] ?? 'Không tên';
                          final qty = e['qty'] ?? 0;
                          final price = e['price'] ?? 0;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,

                            leading: image
                                .toString()
                                .isNotEmpty
                                ? ClipRRect(
                              borderRadius:
                              BorderRadius.circular(8),
                              child: Image.network(
                                image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                const Icon(
                                    Icons.sports),
                              ),
                            )
                                : const Icon(Icons.sports),

                            title: Text(name),

                            subtitle: Text(
                              "SL: $qty | Giá: $price VNĐ",
                            ),
                          );
                        }).toList(),
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