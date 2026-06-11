import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddFoodDialog extends StatefulWidget {
  const AddFoodDialog({super.key});

  @override
  State<AddFoodDialog> createState() =>
      _AddFoodDialogState();
}

class _AddFoodDialogState
    extends State<AddFoodDialog> {
  final nameController =
  TextEditingController();

  final priceController =
  TextEditingController();

  final imageController =
  TextEditingController();

  final categoryController =
  TextEditingController();

  bool status = true;
  bool loading = false;

  final List<String> defaultCategories = [
    'Đồ uống',
    'Đồ ăn nhanh',
    'Snack',
    'Mì ly',
    'Trái cây',
    'Khác',
  ];

  String? selectedCategory;

  Future<void> saveFood() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin"),
        ),
      );
      return;
    }

    final category = selectedCategory == 'Khác'
        ? categoryController.text.trim()
        : selectedCategory;

    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn loại món ăn"),
        ),
      );
      return;
    }

    final price = int.tryParse(priceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giá tiền không hợp lệ"),
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await FirebaseFirestore.instance.collection('foods').add({
        'name': nameController.text.trim(),
        'category': category,
        'price': price,
        'image': imageController.text.trim(),
        'status': status,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thêm món ăn thành công"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    imageController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thêm món ăn"),

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

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Loại món ăn",
                border: OutlineInputBorder(),
              ),
              items: defaultCategories
                  .map(
                    (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            if (selectedCategory == 'Khác') ...[
              const SizedBox(height: 15),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Nhập loại món ăn",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

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
              title: const Text("Đang bán"),
              onChanged: (value) {
                setState(() {
                  status = value;
                });
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
          onPressed: loading ? null : saveFood,
          child: loading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Thêm"),
        ),
      ],
    );
  }
}