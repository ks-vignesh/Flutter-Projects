import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/res/custom_colors.dart';
import 'package:todo_list_app/screens/todo_creation_edit.dart';
import 'package:todo_list_app/utils/Constants.dart';
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
      }
    }
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId, String Category) async {
    await _toDos.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted')));

    //removing the count in home screen
    if (Category == Constants.BUSINESS) {
      businessCount--;
    } else {
      personalCount--;
    }
    setState(() {
      businessCount = businessCount;
      personalCount = personalCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using StreamBuilder to display all products from Firestore in real-time
      backgroundColor: Colors.white,
      key: scaffoldKey,
      drawer: NavigationDrawer(user: widget.user),
      body: Container(
        // padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              //margin: EdgeInsets.fromLTRB(15, 0, 0, bottom),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: 30,
                            color: Colors.white,
                          ),
                          // alignment: Alignment.topRight,
                          onPressed: () {
                            scaffoldKey.currentState!.openDrawer();
                          }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  Your',
                          style: TextStyle(
                            fontSize: 34,
                            color: Colors.white60,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  Things',
                          style: TextStyle(
                            fontSize: 34,
                            color: Colors.white60,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                personalCount.toString(),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                'Personal',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                businessCount.toString(),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                'Business',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.normal,
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
                borderRadius: BorderRadius.circular(5),
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
              margin: EdgeInsets.fromLTRB(25, 10, 10, 5),
              alignment: Alignment.centerLeft,
              child: Text(
                "INBOX",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Container(
                                  color: Colors.white,
                                  height: 110,
                                  child: Row(
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipOval(
                                        child: Material(
                                          color: Colors.grey,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Icon(
                                              Icons.wysiwyg_rounded,
                                              size: 30,
                                              color: CustomColors.firebaseGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            documentSnapshot[Constants.TITLE],
                                            style: TextStyle(
                                              fontSize: 26,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          new Container(
                                            width: 140,
                                            child: Row(
                                              children: <Widget>[
                                                Flexible(
                                                  child: new Text(
                                                    documentSnapshot[
                                                        Constants.DESCRIPTION],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            documentSnapshot[Constants.TIME]
                                                .toString()
                                                .split(" ")[1],
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
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
                                                  }),
                                              // This icon button is used to delete a single product
                                              IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.grey,
                                                  ),
                                                  onPressed: () {
                                                    String category =
                                                        documentSnapshot[
                                                            Constants.CATEGORY];
                                                    _deleteProduct(
                                                        documentSnapshot.id,
                                                        category);
                                                  }),
                                            ],
                                          ),
                                        ],
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
        //onPressed: () => _createOrUpdate(),
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
