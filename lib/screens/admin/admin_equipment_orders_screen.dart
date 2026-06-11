import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminEquipmentOrdersScreen extends StatelessWidget {
  const AdminEquipmentOrdersScreen({super.key});

  // ✅ format date an toàn (Timestamp / String)
  String formatDate(dynamic value) {
    if (value == null) return "Không rõ";

    if (value is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(value.toDate());
    }

    if (value is String) {
      return value;
    }

    return "Không rõ";
  }

  String formatDateTime(dynamic value) {
    if (value == null) return "Không rõ";

    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(value.toDate());
    }

    return "Không rõ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn thuê dụng cụ")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('equipment_orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải dữ liệu"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              final userName =
                  data['userName'] ?? data['userEmail'] ?? 'Không rõ';
              final userPhone = data['userPhone'] ?? 'Không có SĐT';

              final fieldName = data['fieldName'] ?? 'Không rõ sân';
              final totalPrice = data['totalPrice'] ?? 0;
              final status = (data['status'] ?? '').toString();

              final startHour = data['startHour'];
              final endHour = data['endHour'];

              // ⚠️ KHÔNG CAST TỪNG KIỂU NỮA
              final date = data['date'];
              final createdAt = data['createdAt'];

              final List items = data['items'] ?? [];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "🏟 Sân: $fieldName",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Text("👤 Khách: $userName"),
                      Text("📞 SĐT: $userPhone"),

                      const SizedBox(height: 5),

                      Text("⏰ Giờ: ${startHour ?? '-'}h → ${endHour ?? '-'}h"),

                      // ✅ DATE USER CHỌN
                      Text("📅 Ngày thuê: ${formatDate(date)}"),

                      // ✅ CREATED TIME ADMIN
                      Text("🕒 Tạo đơn: ${formatDateTime(createdAt)}"),

                      const SizedBox(height: 10),

                      const Text(
                        "🧰 Dụng cụ:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Column(
                        children: items.map<Widget>((item) {
                          final e = Map<String, dynamic>.from(item);

                          final image = (e['image'] ?? '').toString();
                          final name = e['name'] ?? 'Không rõ';
                          final qty = e['qty'] ?? 0;
                          final price = e['price'] ?? 0;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: image.isNotEmpty
                                ? Image.network(image,
                                width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.sports),
                            title: Text(name),
                            subtitle: Text("SL: $qty | Giá: $price VNĐ"),
                          );
                        }).toList(),
                      ),

                      const Divider(),

                      Text("💰 Tổng: $totalPrice VNĐ"),

                      const SizedBox(height: 6),

                      Text(
                        "Trạng thái: $status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == 'confirmed'
                              ? Colors.green
                              : status == 'cancelled'
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 'cancelled')
                            const Text(
                              "Đã huỷ",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          else ...[
                            if (status == 'waiting_confirm')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('equipment_orders')
                                      .doc(doc.id)
                                      .update({
                                    'status': 'confirmed'
                                  });
                                },
                                child: const Text(
                                  "Duyệt",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            const SizedBox(width: 8),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('equipment_orders')
                                    .doc(doc.id)
                                    .update({
                                  'status': 'cancelled'
                                });
                              },
                              child: const Text(
                                "Hủy",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
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