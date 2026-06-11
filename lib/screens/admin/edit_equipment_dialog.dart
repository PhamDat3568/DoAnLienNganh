import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditEquipmentDialog extends StatefulWidget {
  final String docId;
  final String oldName;
  final String oldPrice;
  final String oldImage;

  const EditEquipmentDialog({
    super.key,
    required this.docId,
    required this.oldName,
    required this.oldPrice,
    required this.oldImage,
  });

  @override
  State<EditEquipmentDialog> createState() => _EditEquipmentDialogState();
}

class _EditEquipmentDialogState extends State<EditEquipmentDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController imageController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.oldName);
    priceController = TextEditingController(text: widget.oldPrice);
    imageController = TextEditingController(text: widget.oldImage);
  }

  Future<void> update() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('equipment')
          .doc(widget.docId)
          .update({
        'name': nameController.text.trim(),
        'price': int.tryParse(priceController.text.trim()) ?? 0,
        'image': imageController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sửa dụng cụ"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Tên"),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Giá"),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: imageController,
            decoration: const InputDecoration(labelText: "Link ảnh"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Huỷ"),
        ),

        ElevatedButton(
          onPressed: loading ? null : update,
          child: loading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Lưu"),
        ),
      ],
    );
  }
}