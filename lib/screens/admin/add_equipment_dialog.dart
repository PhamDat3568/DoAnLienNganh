import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEquipmentDialog extends StatefulWidget {
  const AddEquipmentDialog({super.key});

  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  final name = TextEditingController();
  final price = TextEditingController();
  final image = TextEditingController();

  String? selectedFieldId;
  bool loading = false;

  Future<void> save() async {
    if (name.text.isEmpty || price.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('equipment').add({
      'name': name.text.trim(),
      'price': int.parse(price.text.trim()),
      'image': image.text.trim(),
      'fieldId': selectedFieldId, // 👈 QUAN TRỌNG
      'status': true,
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thêm dụng cụ"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Tên dụng cụ"),
            ),

            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá"),
            ),

            TextField(
              controller: image,
              decoration: const InputDecoration(labelText: "Link ảnh"),
            ),

            const SizedBox(height: 10),

            /// 🔥 CHỌN SÂN
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('fields')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final fields = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedFieldId,
                  decoration: const InputDecoration(
                    labelText: "Chọn sân",
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Dùng chung tất cả sân"),
                    ),
                    ...fields.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text(f['name']),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFieldId = value;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Huỷ"),
        ),
        ElevatedButton(
          onPressed: save,
          child: const Text("Thêm"),
        ),
      ],
    );
  }
}