import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './login.dart';

class SecuritySettings extends StatefulWidget {
  @override
  _SecuritySettingsState createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  var passwordController = new TextEditingController();
  var newPasswordController = new TextEditingController();
  var confirmNewPasswordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: new AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Security",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Container(
          width: screenWidth,
          height: screenHeight,
          margin: EdgeInsets.only(left: 30, right: 15),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.lock),
                    ),
                    InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return WillPopScope(
                                    onWillPop: () async {
                                      passwordController.clear();
                                      newPasswordController.clear();
                                      confirmNewPasswordController.clear();
                                      return true;
                                    },
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                      child: Container(
                                        width: screenWidth / 3.5,
                                        height: screenHeight / 3.5,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15,
                                                  top: 10,
                                                  right: 25,
                                                  bottom: 10),
                                              child: TextField(
                                                controller:
                                                    newPasswordController,
                                                obscureText: true,
                                                autocorrect: false,
                                                enableSuggestions: false,
                                                textAlign: TextAlign.left,
                                                decoration: InputDecoration(
                                                    enabledBorder:
                                                        UnderlineInputBorder(),
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "Enter new password"),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15,
                                                  top: 10,
                                                  right: 25,
                                                  bottom: 10),
                                              child: TextField(
                                                controller:
                                                    confirmNewPasswordController,
                                                textAlign: TextAlign.left,
                                                autocorrect: false,
                                                enableSuggestions: false,
                                                obscureText: true,
                                                decoration: InputDecoration(
                                                    enabledBorder:
                                                        UnderlineInputBorder(),
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "Confirm new password"),
                                              ),
                                            ),
                                            ButtonTheme(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: RaisedButton(
                                                  child:
                                                      Text("Change Password"),
                                                  onPressed: () async {
                                                    String newPassword =
                                                        newPasswordController
                                                            .text;
                                                    String confirmNewPassword =
                                                        confirmNewPasswordController
                                                            .text;

                                                    if (newPassword ==
                                                        confirmNewPassword) {
                                                      User user = FirebaseAuth
                                                          .instance.currentUser;

                                                      try {
                                                        await user
                                                            .updatePassword(
                                                                newPassword);

                                                        Scaffold.of(context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              "Password updated successfully!"),
                                                        ));
                                                      } catch (e) {
                                                        print("e is " +
                                                            e.toString());

                                                        if (e.toString().contains(
                                                            "[firebase_auth/requires-recent-login]")) {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Login()));
                                                        }
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Text("Change Password",
                            style: TextStyle(fontSize: 20))),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.clear),
                    ),
                    Text("Clear Search History",
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
