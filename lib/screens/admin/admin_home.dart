import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../login_screen.dart';
import 'admin_bookings_screen.dart';
import 'manage_fields.dart';
import 'manage_foods_screen.dart';
import 'admin_food_orders_screen.dart';
import 'manage_equipment_screen.dart';
import 'admin_equipment_orders_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: ListView(
        children: [

          // QUẢN LÝ SÂN
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text("Quản lý sân"),
            subtitle: const Text(
              "Thêm / sửa / xoá sân",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageFields(),
                ),
              );
            },
          ),

          const Divider(),

          // BOOKING
          ListTile(
            leading: const Icon(
              Icons.calendar_month,
            ),
            title: const Text(
              "Danh sách đặt sân",
            ),
            subtitle: const Text(
              "Xem tất cả booking",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const AdminBookingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // QUẢN LÝ MÓN ĂN
          ListTile(
            leading: const Icon(Icons.fastfood),
            title: const Text(
              "Quản lý món ăn",
            ),
            subtitle: const Text(
              "Thêm / sửa / xoá món ăn",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ManageFoodsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // ĐƠN ĐỒ ĂN
          ListTile(
            leading: const Icon(
              Icons.receipt_long,
            ),
            title: const Text(
              "Đơn đặt đồ ăn",
            ),
            subtitle: const Text(
              "Xác nhận / huỷ đơn",
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const AdminFoodOrdersScreen(),
                ),
              );
            },
          ),
          const Divider(),

// QUẢN LÝ DỤNG CỤ
          ListTile(
            leading: const Icon(Icons.sports),
            title: const Text("Quản lý dụng cụ"),
            subtitle: const Text("Thêm / sửa / xoá dụng cụ"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageEquipmentScreen(),
                ),
              );
            },
          ),

          const Divider(),

// ĐƠN THUÊ DỤNG CỤ
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text("Đơn thuê dụng cụ"),
            subtitle: const Text("Xác nhận / huỷ đơn thuê"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminEquipmentOrdersScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}