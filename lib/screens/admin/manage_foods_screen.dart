import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_food_dialog.dart';
import 'edit_food_dialog.dart';

class ManageFoodsScreen extends StatelessWidget {
  const ManageFoodsScreen({super.key});

  Future<void> deleteFood(
      BuildContext context,
      String docId,
      String foodName,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xoá món ăn"),
        content: Text(
          "Bạn có chắc muốn xoá '$foodName'?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              "Xoá",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('foods')
        .doc(docId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã xoá món ăn"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý món ăn",
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) =>
            const AddFoodDialog(),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Có lỗi xảy ra",
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có món ăn",
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder:
                (context, index) {
              final data =
              docs[index];

              final food =
              data.data()
              as Map<String,
                  dynamic>;

              return Card(
                margin:
                const EdgeInsets.all(
                    10),

                child: ListTile(
                  leading: food[
                  'image'] !=
                      null &&
                      food['image']
                          .toString()
                          .isNotEmpty
                      ? ClipRRect(
                    borderRadius:
                    BorderRadius
                        .circular(
                        8),
                    child:
                    Image.network(
                      food['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit
                          .cover,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .fastfood,
                          size: 40,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.fastfood,
                    size: 40,
                  ),

                  title: Text(
                    food['name'] ??
                        '',
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        "${food['price']} VNĐ",
                      ),

                      Text(
                        food['status'] ==
                            true
                            ? "Đang bán"
                            : "Ngừng bán",
                        style:
                        TextStyle(
                          color: food['status'] ==
                              true
                              ? Colors
                              .green
                              : Colors
                              .red,
                        ),
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                        const Icon(
                          Icons.edit,
                          color: Colors
                              .blue,
                        ),
                        onPressed:
                            () {
                          showDialog(
                            context:
                            context,
                            builder:
                                (_) =>
                                EditFoodDialog(
                                  docId:
                                  data.id,
                                  oldName:
                                  food['name'],
                                  oldPrice:
                                  food['price']
                                      .toString(),
                                  oldImage:
                                  food['image'] ??
                                      '',
                                  oldStatus:
                                  food['status'] ??
                                      true,
                                ),
                          );
                        },
                      ),

                      IconButton(
                        icon:
                        const Icon(
                          Icons.delete,
                          color: Colors
                              .red,
                        ),
                        onPressed:
                            () {
                          deleteFood(
                            context,
                            data.id,
                            food['name'],
                          );
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