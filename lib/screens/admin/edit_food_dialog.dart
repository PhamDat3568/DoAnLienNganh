import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditFoodDialog extends StatefulWidget {
  final String docId;
  final String oldName;
  final String oldPrice;
  final String oldImage;
  final bool oldStatus;

  const EditFoodDialog({
    super.key,
    required this.docId,
    required this.oldName,
    required this.oldPrice,
    required this.oldImage,
    required this.oldStatus,
  });

  @override
  State<EditFoodDialog> createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController imageController;

  late bool status;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.oldName);
    priceController = TextEditingController(text: widget.oldPrice);
    imageController = TextEditingController(text: widget.oldImage);

    status = widget.oldStatus;
  }

  Future<void> updateFood() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final price = int.tryParse(priceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giá tiền không hợp lệ")),
      );
      return;
    }

    try {
      setState(() => loading = true);

      await FirebaseFirestore.instance
          .collection('foods')
          .doc(widget.docId)
          .update({
        'name': nameController.text.trim(),
        'price': price,
        'image': imageController.text.trim(),
        'status': status,
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật món ăn thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
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
      title: const Text("Sửa món ăn"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tên món ăn",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Giá tiền",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "Link ảnh",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: status,
              title: Text(status ? "Đang bán" : "Ngừng bán"),
              onChanged: (value) {
                setState(() => status = value);
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: loading ? null : () => Navigator.pop(context),
          child: const Text("Huỷ"),
        ),

        ElevatedButton(
          onPressed: loading ? null : updateFood,
          child: loading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Lưu"),
        ),
      ],
    );
  }
}