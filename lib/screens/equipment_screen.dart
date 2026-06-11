import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'equipment_payment_screen.dart';

class EquipmentScreen extends StatefulWidget {
  final String fieldId;
  final String fieldName;

  const EquipmentScreen({
    super.key,
    required this.fieldId,
    required this.fieldName,
  });

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final Map<String, int> quantities = {};

  int startHour = 8;
  int endHour = 9;

  DateTime selectedDate = DateTime.now();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<Map<String, String>> getUserInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? '',
          'phone': data['phone'] ?? '',
        };
      }
    } catch (_) {}

    return {'name': '', 'phone': ''};
  }

  Future<void> orderEquipment(QueryDocumentSnapshot item) async {
    final qty = quantities[item.id] ?? 0;

    if (qty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chọn số lượng")),
      );
      return;
    }

    if (endHour <= startHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giờ không hợp lệ")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final hours = endHour - startHour;
    final price = item['price'] as int;
    final total = hours * price * qty;

    final userInfo = await getUserInfo(user.uid);

    final List<Map<String, dynamic>> items = [
      {
        'equipmentId': item.id,
        'name': item['name'],
        'price': price,
        'qty': qty,
        'image': item['image'] ?? '',
      }
    ];

    // ✅ TẠO ORDER VÀ LẤY ID NGAY
    final docRef =
    FirebaseFirestore.instance.collection('equipment_orders').doc();

    await docRef.set({
      // USER
      'userId': user.uid,
      'userEmail': user.email,
      'userName': userInfo['name'],
      'userPhone': userInfo['phone'],

      // FIELD
      'fieldId': widget.fieldId,
      'fieldName': widget.fieldName,

      // ITEMS
      'items': items,

      // TIME
      'date': "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
      'startHour': startHour,
      'endHour': endHour,
      'hours': hours,

      // MONEY
      'totalPrice': total,

      // STATUS
      'status': 'waiting_payment',

      // CREATED
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentPaymentScreen(
          orderId: docRef.id, // ✅ KHÔNG BAO GIỜ NULL
          totalPrice: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thuê dụng cụ")),

      body: Column(
        children: [
          // 📅 CHỌN NGÀY
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Ngày: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Chọn ngày"),
                )
              ],
            ),
          ),

          // ⏰ CHỌN GIỜ
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: startHour,
                    isExpanded: true,
                    items: List.generate(24, (i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text("$i:00"),
                      );
                    }),
                    onChanged: (v) => setState(() => startHour = v!),
                  ),
                ),
                const SizedBox(width: 10),
                const Text("→"),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<int>(
                    value: endHour,
                    isExpanded: true,
                    items: List.generate(24, (i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text("$i:00"),
                      );
                    }),
                    onChanged: (v) => setState(() => endHour = v!),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // LIST DỤNG CỤ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('equipment')
                  .where('fieldId', isEqualTo: widget.fieldId)
                  .where('status', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final qty = quantities[item.id] ?? 0;

                    final image = (item['image'] ?? '').toString();

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: image.isNotEmpty
                            ? Image.network(image, width: 60, height: 60)
                            : const Icon(Icons.sports),

                        title: Text(item['name']),
                        subtitle: Text("${item['price']} VNĐ / giờ"),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (qty > 0) {
                                  setState(() {
                                    quantities[item.id] = qty - 1;
                                  });
                                }
                              },
                            ),
                            Text("$qty"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantities[item.id] = qty + 1;
                                });
                              },
                            ),
                            ElevatedButton(
                              onPressed: () => orderEquipment(item),
                              child: const Text("Thuê"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}