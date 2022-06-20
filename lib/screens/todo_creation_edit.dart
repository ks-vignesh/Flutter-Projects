import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/res/custom_colors.dart';
import 'package:todo_list_app/utils/Constants.dart';

class MakeToDo extends StatefulWidget {
  final Function addFilterTx;
  DocumentSnapshot? documentSnapshot;
  bool isEdit;

  MakeToDo(this.addFilterTx, this.isEdit, [this.documentSnapshot]);

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
        todoTitleNameController.text =
            widget.documentSnapshot![Constants.TITLE];
        todoDescriptionController.text =
            widget.documentSnapshot![Constants.DESCRIPTION];
        selectedCategory = widget.documentSnapshot![Constants.CATEGORY];
        todoDateandTimeastimestampValue =
            widget.documentSnapshot![Constants.TIME];
      });
    }
    super.initState();
  }

  void addtheNewThingsinToDoList() {
    //Passing the selected values to Main Search Screen
    widget.addFilterTx(
      widget.documentSnapshot,
      todoTitleNameController.text,
      todoDescriptionController.text,
      selectedCategory,
      todoDateandTimeastimestampValue.toString(),
    );
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
                        showSnackBarWidget("Enter Title", context);
                      } else if (selectedCategory == null) {
                        showSnackBarWidget("Select Category", context);
                      } else if (todoDescriptionController.text == "") {
                        showSnackBarWidget("Enter Description", context);
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

  //snack bar
  showSnackBarWidget(String text, BuildContext context) {
    final snackBar = new SnackBar(
      duration: const Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
