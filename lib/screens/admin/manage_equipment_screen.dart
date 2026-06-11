import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_equipment_dialog.dart';
import 'edit_equipment_dialog.dart';

class ManageEquipmentScreen extends StatelessWidget {
  const ManageEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý dụng cụ"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddEquipmentDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('equipment')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text("Chưa có dụng cụ"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final doc = items[i];
              final data = doc.data() as Map<String, dynamic>;

              final String imageUrl = (data['image'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,

                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 55,
                          height: 55,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },

                      errorBuilder: (_, __, ___) {
                        return const Icon(Icons.sports, size: 40);
                      },
                    ),
                  )
                      : const Icon(Icons.sports, size: 40),

                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    "${data['price'] ?? 0} VNĐ",
                    style: const TextStyle(color: Colors.green),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditEquipmentDialog(
                              docId: doc.id,
                              oldName: data['name'] ?? '',
                              oldPrice: (data['price'] ?? '').toString(),
                              oldImage: imageUrl,
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('equipment')
                              .doc(doc.id)
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