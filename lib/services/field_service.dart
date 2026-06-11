import 'package:cloud_firestore/cloud_firestore.dart';

class FieldService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot> getFieldsBySport(
      String sportType) {
    return _firestore
        .collection('fields')
        .where(
      'sportType',
      isEqualTo: sportType,
    )
        .snapshots();
  }
}