import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String? id;
  String title;
  String description;
  String category;
  String date;
  DocumentSnapshot? documentSnapshot;

  Todo(this.title, this.description, this.category, this.date,
      [this.documentSnapshot,this.id]);
}
