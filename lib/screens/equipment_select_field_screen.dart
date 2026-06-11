import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'equipment_screen.dart';

class EquipmentSelectFieldScreen extends StatefulWidget {
  const EquipmentSelectFieldScreen({super.key});

  @override
  State<EquipmentSelectFieldScreen> createState() =>
      _EquipmentSelectFieldScreenState();
}

class _EquipmentSelectFieldScreenState
    extends State<EquipmentSelectFieldScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chọn sân")),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Tìm theo tên hoặc địa chỉ...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase().trim();
                });
              },
            ),
          ),

          // 📋 LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fields')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final fields = snapshot.data!.docs;

                // 🔥 FILTER SEARCH
                final filtered = fields.where((field) {
                  final name = (field['name'] ?? '')
                      .toString()
                      .toLowerCase();

                  final address = (field['address'] ?? '')
                      .toString()
                      .toLowerCase();

                  return name.contains(searchText) ||
                      address.contains(searchText);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text("Không tìm thấy sân"),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final field = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.sports_soccer),
                        title: Text(field['name']),
                        subtitle: Text(field['address'] ?? ''),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EquipmentScreen(
                                fieldId: field.id,
                                fieldName: field['name'],
                              ),
                            ),
                          );
                        },
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