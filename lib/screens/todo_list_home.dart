import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/screens/todo_creation_edit.dart';
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

  String title = "";
  String category = "";
  String description = "";
  String time = "";
  int personalCount = 0;
  int businessCount = 0;

  @override
  void initState() {
    _toDos = FirebaseFirestore.instance.collection(
        Constants.FIREBASEDBNAME + '_' + widget.userEmailAddressforID);

    //geting the category counts to display in home page
    FirebaseFirestore.instance
        .collection(
            Constants.FIREBASEDBNAME + '_' + widget.userEmailAddressforID)
        .get()
        .then((val) {
      if (val.docs.length > 0) {
        for (int i = 0; i < val.docs.length; i++) {
          if (val.docs[i].get(Constants.CATEGORY) == Constants.BUSINESS) {
            businessCount++;
          } else {
            personalCount++;
          }
        }
        setState(() {});
      } else {
        print("No Data Found");
      }
    });
    super.initState();
  }

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([
    DocumentSnapshot? documentSnapshot,
    String? title,
    String? description,
    String? category,
    String? time,
  ]) async {
    String action = Constants.CREATE;
    this.title = title!;
    this.description = description!;
    this.category = category!;
    this.time = time.toString();
    if (documentSnapshot != null) {
      action = Constants.UPDATE;
    }
    if (title != null && description != null) {
      if (action == 'create') {
        // Persist a new product to Firestore
        await _toDos.add({
          Constants.TITLE: title,
          Constants.DESCRIPTION: description,
          Constants.CATEGORY: category,
          Constants.TIME: time,
        });

        //getting add todo category
        if (category == Constants.BUSINESS) {
          businessCount++;
        } else {
          personalCount++;
        }
        setState(() {});
      }

      if (action == 'update') {
        // Update the product
        await _toDos.doc(documentSnapshot!.id).update({
          Constants.TITLE: title,
          Constants.DESCRIPTION: description,
          Constants.CATEGORY: category,
          Constants.TIME: time,
        });
        if (category == Constants.BUSINESS) {
          businessCount++;
          personalCount--;
        } else {
          personalCount++;
          businessCount--;
        }
        setState(() {});
      }
    }
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId, String Category) async {
    await _toDos.doc(productId).delete();

    // Show a snackbar
    CommonFunction.showSnackBarWidget(
        'Todo Item Deleted Successfully.', context);
    /*   ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todo Item Deleted Successfully.'),
      ),
    );*/

    //removing the count in home screen
    if (Category == Constants.BUSINESS) {
      businessCount--;
    } else {
      personalCount--;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using StreamBuilder to display all products from Firestore in real-time
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      key: scaffoldKey,
      drawer: NavigationDrawer(user: widget.user),
      body: Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
              child: Row(
                children: [
                  Container(
                    child: Column(
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
                          height: 35,
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
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
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
                                  fontSize: 20,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
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
                                  fontSize: 20,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/todo_home.jpg'),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
              child: new Center(
                child: new Container(
                  margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
                  height: 4.0,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 10, 10, 5),
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
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              height: MediaQuery.of(context).size.height * 0.58,
              child: StreamBuilder(
                stream: _toDos.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData) {
                    return streamSnapshot.data!.docs.length > 0
                        ? ListView.builder(
                            itemCount: streamSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot documentSnapshot =
                                  streamSnapshot.data!.docs[index];
                              return Card(
                                //elevation: 5,
                                margin: const EdgeInsets.fromLTRB(5, 2, 5, 0),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  color: Colors.white,
                                  height: 95,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                      documentSnapshot[
                                                          Constants.TITLE],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                  documentSnapshot[
                                                          Constants.TIME]
                                                      .toString()
                                                      .split(" ")[1],
                                                  style: TextStyle(
                                                    fontFamily: "Barlow",
                                                    fontSize: 16,
                                                    color: Colors.grey.shade400,
                                                    fontWeight: FontWeight.w300,
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
                                                      documentSnapshot[Constants
                                                          .DESCRIPTION],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                            builder: (context) =>
                                                                MakeToDo(
                                                                    _createOrUpdate,
                                                                    true,
                                                                    documentSnapshot),
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
                                                            documentSnapshot[
                                                                Constants
                                                                    .CATEGORY];
                                                        _deleteProduct(
                                                            documentSnapshot.id,
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
                  }
                  return const Center(
                    child: Text("No Data Found"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakeToDo(_createOrUpdate, false),
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
