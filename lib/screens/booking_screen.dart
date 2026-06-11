import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/booking_service.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  final String sportType;
  final int pricePerHour;
  final String image;

  const BookingScreen({
    super.key,
    required this.fieldId,
    required this.fieldName,
    required this.sportType,
    required this.pricePerHour,
    required this.image,
  });

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {
  DateTime selectedDate =
  DateTime.now();

  bool loading = false;

  // Giờ đã được thuê
  List<int> bookedHours = [];

  // Giờ user chọn
  Set<int> selectedHours = {};

  @override
  void initState() {
    super.initState();
    loadBookedHours();
  }

  Future<void> loadBookedHours() async {
    final date = DateFormat(
      'yyyy-MM-dd',
    ).format(selectedDate);

    final snapshot =
    await FirebaseFirestore
        .instance
        .collection('bookings')
        .where(
      'fieldId',
      isEqualTo: widget.fieldId,
    )
        .where(
      'date',
      isEqualTo: date,
    )
        .get();

    List<int> hours = [];

    for (var doc in snapshot.docs) {
      final status =
      doc['status'];

      // Bỏ qua booking đã huỷ
      if (status ==
          'cancelled') {
        continue;
      }

      int start =
      doc['startHour'];

      int end =
      doc['endHour'];

      for (
      int i = start;
      i < end;
      i++
      ) {
        hours.add(i);
      }
    }

    setState(() {
      bookedHours = hours;
    });
  }

  void selectHour(int hour) {
    if (bookedHours.contains(
      hour,
    )) {
      return;
    }

    setState(() {
      if (selectedHours
          .contains(hour)) {
        selectedHours.remove(
          hour,
        );
      } else {
        selectedHours.add(
          hour,
        );
      }
    });
  }

  Future<void> book() async {
    if (selectedHours
        .isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng chọn giờ",
          ),
        ),
      );

      return;
    }

    final sorted =
    selectedHours
        .toList()
      ..sort();

    // Kiểm tra liên tiếp
    for (
    int i = 0;
    i <
        sorted.length -
            1;
    i++
    ) {
      if (sorted[i + 1] !=
          sorted[i] + 1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              "Vui lòng chọn giờ liên tiếp",
            ),
          ),
        );

        return;
      }
    }

    int startHour =
        sorted.first;

    int endHour =
        sorted.last + 1;

    setState(() {
      loading = true;
    });

    String? result =
    await BookingService()
        .createBooking(
      fieldId:
      widget.fieldId,
      fieldName:
      widget.fieldName,
      sportType:
      widget.sportType,
      date: DateFormat(
        'yyyy-MM-dd',
      ).format(
        selectedDate,
      ),
      startHour:
      startHour,
      endHour:
      endHour,
      pricePerHour:
      widget
          .pricePerHour,
    );

    setState(() {
      loading = false;
    });

    if (!mounted) return;

    if (result == null ||
        result.contains(
          "Khung giờ",
        )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            result ?? "Lỗi",
          ),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentScreen(
              documentId: result!,
              collectionName: 'bookings',
              totalPrice:
              (endHour - startHour) *
                  widget.pricePerHour,
            )
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fieldName,
        ),
      ),

      body:
      SingleChildScrollView(
        child: Column(
          children: [

            // Ảnh sân
            if (widget
                .image
                .isNotEmpty)
              Image.network(
                widget.image,
                width:
                double
                    .infinity,
                height: 220,
                fit:
                BoxFit.cover,
              ),

            // Chọn ngày
            ListTile(
              title:
              const Text(
                "Ngày",
              ),

              subtitle: Text(
                DateFormat(
                  'dd/MM/yyyy',
                ).format(
                  selectedDate,
                ),
              ),

              trailing:
              const Icon(
                Icons
                    .calendar_today,
              ),

              onTap: () async {
                DateTime?
                picked =
                await showDatePicker(
                  context:
                  context,
                  firstDate:
                  DateTime.now(),
                  lastDate:
                  DateTime(
                    2030,
                  ),
                  initialDate:
                  selectedDate,
                );

                if (picked !=
                    null) {
                  setState(() {
                    selectedDate =
                        picked;

                    selectedHours
                        .clear();
                  });

                  loadBookedHours();
                }
              },
            ),

            const Padding(
              padding:
              EdgeInsets.all(
                12,
              ),
              child: Text(
                "Chọn giờ",
                style:
                TextStyle(
                  fontSize:
                  18,
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),
            ),

            // Grid giờ
            GridView.builder(
              shrinkWrap:
              true,

              physics:
              const NeverScrollableScrollPhysics(),

              padding:
              const EdgeInsets
                  .all(
                10,
              ),

              itemCount: 24,

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                4,
                childAspectRatio:
                2,
                crossAxisSpacing:
                10,
                mainAxisSpacing:
                10,
              ),

              itemBuilder:
                  (
                  context,
                  index,
                  ) {

                bool booked =
                bookedHours
                    .contains(
                  index,
                );

                bool selected =
                selectedHours
                    .contains(
                  index,
                );

                return InkWell(
                  onTap: booked
                      ? null
                      : () =>
                      selectHour(
                        index,
                      ),

                  child:
                  Container(
                    decoration:
                    BoxDecoration(
                      color: booked
                          ? Colors
                          .grey
                          : selected
                          ? Colors
                          .orange
                          : Colors
                          .green,

                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),

                    child: Center(
                      child: Text(
                        "${index.toString().padLeft(2, '0')}:00",

                        style:
                        const TextStyle(
                          color: Colors
                              .white,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(
              height: 20,
            ),

            if (selectedHours
                .isNotEmpty)
              Padding(
                padding:
                const EdgeInsets
                    .all(
                  12,
                ),

                child: Text(
                  "Đã chọn: ${(selectedHours.toList()..sort()).map((e) => '${e.toString().padLeft(2, '0')}:00').join(', ')}",

                  textAlign:
                  TextAlign
                      .center,

                  style:
                  const TextStyle(
                    fontSize:
                    16,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),

            if (selectedHours
                .isNotEmpty)
              Text(
                "Tổng tiền: ${selectedHours.length * widget.pricePerHour} VNĐ",

                style:
                const TextStyle(
                  fontSize:
                  18,
                  fontWeight:
                  FontWeight
                      .bold,
                ),
              ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed:
              loading
                  ? null
                  : book,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text(
                "Đặt sân",
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}