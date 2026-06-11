import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyBookingScreen extends StatelessWidget {
  const MyBookingScreen({super.key});

  IconData getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'bóng đá':
      case 'soccer':
        return Icons.sports_soccer;

      case 'tennis':
        return Icons.sports_tennis;

      case 'bóng rổ':
      case 'basketball':
        return Icons.sports_basketball;

      case 'bóng chuyền':
      case 'volleyball':
        return Icons.sports_volleyball;

      default:
        return Icons.sports;
    }
  }

  Color statusColor(String status) {
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

  String statusText(String status) {
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

  Future<void> cancelBooking(String docId, String status) async {
    // 🔥 RULE QUAN TRỌNG
    if (status == 'confirmed') return;

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update({
      'status': 'cancelled',
    });
  }

  void showCancelDialog(
      BuildContext context,
      String docId,
      String status,
      ) {
    if (status == 'confirmed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Không thể huỷ lịch đã xác nhận"),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hủy đặt sân"),
        content: const Text("Bạn có chắc muốn hủy lịch này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () async {
              await cancelBooking(docId, status);
              Navigator.pop(context);
            },
            child: const Text(
              "Hủy",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lịch đặt của tôi"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Chờ xác nhận"),
              Tab(text: "Đã xác nhận"),
              Tab(text: "Đã huỷ"),
            ],
          ),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text("Bạn chưa có lịch đặt nào"));
            }

            return TabBarView(
              children: [
                buildList(context, docs, null),
                buildList(context, docs, 'waiting_confirm'),
                buildList(context, docs, 'confirmed'),
                buildList(context, docs, 'cancelled'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildList(
      BuildContext context,
      List<QueryDocumentSnapshot> docs,
      String? filter,
      ) {
    final filtered = filter == null
        ? docs
        : docs.where((d) => d['status'] == filter).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final doc = filtered[index];
        final data = doc.data() as Map<String, dynamic>;

        final status = data['status'];
        final sportType = data['sportType'] ?? '';

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: Icon(
              getSportIcon(sportType),
              size: 30,
            ),

            title: Text(
              data['fieldName'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ngày: ${data['date']}"),
                Text("Giờ: ${data['startHour']}h - ${data['endHour']}h"),
                Text("Tiền: ${data['totalPrice']} VNĐ"),

                const SizedBox(height: 5),

                Text(
                  statusText(status),
                  style: TextStyle(
                    color: statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            trailing: (status == 'confirmed')
                ? const Icon(Icons.lock, color: Colors.grey)
                : IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                showCancelDialog(context, doc.id, status);
              },
            ),
          ),
        );
      },
    );
  }
}