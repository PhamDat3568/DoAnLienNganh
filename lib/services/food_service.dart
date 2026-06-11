import 'package:cloud_firestore/cloud_firestore.dart';

class FoodService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot> getFoods() {
    return _firestore
        .collection('foods')
        .snapshots();
  }
}