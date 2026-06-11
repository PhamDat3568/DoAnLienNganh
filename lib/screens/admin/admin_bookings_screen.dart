import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  String formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (e) {
      return date;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'waiting_payment':
        return Colors.orange;

      case 'waiting_confirm':
        return Colors.blue;

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
      case 'waiting_payment':
        return "Chờ thanh toán";

      case 'waiting_confirm':
        return "Chờ xác nhận";

      case 'confirmed':
        return "Đã xác nhận";

      case 'cancelled':
        return "Đã huỷ";

      default:
        return status;
    }
  }

  Future<void> cancelBooking(
      BuildContext context,
      String docId,
      String status,
      ) async {

    // ❌ nếu đã huỷ rồi
    if (status == 'cancelled') return;

    // ⚠ confirmed cần xác nhận mạnh
    if (status == 'confirmed') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("⚠ Huỷ booking đã xác nhận"),
          content: const Text(
            "Booking này đã xác nhận. Huỷ sẽ ảnh hưởng hệ thống. Bạn chắc chắn?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Không"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Huỷ",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update({
      'status': 'cancelled',
      'cancelledBy': 'admin',
      'cancelledAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý đặt sân"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Có lỗi xảy ra"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có booking"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final status = data['status'];

              return Card(
                margin: const EdgeInsets.all(10),

                child: Padding(
                  padding: const EdgeInsets.all(10),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        data['fieldName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email: ${data['userEmail']}",
                          ),

                          Text(
                            "SĐT: ${data['userPhone'] ?? 'Chưa có'}",
                          ),
                          Text("Ngày: ${formatDate(data['date'])}"),
                          Text("Giờ: ${data['startHour']} - ${data['endHour']}"),
                          Text("Tiền: ${data['totalPrice']} VNĐ"),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Trạng thái: ${getStatusText(status)}",
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          // ✔ CONFIRM
                          if (status == 'waiting_confirm')
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(data.id)
                                    .update({
                                  'status': 'confirmed',
                                });
                              },
                              child: const Text("Xác nhận"),
                            ),

                          const SizedBox(width: 10),

                          // ❌ CANCEL (ALL STATUS)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              cancelBooking(context, data.id, status);
                            },
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