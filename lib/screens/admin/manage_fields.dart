import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_field_dialog.dart';
import 'edit_field_dialog.dart';

class ManageFields extends StatelessWidget {
  const ManageFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý sân"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddFieldDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fields')
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Chưa có sân"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['name']),
                  subtitle: Text("${data['pricePerHour']} VNĐ"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ✏️ SỬA
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditFieldDialog(
                              docId: data.id,
                              oldName: data['name'],
                              oldPrice: data['pricePerHour'].toString(),
                              oldSport: data['sportType'],
                              oldAddress: data['address'],
                              oldImage: data['image'] ?? '',
                            ),
                          );
                        },
                      ),

                      // 🗑 XOÁ
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('fields')
                              .doc(data.id)
                              .delete();
                        },
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