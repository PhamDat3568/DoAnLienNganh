import 'package:cloud_firestore/cloud_firestore.dart';

class SportService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot> getSports() {
    return _firestore
        .collection('sports')
        .snapshots();
  }
}