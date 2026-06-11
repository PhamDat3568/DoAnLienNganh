import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddFieldDialog extends StatefulWidget {
  const AddFieldDialog({super.key});

  @override
  State<AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final addressController = TextEditingController();
  final imageController = TextEditingController();

  String? selectedSport;

  bool loading = false;

  Future<void> addField() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedSport == null) {
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('fields').add({
      'name': nameController.text.trim(),
      'pricePerHour': int.parse(priceController.text.trim()),
      'sportType': selectedSport, // 🔥 lấy từ dropdown
      'address': addressController.text.trim(),
      'image': imageController.text.trim(),
      'rating': 5,
      'status': true,
      'createdAt': Timestamp.now(),
    });

    setState(() => loading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    addressController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thêm sân mới"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên sân"),
            ),

            const SizedBox(height: 10),

            // 🔥 DROPDOWN LẤY TỪ FIREBASE SPORTS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final sports = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  value: selectedSport,
                  decoration: const InputDecoration(
                    labelText: "Chọn môn thể thao",
                  ),

                  items: sports.map((doc) {
                    return DropdownMenuItem(
                      value: doc['name'] as String,
                      child: Text(doc['name'] as String),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedSport = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá / giờ"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Địa chỉ"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Link ảnh"),
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
          onPressed: loading ? null : addField,
          child: loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Thêm"),
        ),
      ],
    );
  }
}