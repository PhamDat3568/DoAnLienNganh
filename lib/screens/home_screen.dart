import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/sport_service.dart';

import 'field_list_screen.dart';
import 'food_screen.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'my_booking_screen.dart';
import 'my_food_orders_screen.dart';
import 'equipment_screen.dart';
import 'equipment_select_field_screen.dart';
import 'my_equipment_orders_screen.dart';
import 'my_equipment_orders_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(
      BuildContext context,
      ) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),
          (route) => false,
    );
  }

  IconData getSportIcon(
      String icon,
      ) {
    switch (icon) {
      case 'sports_soccer':
        return Icons.sports_soccer;

      case 'sports_basketball':
        return Icons.sports_basketball;

      case 'sports_volleyball':
        return Icons.sports_volleyball;

      case 'sports_tennis':
        return Icons.sports_tennis;

      default:
        return Icons.sports;
    }
  }

  void openMenu(
      BuildContext context,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.book,
              ),
              title: const Text(
                "Lịch đặt sân của tôi",
              ),
              onTap: () {
                Navigator.pop(
                    context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const MyBookingScreen(),
                  ),
                );
              },
            ),

            // 🍔 ĐẶT ĐỒ ĂN
            ListTile(
              leading: const Icon(
                Icons.restaurant_menu,
              ),
              title: const Text(
                "Đặt đồ ăn",
              ),
              onTap: () {
                Navigator.pop(
                    context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const FoodScreen(),
                  ),
                );
              },
            ),

            // 📋 ĐƠN ĐỒ ĂN
            ListTile(
              leading: const Icon(
                Icons.fastfood,
              ),
              title: const Text(
                "Đơn đồ ăn của tôi",
              ),
              onTap: () {
                Navigator.pop(
                    context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const MyFoodOrdersScreen(),
                  ),
                );
              },
            ),

            // 🗺 BẢN ĐỒ
            ListTile(
              leading: const Icon(
                Icons.map,
              ),
              title: const Text(
                "Bản đồ sân",
              ),
              onTap: () {
                Navigator.pop(
                    context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const MapScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports),
              title: const Text("Thuê dụng cụ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EquipmentSelectFieldScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Lịch sử thuê dụng cụ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyEquipmentOrdersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.support_agent,
              ),
              title: const Text(
                "Thông tin liên hệ",
              ),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                      "Thông tin hỗ trợ",
                    ),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone),
                            SizedBox(width: 10),
                            Text(
                              "Hotline: 0123456789",
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [
                            Icon(Icons.email),
                            SizedBox(width: 10),
                            Text(
                              "Email: support@sportbooking.com",
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 10),
                            Text(
                              "Luôn luôn online",
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(
                              context,
                            ),
                        child: const Text(
                          "Đóng",
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // 🚪 ĐĂNG XUẤT
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(
                    context);

                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đặt sân thể thao",
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
            ),
            onPressed: () {
              openMenu(
                  context);
            },
          ),
        ],
      ),

      body: StreamBuilder<
          QuerySnapshot>(
        stream:
        SportService()
            .getSports(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot
              .hasError) {
            return const Center(
              child: Text(
                "Có lỗi xảy ra",
              ),
            );
          }

          if (!snapshot
              .hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final sports =
              snapshot
                  .data!
                  .docs;

          if (sports.isEmpty) {
            return const Center(
              child: Text(
                "Chưa có môn thể thao",
              ),
            );
          }

          return GridView.builder(
            padding:
            const EdgeInsets
                .all(16),

            itemCount:
            sports.length,

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              2,
              crossAxisSpacing:
              15,
              mainAxisSpacing:
              15,
              childAspectRatio:
              1,
            ),

            itemBuilder: (
                context,
                index,
                ) {
              final sport =
              sports[index];

              return Card(
                elevation: 4,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      15),
                ),

                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(
                      15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FieldListScreen(
                              sportType:
                              sport['name'],
                            ),
                      ),
                    );
                  },

                  child: Padding(
                    padding:
                    const EdgeInsets
                        .all(15),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Icon(
                          getSportIcon(
                            sport[
                            'icon'],
                          ),
                          size: 60,
                          color:
                          Colors.blue,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Text(
                          sport[
                          'name'],
                          textAlign:
                          TextAlign
                              .center,
                          style:
                          const TextStyle(
                            fontSize:
                            18,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ],
                    ),
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