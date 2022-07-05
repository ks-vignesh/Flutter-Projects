class Todo {
  String? id;
  String title;
  String description;
  String category;
  String date;
  var documentSnapshot;

  Todo(this.title, this.description, this.category, this.date,
      [this.documentSnapshot, this.id]);
}
