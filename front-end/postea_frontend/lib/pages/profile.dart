import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:postea_frontend/colors.dart';
import 'package:postea_frontend/data_models/process_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:postea_frontend/pages/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  int profileId;
  bool isOwner;
  Profile({this.profileId, this.isOwner});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var name = "";
  var bio_data = "";
  bool isPrivate = false;
  Map<String, dynamic> profile;
  SharedPreferences prefs;
  String username;

  var _nameController = TextEditingController();
  var _biodataController = TextEditingController();
  int _value;
  PageController controller = PageController(initialPage: 0);
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // displayImage();
    _value=0;
    getProfile();
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  updateProfile() async {
    var sendAnswer = JsonEncoder().convert({
      "original_username": username,
      "update_privateAcc": isPrivate.toString(),
      "update_name": name,
      "update_biodata": bio_data,
      "update_profilePic": "random"
    });

    http.Response resp = await http.post(
        "http://postea-server.herokuapp.com/profile",
        headers: {'Content-Type': 'application/json'},
        body: sendAnswer);
    print(resp.body);
    if (resp.statusCode == 200)
      print("success");
    else
      print("Some error");
  }

  getProfile() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? "";
    print(username);
    http.Response resp = await http
        .get("http://postea-server.herokuapp.com/profile?username="+username.toString());
    profile = jsonDecode(resp.body);
    setState(() {
      _nameController.text = profile["message"]["name"];
      name = _nameController.text;
      _biodataController.text = profile["message"]["biodata"];
      bio_data = _biodataController.text;
      isPrivate =
          profile["message"]["privacy"].toString().toLowerCase() == "true";
    });

    print(profile["message"]["profile_id"]);
  }

  // displayImage() {
  //   Uint8List pic;
  //   StorageReference profilePic =
  //       FirebaseStorage.instance.ref().child("profile");

  //   var url = profilePic.child("tom_and_jerry.jpeg").getDownloadURL();
  //   print("url: " + url.toString());
  // }
  var isFollow = false;
  var buttonColor = Colors.red[50];
  var followButtonText = "Follow";
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    
    

    // displayImage();

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          widget.isOwner? IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.black,
            ),
            onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: Offset(0,-1), end: Offset(0,0)).animate(CurvedAnimation(parent: animation, curve: Curves.decelerate)), child: child,));
                    },
                    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secAnimation) {
                      return EditProfile(nameText: name, biodata: bio_data, privacy: isPrivate, username: username,);
                    },
                  )
                  );

            },
          ):Container()
        ],
      ),
      body: SafeArea(
        child: PageView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  // height: screenHeight / 4,
                  width: screenWidth,
                  color: Colors.transparent,
                  // padding: EdgeInsets.only(top: screenHeight / 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: screenWidth / 4,
                              width: screenWidth / 4,
                              decoration: ShapeDecoration(
                                  shape: CircleBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.blueGrey))),
                              child: FutureBuilder(
                                future: FirebaseStorageService.getImage(context, "tom_and_jerry.jpeg"),
                                builder: (context, AsyncSnapshot<dynamic> snapshot){

                                  if(snapshot.hasData){

                                    return CircleAvatar(
                                    backgroundImage: NetworkImage(snapshot.data),
                                    maxRadius: screenWidth / 8,
                                );
                                  }
                                  else{
                                    return CircularProgressIndicator(
                                      strokeWidth: 2,
                                      backgroundColor: bgColor,
                                      valueColor: AlwaysStoppedAnimation(loginButtonEnd),
                                    );
                                    
                                  }
                                  
                                }
                                
                              ),
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    name,
                                    maxFontSize: 29,
                                    minFontSize: 27,
                                    softWrap: true,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          bottom: screenHeight / 40)),
                                  IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Followers",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text("4.5k")
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth / 25)),
                                        Container(
                                          // height: 20,
                                          width: 0.5,
                                          color: Colors.blueGrey,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: screenWidth / 25)),
                                        Column(
                                          children: [
                                            Text(
                                              "Following",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text("4.4k")
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ]),
                          ],
                        ),
                      ),
                      // Profile circle
                      SizedBox(
                        height: screenHeight / 25,
                      ),
                      widget.isOwner == false ? Container(
                        height: screenHeight/14,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth/15, vertical: 10),
                        child: ButtonTheme(
                          buttonColor: buttonColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minWidth: screenWidth/1.5,
                          child: RaisedButton(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            child: Text(followButtonText),
                            onPressed: (){
                              print(isFollow);
                              setState(() {
                                if(isFollow){
                                buttonColor = Colors.red[50];
                                isFollow = false;
                                followButtonText = "Follow";
                              }
                              else{
                                print("HERE");
                                buttonColor = Colors.redAccent[100];
                                isFollow = true;
                                followButtonText = "Following";
                              }   
                                
                              });
                                
                            })
                            ),
                        ): Container(),
                      
                      // Follow & Following Buttons
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: <Widget>[
                          // Follower button
                            // Stack(
                            //   alignment: Alignment.centerRight,
                            //   children: [
                            //     ButtonTheme(
                            //       padding: EdgeInsets.only(right: 40),
                            //       height: 50,
                            //       minWidth: screenWidth / 2.5,
                            //       child: RaisedButton(
                            //         color: profileButtoColor,
                            //         onPressed: () {},
                            //         child: Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceAround,
                            //             children: [
                            //               // IconButton(
                            //               //     icon: Icon(Icons.add), onPressed: () {}),
                            //               Text("Followers")
                            //             ]),
                            //         elevation: 0,
                            //         shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(100),
                            //             side: BorderSide(color: Colors.transparent)),
                            //       ),
                            //     ),
                            //     ButtonTheme(
                            //       height: 55,
                            //       minWidth: screenWidth / 7,
                            //       child: RaisedButton(
                            //         color: ffDisplayer,
                            //         onPressed: () {},
                            //         child: Text("4.2k"),
                            //         elevation: 6,
                            //         shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.only(
                            //                 topLeft: Radius.zero,
                            //                 bottomLeft: Radius.zero,
                            //                 topRight: Radius.circular(100),
                            //                 bottomRight: Radius.circular(100)),
                            //             side: BorderSide(color: Colors.black12)),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            // Stack(
                            //   alignment: Alignment.centerRight,
                            //   children: [
                            //     ButtonTheme(
                            //       padding: EdgeInsets.only(right: 40),
                            //       height: 50,
                            //       minWidth: screenWidth / 2.6,
                            //       child: RaisedButton(
                            //         color: profileButtoColor,
                            //         onPressed: () {},
                            //         child: Text(
                            //           "Following",
                            //         ),
                            //         elevation: 0,
                            //         shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(100),
                            //             side: BorderSide(color: Colors.transparent)),
                            //       ),
                            //     ),
                            //     ButtonTheme(
                            //       height: 55,
                            //       minWidth: screenWidth / 7,
                            //       child: RaisedButton(
                            //         color: ffDisplayer,
                            //         onPressed: () {},
                            //         child: Text("6.5k"),
                            //         elevation: 6,
                            //         shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.only(
                            //                 topLeft: Radius.zero,
                            //                 bottomLeft: Radius.zero,
                            //                 topRight: Radius.circular(100),
                            //                 bottomRight: Radius.circular(100)),
                            //             side: BorderSide(color: Colors.black12)),
                            //       ),
                            //     )
                            //   ],
                            // ),
                      //   ],
                      // )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    // height: screenHeight / 1.6,
                    width: screenWidth,
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.red[50],
                              border: Border.all(color: Colors.black12)),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.red[100],
                                buttonTheme: ButtonTheme.of(context).copyWith(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50.0)
                                    ),
                                    alignedDropdown:true
                                  )
                                ),
                              child: DropdownButton(
                                isExpanded: true,
                                underline: SizedBox(),
                                icon: null,
                                value: _value,
                                items: [
                                  DropdownMenuItem(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Container(
                                        child: Text("About"),
                                      ),
                                    ),
                                    value: 0,
                                  ),
                                  DropdownMenuItem(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Container(
                                        child: Text("Posts"),
                                      ),
                                    ),
                                    value: 1,
                                  ),
                                  DropdownMenuItem(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Container(
                                        child: Text("Topics"),
                                      ),
                                    ),
                                    value: 2,
                                  ),
                                  

                                ], 
                              onChanged: (num value) {
                              setState(() {
                              _value = value;
                              });
                              controller.animateToPage(
                                _value,
                                duration: Duration(milliseconds: 150),
                                curve: Curves.decelerate
                              );
                                print(controller.page);
                              }
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            // height: screenHeight / 1.8,
                            color: Colors.transparent,
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                    elevation: 1,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        child: Text(bio_data),
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Container(
                //   height: screenHeight/3,
                //   width: screenWidth,
                //   color: Colors.yellowAccent,
                // ),
              ]),
              // Posts page
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'dmenu',
                    child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.red[50],
                                border: Border.all(color: Colors.black12)),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.red[100],
                                  buttonTheme: ButtonTheme.of(context).copyWith(
                                    alignedDropdown:true
                                  )
                                  ),
                                child: DropdownButton(
                                  isDense: false,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  icon: null,
                                  value: _value,
                                  items: [
                                    DropdownMenuItem(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Container(
                                          child: Text("About"),
                                        ),
                                      ),
                                      value: 0,
                                    ),
                                    DropdownMenuItem(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Container(
                                          child: Text("Posts"),
                                        ),
                                      ),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Container(
                                          child: Text("Topics"),
                                        ),
                                      ),
                                      value: 2,
                                    ),
                                    

                                  ], 
                                onChanged: (num value) {
                                setState(() {
                                _value = value;
                                controller.animateToPage(
                                  _value,
                                  duration: Duration(milliseconds: 150),
                                  curve: Curves.decelerate
                                  );
                                print(value);
                                });
                                // print(value);
                                
                                }
                                ),
                              ),
                            ),
                          ),
                  ),
                        Expanded(
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                    elevation: 1,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        child: Text(bio_data),
                                      ),
                                    )
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                    elevation: 1,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        child: Text(bio_data),
                                      ),
                                    )
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                    elevation: 1,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        child: Text(bio_data),
                                      ),
                                    )
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                    elevation: 1,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        child: Text(bio_data),
                                      ),
                                    )
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                                    elevation: 1,
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        child: Text(bio_data),
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                ],
              )
              ]
        ),
      ),
    );
  }
}

class FirebaseStorageService extends ChangeNotifier {
  FirebaseStorageService();
  static Future<dynamic> getImage(BuildContext context, String image) async {
    return await FirebaseStorage.instance.ref().child("profile").child(image).getDownloadURL();
  }
}
