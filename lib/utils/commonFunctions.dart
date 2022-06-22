import 'package:flutter/material.dart';

class CommonFunction {
  //snack bar
  static showSnackBarWidget(String text, BuildContext context) {
    final snackBar = new SnackBar(
      backgroundColor: Colors.blueGrey,
      duration: const Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.fixed,
      content: Text(text),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
