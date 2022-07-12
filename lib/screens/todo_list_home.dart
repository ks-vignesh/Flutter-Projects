import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/models/todo.dart';
import 'package:todo_list_app/screens/todo_creation_edit.dart';
import 'package:todo_list_app/services/todo_service.dart';
import 'package:todo_list_app/utils/Constants.dart';
import 'package:todo_list_app/utils/commonFunctions.dart';
import 'package:todo_list_app/widgets/drawer.dart';

class ToDoListHomePage extends StatefulWidget {
  String userEmailAddressforID;
  var user;

  ToDoListHomePage(this.userEmailAddressforID, this.user);

  @override
  _ToDoListHomePageState createState() => _ToDoListHomePageState();
}

class _ToDoListHomePageState extends State<ToDoListHomePage> {
  late CollectionReference _toDos;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int personalCount = 0;
  int businessCount = 0;

  @override
  void initState() {
    _toDos = FirebaseFirestore.instance.collection(
        Constants.FIREBASEDBNAME + '_' + widget.userEmailAddressforID);

    //getting the category counts to display in home page
    FirebaseFirestore.instance
        .collection(
            Constants.FIREBASEDBNAME + '_' + widget.userEmailAddressforID)
        .get()
        .then((val) {
      if (val.docs.length > 0) {
        TodoService(context).todos.clear();
        for (int i = 0; i < val.docs.length; i++) {
          if (val.docs[i].get(Constants.CATEGORY) == Constants.BUSINESS) {
            businessCount++;
          } else {
            personalCount++;
          }

          //loading the available todo in Todo Model
          context.read<TodoService>().addTodo(
                Todo(
                  val.docs[i].get(Constants.TITLE),
                  val.docs[i].get(Constants.DESCRIPTION),
                  val.docs[i].get(Constants.CATEGORY),
                  val.docs[i].get(Constants.TIME),
                  val.docs[i],
                  val.docs[i].id,
                ),
                widget.userEmailAddressforID,
                true,
              );
        }
        setState(() {});
      } else {
        print("No Data Found");
      }
    });
    super.initState();
  }

  getCategoryCount(String action, String category) {
    if (action == Constants.ADDACTION) {
      if (category == Constants.BUSINESS) {
        businessCount++;
      } else {
        personalCount++;
      }
    } else if (action == Constants.UPDATEACTION) {
      if (category == Constants.BUSINESS) {
        businessCount++;
        personalCount--;
      } else {
        personalCount++;
        businessCount--;
      }
    }
    setState(() {});
  }

  // Deleting a tod by id
  Future<void> _deleteProduct(String todoID, String Category) async {
    context
        .read<TodoService>()
        .removeTodo(todoID, widget.userEmailAddressforID);

    // Show a snackbar
    CommonFunction.showSnackBarWidget(
        'Todo Item Deleted Successfully.', context);

    //removing the count in home screen
    if (Category == Constants.BUSINESS) {
      businessCount--;
    } else {
      personalCount--;
    }
    setState(() {});
  }

  getHeaderPartofUIScreen() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Image.asset(
            'assets/todo_home.jpg',
            fit: BoxFit.fitHeight,
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.04,
            left: 0,
            right: MediaQuery.of(context).size.width * 0.50,
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.50,
              //height: MediaQuery.of(context).size.width * 0.40,
              // color: Colors.black.withOpacity(0.1),
              child: BackdropFilter(
                filter: new ImageFilter.blur(
                  sigmaX: 0.0,
                  sigmaY: 0.0,
                ),
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.50,
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.menu,
                                size: 30,
                                color: Colors.white,
                              ),
                              alignment: Alignment.topLeft,
                              onPressed: () {
                                scaffoldKey.currentState!.openDrawer();
                              }),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            ' Your',
                            style: TextStyle(
                              fontFamily: "Barlow",
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            ' Things',
                            style: TextStyle(
                              fontFamily: "Barlow",
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "  " +
                                DateFormat('MMM dd, yyyy')
                                    .format(DateTime.now())
                                    .toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Barlow",
                              color: Colors.white60,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width * 0.50,
            right: 0,
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.50,
              height: MediaQuery.of(context).size.width * 0.40,
              color: Colors.black.withOpacity(0.1),
              child: BackdropFilter(
                filter: new ImageFilter.blur(
                  sigmaX: 0.0,
                  sigmaY: 0.0,
                ),
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.50,
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 58,
                                      ),
                                      Text(
                                        personalCount.toString(),
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontFamily: "Barlow",
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Personal',
                                    style: TextStyle(
                                      fontFamily: "Barlow",
                                      fontSize: 18,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 58,
                                      ),
                                      Text(
                                        businessCount.toString(),
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontFamily: "Barlow",
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Business',
                                    style: TextStyle(
                                      fontFamily: "Barlow",
                                      fontSize: 18,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: MediaQuery.of(context).size.width * 0.50,
            top: MediaQuery.of(context).size.height * 0.345,
            child: SizedBox(
              height: 10.0,
              child: new Center(
                child: new Container(
                  margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                  height: 4.0,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using StreamBuilder to display all products from Firestore in real-time
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      key: scaffoldKey,
      drawer: NavigationDrawer(user: widget.user),
      body: Column(
        children: [
          getHeaderPartofUIScreen(),
          Container(
            margin: EdgeInsets.fromLTRB(20, 15, 10, 5),
            alignment: Alignment.centerLeft,
            child: Text(
              "INBOX",
              style: TextStyle(
                fontFamily: "Barlow",
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              height: MediaQuery.of(context).size.height * 0.55,
              child: StreamBuilder(
                stream: _toDos.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData) {
                    return streamSnapshot.data!.docs.length > 0
                        ? Consumer<TodoService>(
                            builder: (context, value, child) =>
                                ListView.builder(
                              itemCount: streamSnapshot.data!.docs.length > 0
                                  ? value.todos.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return Card(
                                  //elevation: 5,
                                  margin: const EdgeInsets.fromLTRB(5, 2, 5, 0),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    color: Colors.white,
                                    height: 95,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.grey.shade300,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.wysiwyg_rounded,
                                            size: 30,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      width: 150,
                                                      child: Text(
                                                        value
                                                            .todos[index].title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: "Barlow",
                                                          fontSize: 26,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    value.todos[index].date
                                                        .toString()
                                                        .split(" ")[1],
                                                    style: TextStyle(
                                                      fontFamily: "Barlow",
                                                      fontSize: 16,
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      width: 150,
                                                      child: Text(
                                                        value.todos[index]
                                                            .description,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: "Barlow",
                                                          fontSize: 18,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        child: Icon(
                                                          Icons.edit,
                                                          color:
                                                              Color(0xff246EB7),
                                                        ),
                                                        onTap: () {
                                                          //to novatigate for edit purpose
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      MakeToDo(
                                                                getCategoryCount,
                                                                true,
                                                                widget
                                                                    .userEmailAddressforID,
                                                                value
                                                                    .todos[
                                                                        index]
                                                                    .id,
                                                                value.todos[
                                                                    index],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      // This icon button is used to delete a single product
                                                      GestureDetector(
                                                        child: Icon(
                                                          Icons.delete,
                                                          color:
                                                              Color(0xffD37B6F),
                                                        ),
                                                        onTap: () {
                                                          String category =
                                                              value.todos[index]
                                                                  .category;
                                                          _deleteProduct(
                                                              value.todos[index]
                                                                  .id
                                                                  .toString(),
                                                              category);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              "Add New ToDos...!",
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakeToDo(
                getCategoryCount,
                false,
                widget.userEmailAddressforID,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
