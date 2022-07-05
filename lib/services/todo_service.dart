import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_list_app/models/todo.dart';

import '../utils/Constants.dart';

class TodoService with ChangeNotifier {
  List<Todo> todos = [];
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  addTodo(Todo todo, String emailAddress, bool isInitialLoad) async {
    if (isInitialLoad) {
      //while initial app launch if user has some todo's then this block will be executed
      todos.add(todo);
    } else {
      //Adding the todo
      await firebaseFirestore
          .collection(Constants.FIREBASEDBNAME + '_' + emailAddress)
          .add({
        Constants.TITLE: todo.title,
        Constants.DESCRIPTION: todo.description,
        Constants.CATEGORY: todo.category,
        Constants.TIME: todo.date,
      }).then((value) {
        todo.id = value.id;
        todos.add(todo);
      });
    }
    notifyListeners();
  }

  removeTodo(id, String emailAddress) async {
    //deleting the todo using ID
    var index = todos.indexWhere((element) => element.id == id);
    if (index != -1) {
      await firebaseFirestore
          .collection(Constants.FIREBASEDBNAME + '_' + emailAddress)
          .doc(id)
          .delete();
      todos.removeAt(index);
    }
    notifyListeners();
  }

  updateTodo(Todo todo, String emailAddress) async {
    //updating the todo using ID
    var index = todos.indexWhere((element) => element.id == todo.id);
    if (index != -1) {
      await firebaseFirestore
          .collection(Constants.FIREBASEDBNAME + '_' + emailAddress)
          .doc(todo.id)
          .update({
        Constants.TITLE: todo.title,
        Constants.DESCRIPTION: todo.description,
        Constants.CATEGORY: todo.category,
        Constants.TIME: todo.date,
      });
      todos[index] = todo;
    }
    notifyListeners();
  }
}
