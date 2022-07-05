import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/res/custom_colors.dart';
import 'package:todo_list_app/services/todo_service.dart';
import 'package:todo_list_app/utils/Constants.dart';
import 'package:todo_list_app/utils/commonFunctions.dart';

import '../models/todo.dart';

class MakeToDo extends StatefulWidget {
  final Function addCategoryCallback;
  Todo? editTodo;
  bool isEdit;
  String? indexValue;
  String? emailAddress;

  MakeToDo(this.addCategoryCallback, this.isEdit,
      [this.emailAddress, this.indexValue, this.editTodo]);

  @override
  State<MakeToDo> createState() => _MakeToDoState();
}

class _MakeToDoState extends State<MakeToDo> {
  TextEditingController todoTitleNameController = new TextEditingController();
  TextEditingController todoDescriptionController = new TextEditingController();
  var todoDateandimeController;
  var todoCategory = [Constants.PERSONAL, Constants.BUSINESS];
  var todoDateandTimeastimestampValue;
  String buttonValue = "ADD YOUR THING";

  String? selectedCategory;

  @override
  void initState() {
    //setting the values in their respective fields for edit purpose
    if (widget.isEdit) {
      buttonValue = "UPDATE";
      setState(() {
        todoTitleNameController.text = widget.editTodo!.title;
        todoDescriptionController.text = widget.editTodo!.description;
        selectedCategory = widget.editTodo!.category;
        todoDateandTimeastimestampValue = widget.editTodo!.date;
      });
    }
    super.initState();
  }

  void addtheNewThingsinToDoList() {
    if (widget.isEdit) {
      //Edit functionality todo
      var tempTodo = Todo(
        todoTitleNameController.text,
        todoDescriptionController.text,
        selectedCategory.toString(),
        todoDateandTimeastimestampValue.toString(),
        widget.editTodo,
      );
      tempTodo.id = widget.indexValue.toString();
      context.read<TodoService>().updateTodo(
            tempTodo,
            widget.emailAddress.toString(),
          );

      //we need to pass only if there any changes in category while editing else don't need to pass callback
      if (widget.editTodo!.category != selectedCategory.toString()) {
        widget.addCategoryCallback(
            Constants.UPDATEACTION, selectedCategory.toString());
      }
    } else {
      //Add functionality todo
      widget.addCategoryCallback(
          Constants.ADDACTION, selectedCategory.toString());
      context.read<TodoService>().addTodo(
            Todo(
              todoTitleNameController.text,
              todoDescriptionController.text,
              selectedCategory.toString(),
              todoDateandTimeastimestampValue.toString(),
              widget.editTodo,
            ),
            widget.emailAddress.toString(),
            false,
          );
    }
    Navigator.of(context).pop();
  }

  inputDecorationFeature(String labelValue) {
    return InputDecoration(
      labelText: labelValue,
      contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      labelStyle: TextStyle(
        color: Colors.grey,
        //fontSize: 16,
      ),
      counterText: "",
    );
  }

  sizedBoxHeightValueinbetweenTextFields() {
    return SizedBox(
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0047ab),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    new IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white60,
                        size: 30,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Add new thing",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    )
                  ],
                ),
                sizedBoxHeightValueinbetweenTextFields(),
                ClipOval(
                  child: Material(
                    color: CustomColors.firebaseGrey.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.wysiwyg_rounded,
                        size: 60,
                        color: CustomColors.firebaseGrey,
                      ),
                    ),
                  ),
                ),
                sizedBoxHeightValueinbetweenTextFields(),
                sizedBoxHeightValueinbetweenTextFields(),
                Container(
                    height: 40.0,
                    child: DropdownButton<String>(
                      hint: Text(
                        "Select Category",
                        style: TextStyle(fontSize: 18.0, color: Colors.grey),
                      ),
                      value: selectedCategory,
                      isDense: true,
                      isExpanded: true,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      items: todoCategory.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(" " + value),
                        );
                      }).toList(),
                    )),
                sizedBoxHeightValueinbetweenTextFields(),
                TextField(
                  controller: todoTitleNameController,
                  obscureText: false,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                  decoration: inputDecorationFeature("Title"),
                ),
                sizedBoxHeightValueinbetweenTextFields(),
                TextField(
                  controller: todoDescriptionController,
                  obscureText: false,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                  ),
                  decoration: inputDecorationFeature("Description"),
                ),
                sizedBoxHeightValueinbetweenTextFields(),
                DateTimePicker(
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd MMM, yyyy',
                    initialValue: widget.isEdit
                        ? todoDateandTimeastimestampValue.toString()
                        : DateTime.now().toString(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    icon: Icon(Icons.event),
                    dateLabelText: 'Date',
                    timeLabelText: "Hour",
                    onChanged: (val) {
                      todoDateandTimeastimestampValue = val;
                      print("todoDateandTimeastimestampValue " +
                          todoDateandTimeastimestampValue.toString());
                    },
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) {
                      print(val!);
                    }),
                sizedBoxHeightValueinbetweenTextFields(),
                sizedBoxHeightValueinbetweenTextFields(),
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.horizontal(),
                  color: Color(0xff01A0C7),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: () async {
                      //validations
                      if (todoTitleNameController.text == "") {
                        CommonFunction.showSnackBarWidget(
                            "Enter Title", context);
                      } else if (selectedCategory == null) {
                        CommonFunction.showSnackBarWidget(
                            "Select Category", context);
                      } else if (todoDescriptionController.text == "") {
                        CommonFunction.showSnackBarWidget(
                            "Enter Description", context);
                      } else {
                        if (todoDateandTimeastimestampValue == null) {
                          todoDateandTimeastimestampValue =
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(DateTime.now());
                        }
                        addtheNewThingsinToDoList();
                      }
                    },
                    child: Text(buttonValue,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontFamily: 'Montserrat', fontSize: 18.0)
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
