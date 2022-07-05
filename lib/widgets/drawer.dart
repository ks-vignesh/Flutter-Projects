import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/res/custom_colors.dart';
import 'package:todo_list_app/screens/sign_in_screen.dart';
import 'package:todo_list_app/screens/todo_list_home.dart';

import '../utils/authentication.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  late User _user;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  var userEmailAddress;
  var permissionStatus;
  late DrawerItems dashboardItem, manageSchoolItem, logout;

  @override
  void initState() {
    _user = widget._user;
    loadtheAvailableOptionsInDrawer();
    super.initState();
  }

  loadtheAvailableOptionsInDrawer() {
    dashboardItem = DrawerItems(
      text: 'TodoList Home',
      onTap: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToDoListHomePage(userEmailAddress, _user),
          ),
        );
      },
      divider: HorizontalLine(),
    );

    logout = new DrawerItems(
      text: 'Signout...!',
      onTap: () {
        showAlertDialog(context);
      },
      divider: HorizontalLine(),
    );
    setState(() {
      userEmailAddress = _user.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerItems> currentUserRoleFeatureList;
    List<DrawerItems> superAdmin = [
      dashboardItem,
      logout,
    ];

    currentUserRoleFeatureList = superAdmin;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _createHeader(),
          SizedBox(
            height: 10,
          ),
          Text(
            userEmailAddress.toString(),
            style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 20.0,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 40,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(25, 0, 0, 10),
              // margin: EdgeInsets.fromLTRB(15, 0, 0, 10),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: currentUserRoleFeatureList.map((data) {
                return GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        data.text,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: data.divider,
                      ),
                    ],
                  ),
                  onTap: data.onTap,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  //header
  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Container(
          height: 50,
          child: _user.photoURL != null
              ? ClipOval(
                  child: Material(
                    color: CustomColors.firebaseGrey.withOpacity(0.3),
                    child: Image.network(
                      _user.photoURL!,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                )
              : ClipOval(
                  child: Material(
                    color: CustomColors.firebaseGrey.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: CustomColors.firebaseGrey,
                      ),
                    ),
                  ),
                ),
        ));
  }

  //body
  Widget _createDrawerItem(
      {IconData? icon, String? text, GestureTapCallback? onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          // Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Text(text!),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  Widget HorizontalLine() {
    return SizedBox(
      height: 8.0,
      child: new Center(
        child: new Container(
          margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
          height: 1.0,
          color: Colors.black26,
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () async {
        await Future.delayed(Duration(seconds: 1));
        await Authentication.signOut(context: context);
        Navigator.of(context).pushReplacement(_routeToSignInScreen());
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Are you Sure want to Logout ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class DrawerItems {
  String text;
  GestureTapCallback onTap;
  Widget divider;

  DrawerItems({required this.text, required this.onTap, required this.divider});
}
