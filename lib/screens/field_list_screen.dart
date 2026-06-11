import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/field_service.dart';
import 'booking_screen.dart';

class FieldListScreen extends StatefulWidget {
  final String sportType;

  const FieldListScreen({
    super.key,
    required this.sportType,
  });

  @override
  State<FieldListScreen> createState() =>
      _FieldListScreenState();
}

class _FieldListScreenState
    extends State<FieldListScreen> {

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sportType),
      ),

      body: Column(
        children: [

          /// TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                "Tìm theo tên sân hoặc địa chỉ",
                prefixIcon:
                const Icon(Icons.search),

                suffixIcon:
                searchText.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();

                    setState(() {
                      searchText = '';
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
                    : null,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchText = value
                      .toLowerCase()
                      .trim();
                });
              },
            ),
          ),

          Expanded(
            child:
            StreamBuilder<QuerySnapshot>(
              stream: FieldService()
                  .getFieldsBySport(
                widget.sportType,
              ),

              builder:
                  (context, snapshot) {

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

                List<QueryDocumentSnapshot>
                fields =
                    snapshot.data!.docs;

                /// LỌC THEO TÊN / ĐỊA CHỈ
                if (searchText.isNotEmpty) {
                  fields = fields.where(
                        (field) {
                      final data =
                      field.data()
                      as Map<
                          String,
                          dynamic>;

                      final name =
                      (data['name'] ??
                          '')
                          .toString()
                          .toLowerCase();

                      final address =
                      (data['address'] ??
                          '')
                          .toString()
                          .toLowerCase();

                      return name.contains(
                          searchText) ||
                          address.contains(
                              searchText);
                    },
                  ).toList();
                }

                if (fields.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không tìm thấy sân",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: fields.length,

                  itemBuilder:
                      (context, index) {

                    final field =
                    fields[index];

                    final data =
                    field.data()
                    as Map<
                        String,
                        dynamic>;

                    return Card(
                      margin:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      elevation: 4,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),
                      ),

                      child: InkWell(
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingScreen(
                                    fieldId: field.id,
                                    fieldName: data['name'],
                                    sportType: data['sportType'],
                                    pricePerHour: data['pricePerHour'],
                                    image: data['image'] ?? '',
                                  )
                            ),
                          );
                        },

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            /// ẢNH SÂN
                            ClipRRect(
                              borderRadius:
                              const BorderRadius
                                  .only(
                                topLeft:
                                Radius.circular(
                                  16,
                                ),

                                topRight:
                                Radius.circular(
                                  16,
                                ),
                              ),

                              child:
                              data['image'] !=
                                  null &&
                                  data['image']
                                      .toString()
                                      .isNotEmpty
                                  ? Image.network(
                                data[
                                'image'],

                                width: double
                                    .infinity,

                                height:
                                230,

                                fit: BoxFit
                                    .cover,

                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Container(
                                    height:
                                    230,

                                    color: Colors
                                        .grey[
                                    300],

                                    child:
                                    const Center(
                                      child:
                                      Icon(
                                        Icons
                                            .broken_image,
                                        size:
                                        60,
                                      ),
                                    ),
                                  );
                                },
                              )
                                  : Container(
                                height:
                                230,

                                color: Colors
                                    .grey[
                                300],

                                child:
                                const Center(
                                  child:
                                  Icon(
                                    Icons
                                        .image,
                                    size:
                                    60,
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                              const EdgeInsets
                                  .all(
                                12,
                              ),

                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  Text(
                                    data[
                                    'name'],

                                    style:
                                    const TextStyle(
                                      fontSize:
                                      20,

                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons
                                            .location_on,

                                        color: Colors
                                            .red,

                                        size:
                                        18,
                                      ),

                                      const SizedBox(
                                        width:
                                        5,
                                      ),

                                      Expanded(
                                        child:
                                        Text(
                                          data[
                                          'address'],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    "${data['pricePerHour']} VNĐ/giờ",

                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons
                                            .star,

                                        color: Colors
                                            .amber,

                                        size:
                                        18,
                                      ),

                                      const SizedBox(
                                        width:
                                        5,
                                      ),

                                      Text(
                                        "${data['rating'] ?? 0}",
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal:
                                      12,

                                      vertical:
                                      6,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color: data[
                                      'status']
                                          ? Colors
                                          .green
                                          : Colors
                                          .red,

                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        20,
                                      ),
                                    ),

                                    child: Text(
                                      data['status']
                                          ? "Còn trống"
                                          : "Đã kín",

                                      style:
                                      const TextStyle(
                                        color: Colors
                                            .white,

                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}