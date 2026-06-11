import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditFieldDialog extends StatefulWidget {
  final String docId;
  final String oldName;
  final String oldPrice;
  final String oldSport;
  final String oldAddress;
  final String oldImage;

  const EditFieldDialog({
    super.key,
    required this.docId,
    required this.oldName,
    required this.oldPrice,
    required this.oldSport,
    required this.oldAddress,
    required this.oldImage,
  });

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController addressController;
  late TextEditingController imageController;

  String? selectedSport;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.oldName);
    priceController = TextEditingController(text: widget.oldPrice);
    addressController = TextEditingController(text: widget.oldAddress);
    imageController = TextEditingController(text: widget.oldImage);

    selectedSport = widget.oldSport; // 🔥 set giá trị cũ
  }

  Future<void> updateField() async {
    await FirebaseFirestore.instance
        .collection('fields')
        .doc(widget.docId)
        .update({
      'name': nameController.text,
      'pricePerHour': int.parse(priceController.text),
      'sportType': selectedSport, // 🔥 lấy từ dropdown
      'address': addressController.text,
      'image': imageController.text,
    });

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
      title: const Text("Sửa sân"),

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
                    labelText: "Môn thể thao",
                  ),

                  items: sports.map((doc) {
                    final name = doc['name'] as String;

                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
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
          onPressed: updateField,
          child: const Text("Cập nhật"),
        ),
      ],
    );
  }
}