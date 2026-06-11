import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String documentId;
  final String collectionName;
  final int totalPrice;

  const PaymentScreen({
    super.key,
    required this.documentId,
    required this.collectionName,
    required this.totalPrice,
  });

  Future<void> confirmPayment(
      BuildContext context,
      ) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .update({
      'status': 'waiting_confirm',
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Đã gửi xác nhận thanh toán",
        ),
      ),
    );

    Navigator.popUntil(
      context,
          (route) => route.isFirst,
    );
  }

  Future<void> cancelPayment(
      BuildContext context,
      ) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .delete();

    if (!context.mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(
      BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await cancelPayment(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Thanh toán",
          ),
        ),

        body: Padding(
          padding:
          const EdgeInsets.all(
            20,
          ),
          child: Column(
            children: [

              Container(
                height: 250,
                width:
                double.infinity,
                color:
                Colors.grey[300],
                child: const Center(
                  child: Text(
                    "QR CHUYỂN KHOẢN",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 20),

              const Text(
                "Thông tin chuyển khoản",
                style: TextStyle(
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),

              const SizedBox(
                  height: 10),

              const Text(
                "Ngân hàng: Vietcombank",
              ),

              const Text(
                "STK: 123456789",
              ),

              const Text(
                "Tên: DAT SAN APP",
              ),

              const SizedBox(
                  height: 20),

              Text(
                "Số tiền: $totalPrice VNĐ",
                style:
                const TextStyle(
                  fontSize: 22,
                  color:
                  Colors.green,
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                ElevatedButton(
                  onPressed: () =>
                      confirmPayment(
                        context,
                      ),
                  child:
                  const Text(
                    "Tôi đã chuyển khoản",
                  ),
                ),
              ),

              const SizedBox(
                  height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                OutlinedButton(
                  onPressed: () =>
                      cancelPayment(
                        context,
                      ),
                  child:
                  const Text(
                    "Huỷ thanh toán",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}