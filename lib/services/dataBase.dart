import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseService {
  final CollectionReference categories = FirebaseFirestore.instance.collection('categories');
  Stream<QuerySnapshot> getCategories(){
    final categoriesStream = categories.orderBy('name', descending: true).snapshots();

    return categoriesStream;
}
}