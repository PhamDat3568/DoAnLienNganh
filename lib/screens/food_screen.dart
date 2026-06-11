import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'payment_screen.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final Map<String, int> quantities = {};

  String? selectedFieldId;
  String? selectedFieldName;

  // 🔥 LẤY USER INFO
  Future<Map<String, dynamic>> getUserInfo(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return {'phone': '', 'name': ''};
    }

    return doc.data() as Map<String, dynamic>;
  }

  Future<void> orderFood(QueryDocumentSnapshot food) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập")),
      );
      return;
    }

    int quantity = quantities[food.id] ?? 0;

    if (quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn số lượng")),
      );
      return;
    }

    if (selectedFieldId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn sân")),
      );
      return;
    }

    final userInfo = await getUserInfo(user.uid);

    final price = (food['price'] ?? 0) as int;

    final doc = await FirebaseFirestore.instance
        .collection('food_orders')
        .add({
      // USER
      'userId': user.uid,
      'userEmail': user.email,
      'userPhone': userInfo['phone'],
      'userName': userInfo['name'],

      // FIELD (🔥 NEW)
      'fieldId': selectedFieldId,
      'fieldName': selectedFieldName,

      // FOOD
      'foodId': food.id,
      'foodName': food['name'],
      'foodImage': food['image'],
      'category': food['category'],

      // ORDER
      'quantity': quantity,
      'price': price,
      'totalPrice': quantity * price,

      // STATUS
      'status': 'waiting_payment',

      // TIME
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          documentId: doc.id,
          collectionName: 'food_orders',
          totalPrice: quantity * price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt đồ ăn")),

      body: Column(
        children: [

          // 🏟 CHỌN SÂN
          Padding(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fields')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final fields = snapshot.data!.docs;

                return DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Chọn sân"),
                  value: selectedFieldId,
                  items: fields.map((f) {
                    return DropdownMenuItem(
                      value: f.id,
                      child: Text(f['name']),
                      onTap: () {
                        selectedFieldName = f['name'];
                      },
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFieldId = value;
                    });
                  },
                );
              },
            ),
          ),

          const Divider(),

          // 🍔 FOOD LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('foods')
                  .where('status', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final foods = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    int quantity = quantities[food.id] ?? 0;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [

                            Row(
                              children: [
                                Image.network(
                                  food['image'] ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.fastfood),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food['name'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(food['category'] ?? ''),
                                      Text(
                                        "${food['price']} VNĐ",
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (quantity > 0) {
                                          setState(() {
                                            quantities[food.id] =
                                                quantity - 1;
                                          });
                                        }
                                      },
                                    ),
                                    Text("$quantity"),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          quantities[food.id] =
                                              quantity + 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                ElevatedButton(
                                  onPressed: () => orderFood(food),
                                  child: const Text("Đặt"),
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
          ),
        ],
      ),
    );
  }
}