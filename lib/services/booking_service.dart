import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<String?> createBooking({
    required String fieldId,
    required String fieldName,
    required String sportType,
    required String date,
    required int startHour,
    required int endHour,
    required int pricePerHour,
  }) async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return "Chưa đăng nhập";
      }

      // Lấy thông tin user
      DocumentSnapshot userDoc =
      await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      String phone = '';

      if (userDoc.exists) {
        final data =
        userDoc.data()
        as Map<String, dynamic>;

        phone = data['phone'] ?? '';
      }

      // Kiểm tra trùng lịch
      QuerySnapshot snapshot =
      await _firestore
          .collection('bookings')
          .where(
        'fieldId',
        isEqualTo: fieldId,
      )
          .where(
        'date',
        isEqualTo: date,
      )
          .get();

      for (var doc in snapshot.docs) {
        final status =
        doc['status'];

        // Bỏ qua booking đã huỷ
        if (status ==
            'cancelled') {
          continue;
        }

        int bookedStart =
        doc['startHour'];

        int bookedEnd =
        doc['endHour'];

        bool overlap =
            startHour <
                bookedEnd &&
                endHour >
                    bookedStart;

        if (overlap) {
          return "Khung giờ đã được đặt";
        }
      }

      int totalPrice =
          (endHour -
              startHour) *
              pricePerHour;

      DocumentReference docRef =
      await _firestore
          .collection(
          'bookings')
          .add({
        'userId': user.uid,

        'userEmail':
        user.email,

        // THÊM SỐ ĐIỆN THOẠI
        'userPhone': phone,

        'fieldId': fieldId,

        'fieldName':
        fieldName,

        'sportType':
        sportType,

        'date': date,

        'startHour':
        startHour,

        'endHour':
        endHour,

        'totalPrice':
        totalPrice,

        // Chờ xác nhận
        'status':
        'waiting_confirm',

        'createdAt':
        Timestamp.now(),
      });

      return docRef.id;
    } catch (e) {
      return e.toString();
    }
  }
}