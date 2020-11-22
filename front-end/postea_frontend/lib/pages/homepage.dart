import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postea_frontend/colors.dart';
import 'package:flutter/material.dart';
import 'package:postea_frontend/customWidgets/customNavBar.dart';
import 'package:postea_frontend/customWidgets/postTile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:postea_frontend/data_models/process_topic.dart';
//import 'package:postea_frontend/customWidgets/customAppBar.dart';
import 'package:postea_frontend/data_models/timer.dart';
import 'package:postea_frontend/main.dart';
import 'package:postea_frontend/pages/create_topic.dart';
import 'package:postea_frontend/pages/discoverTopics.dart';
import 'package:postea_frontend/pages/profile.dart';
import 'package:postea_frontend/pages/settingsPage.dart';
import 'package:postea_frontend/pages/trending.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:postea_frontend/customWidgets/topic_pill.dart';
import 'package:http/http.dart' as http;
import 'package:postea_frontend/data_models/process_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'topic.dart';
import 'settingsPage.dart';
import '../data_models/process_search.dart';

class HomePage extends StatefulWidget {
  int profileID;

  HomePage({@required this.profileID});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // File _postImage;

  var _scrollController = new ScrollController();
  var postTextController = new TextEditingController();
  var postTitleController = new TextEditingController();
  var checkPosScrollController = new ScrollController();
  var topicEditingController = new TextEditingController();
  var searchTextController = new TextEditingController();
  var topicButtonText = "Topic";
  bool checkBoxVal = false;
  bool checkEnd = false;
  File imgToUpload;
  String base64Image = "";
  ProcessTimeline timeLine;
  var isAnonymous = 0;
  Color isAnonColor = Colors.grey;
  var is_private = 0;
  var postID;
  var offset = 0;

  SharedPreferences pref;
  // var searchResults = [];

  ValueNotifier<int> searchNow = ValueNotifier<int>(0);

  _scrollListener() {
    // if (checkPosScrollController.offset <=
    //         checkPosScrollController.position.minScrollExtent &&
    //     !checkPosScrollController.position.outOfRange) {
    //   setState(() {
    //     offset = 0;
    //     print("Timeline refreshed");
    //     timeLine.clearTimeline();
    //   });
    // }

    if (checkPosScrollController.offset >=
            checkPosScrollController.position.maxScrollExtent / 2.0 &&
        !checkPosScrollController.position.outOfRange) {
      print("ISPOST" + timeLine.postRetrieved.toString());
      if (!timeLine.isEnd && timeLine.postRetrieved)
        setState(() {
          print("SETSTATE CALLED");
          offset = offset + 10;
          // updatePost();
        });
    }
  }

  @override
  // void dispose() {
  //   // TODO: implement dispose
  //   checkPosScrollController.dispose();
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    print("The profile ID is: " + widget.profileID.toString());
    timeLine = new ProcessTimeline(widget.profileID);
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   var timer = Provider.of<TimerCount>(context, listen: false);
    //   timer.changeVal();
    //  });
    checkPosScrollController.addListener(_scrollListener);
    //  setState(() {
    // offset = offset+3;
    // updatePost();
    //         });
    super.initState();
  }

  pickImage() async {
    // PickedFile img = await ImagePicker().getImage(source: ImageSource.gallery);
    imgToUpload = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(imgToUpload);
  }

  Future uploadImage(File file) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("post").child(postID.toString());
    await storageReference.putFile(file).onComplete;
    print("Uploaded image to Firebase");
  }

  void makePost() async {
    Random random = new Random();
    postID = (random.nextInt(10000000));
    var reqBody = {
      "postTitle": postTitleController.text,
      "msg": postTextController.text,
      "topic": topicEditingController.text,
      "img": base64Image == "" ? "0" : "1",
      "topicID": 21,
      "profileID": widget.profileID,
      "likes": 0,
      "dislikes": 0,
      "comment": 0,
      "anonymous": isAnonymous,
      "is_private": is_private,
      "postID": postID
    };
    var reqBodyJson = jsonEncode(reqBody);
    print("sending" + reqBodyJson);
    http
        .post("http://postea-server.herokuapp.com/post",
            headers: {"Content-Type": "application/json"}, body: reqBodyJson)
        .then((value) => print(value.body));
  }

  Future<http.Response> updatePost() async {
    await timeLine.setOffset(offset);
    return await timeLine.getPosts();
  }

  Future<http.Response> getSearchResults(String searchString) async {
    ProcessSearch processSearch = new ProcessSearch(searchString: searchString);
    print("hello before getting results");
    http.Response resp = await processSearch.getSearchResults();
    print("hello after getting results");
    print(resp.body.toString());
    return resp;
  }

  bool isTopicOwner(int topicID) {
    ProcessTopic processTopic = new ProcessTopic(topic_id: topicID);
    var topicInfo = processTopic.getTopicInfo();
    if (widget.profileID == topicInfo["topic_creator_id"]) {
      return true;
    } else {
      return false;
    }
  }

  initializeSharedPref() async {
    pref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    PageController pageController = new PageController(initialPage: 0);

    initializeSharedPref();

    return PageView(
      controller: pageController,
      children: [
        Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Text(
                      "Vidit Shah",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                  ),
                  decoration: BoxDecoration(color: Colors.purple[900]),
                ),
                ListTile(
                  title: Text("Settings"),
                  leading: Icon(
                    Icons.settings,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                  },
                ),
                ListTile(
                  title: Text("Logout"),
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    pref.clear().then((value) async {
                      if (value == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomNavBar(
            context,
            onTap: (value) {
              if (value == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Trending(profileId: widget.profileID)));
              } else if (value == 3) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CreateTopic(
                              profile_id: widget.profileID,
                            )));
                // MaterialPageRoute(
                //     builder: (_) => Topic(
                //           profileId: widget.profileID,
                //           isOwner: true,
                //           topicId: "21",
                //         )));
              } else if (value == 4) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CreateTopic(
                              profile_id: widget.profileID,
                            )));
              } else if (value == 1)
                // Making a post logic
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return WillPopScope(
                        onWillPop: () async {
                          postTitleController.clear();
                          postTextController.clear();
                          return true;
                        },
                        child: Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Container(
                            width: screenWidth / 1.1,
                            height: screenHeight / 1.8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 18, right: 18, top: 15),
                                    color: Colors.transparent,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Title",
                                      ),
                                      controller: postTitleController,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: SingleChildScrollView(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    scrollDirection: Axis.vertical,
                                    child: TextField(
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Post description"),
                                      controller: postTextController,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 13, right: 13),
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () async {
                                              await pickImage();
                                              // Image image = Image.file(imgToUpload);
                                              if (imgToUpload == null) {
                                                // final imgErrorSnackBar = SnackBar(content: Text('Image upload failed'));
                                                // Scaffold.of(context).showSnackBar(imgErrorSnackBar);
                                              }
                                              base64Image = base64Encode(
                                                  imgToUpload
                                                      .readAsBytesSync());
                                            }),
                                        IconButton(
                                            icon: Icon(
                                              Icons.attachment,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {}),
                                        IconButton(
                                            icon: Icon(
                                              Icons.fingerprint,
                                              color: isAnonColor,
                                            ),
                                            onPressed: () {
                                              if (isAnonymous == 0) {
                                                isAnonymous = 1;
                                                isAnonColor =
                                                    Colors.deepOrange[100];
                                              } else if (isAnonymous == 1) {
                                                isAnonymous = 0;
                                                isAnonColor = Colors.grey;
                                              }
                                              setState(() {});
                                              print(isAnonymous);
                                            }),
                                        IconButton(
                                          icon: Icon(
                                            CupertinoIcons.eye,
                                            size: 35,
                                          ),
                                          onPressed: () {},
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: 15),
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: screenHeight / 22,
                                              width: screenWidth / 4.5,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              child: ButtonTheme(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            17)),
                                                child: FlatButton(
                                                  onPressed: () => {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (context) {
                                                        return WillPopScope(
                                                            child: Dialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Container(
                                                                width:
                                                                    screenWidth /
                                                                        1.1,
                                                                height:
                                                                    screenHeight /
                                                                        7,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    TextField(
                                                                      controller:
                                                                          topicEditingController,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            InputBorder.none,
                                                                        hintText:
                                                                            "Enter a topic",
                                                                      ),
                                                                    ),
                                                                    ButtonTheme(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20)),
                                                                      child: RaisedButton(
                                                                          child: Text("Choose Topic"),
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              topicButtonText = topicEditingController.text;
                                                                              print(topicEditingController.text);
                                                                            });
                                                                            Navigator.of(context, rootNavigator: true).pop();
                                                                          }),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            onWillPop:
                                                                () async {
                                                              topicEditingController
                                                                  .clear();
                                                              return true;
                                                            });
                                                      },
                                                    )
                                                  },
                                                  child: Text(
                                                    topicButtonText,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Making a post request
                                      makePost();
                                      if (base64Image != "") {
                                        await uploadImage(imgToUpload);
                                      }

                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 13),
                                      alignment: Alignment.center,
                                      child: Text("Post"),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.5))),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
            },
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            // leading: Icon(Icons.menu),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 20,
                ),
                onPressed: () {
                  pageController.animateToPage(1,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.bounceInOut);
                },
              ),
              IconButton(
                  icon: Icon(
                    Icons.notifications,
                    size: 20,
                  ),
                  onPressed: () {}),
              IconButton(
                  icon: Icon(
                    Icons.account_circle,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Profile(
                              profileId: widget.profileID,
                              isOwner: true,
                            )));
                  }),
            ],
          ),
          backgroundColor: bgColor,
          body: Column(
            children: [
              Container(
                height: screenHeight / 15,
                width: screenWidth,
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    TopicPill(
                      topicId: 2,
                      col1: Colors.purple[900],
                      col2: Colors.purple[400],
                      height: screenHeight / 15,
                      width: screenWidth / 4,
                      profileId: widget.profileID,
                      isOwner: true,
                    ),
                    TopicPill(
                      topicId: 26894,
                      col1: Colors.green[700],
                      col2: Colors.lightGreen[400],
                      height: screenHeight / 15,
                      width: screenWidth / 4,
                      profileId: widget.profileID,
                      isOwner: true,
                    ),
                    TopicPill(
                      topicId: 51561,
                      col1: Colors.blue[700],
                      col2: Colors.lightBlueAccent[200],
                      height: screenHeight / 15,
                      width: screenWidth / 4,
                      profileId: widget.profileID,
                      isOwner: true,
                    ),
                    TopicPill(
                      topicId: 99841,
                      col1: Colors.red[700],
                      col2: Colors.pink[400],
                      height: screenHeight / 15,
                      width: screenWidth / 4,
                      profileId: widget.profileID,
                      isOwner: true,
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 15)),
              Expanded(
                child: FutureBuilder(
                    future: updatePost(),
                    builder: (BuildContext context,
                        AsyncSnapshot<http.Response> snapshot) {
                      if (snapshot.hasData) {
                        return RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: ListView.builder(
                              physics: BouncingScrollPhysics(),
                              controller: checkPosScrollController,
                              itemCount: timeLine.postList.length,
                              itemBuilder: (BuildContext context, int index) {
                                // if(timeLine.isEnd == true){
                                //   if(checkEnd)
                                //   return ListTile(
                                //     leading: Icon(Icons.error_outline),
                                //     title: Text("You have reached the end, my friend.", style: TextStyle(color: Colors.grey, fontSize: 15),),
                                //   );
                                //   if(index == timeLine.postList.length-1){
                                //     checkEnd = true;
                                //   }

                                // }
                                print("LIKES ARE: " +
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_likes);
                                return PostTile(
                                    timeLine.postList.elementAt(index).post_id,
                                    timeLine.postList
                                        .elementAt(index)
                                        .profile_id,
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_description,
                                    timeLine.postList.elementAt(index).topic_id,
                                    timeLine.postList.elementAt(index).post_img,
                                    timeLine.postList
                                        .elementAt(index)
                                        .creation_date,
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_likes,
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_dislikes,
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_comments,
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_title,
                                    timeLine.postList
                                        .elementAt(index)
                                        .post_name,
                                    widget.profileID.toString(),
                                    0);
                              }),
                        );
                      } else
                        return Center(
                            child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(bgGradEnd),
                        ));
                      // else return null;
                    }),
              )
            ],

            // child: Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Text("This timer is changing"),
            //     Consumer<TimerCount>(builder: (context, data, child){
            //       return AutoSizeText(
            //         data.getTime().toString(),
            //         style: TextStyle(fontSize: 15),
            //         );
            //     })
            //   ],

            // )
          ),
        ),
        Container(
          color: bgColor,
          child: Container(
            margin: EdgeInsets.only(top: 40, left: 10, right: 10),
            child: Column(
              children: [
                Material(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                          ),
                          onPressed: () {
                            pageController.animateToPage(0,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.bounceInOut);

                            searchTextController.clear();
                          }),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 7,
                          right: 18,
                        ),
                        child: Container(
                          width: screenWidth / 1.7,
                          height: screenHeight / 15,
                          child: TextField(
                            controller: searchTextController,
                            decoration: InputDecoration(
                                hintText: "Search", border: InputBorder.none),
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            searchNow.value += 1;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight / 1.2,
                  margin: EdgeInsets.only(top: 10),
                  child: ValueListenableBuilder(
                      valueListenable: searchNow,
                      builder: (_, value, __) {
                        if (value > 0) {
                          return FutureBuilder(
                              future:
                                  getSearchResults(searchTextController.text),
                              builder: (BuildContext context,
                                  AsyncSnapshot<http.Response> snapshot) {
                                if (snapshot.hasData) {
                                  List searchResults =
                                      jsonDecode(snapshot.data.body);

                                  print(searchResults);
                                  print("len of search results is " +
                                      searchResults.length.toString());
                                  return Material(
                                    child: ListView.builder(
                                      itemCount: searchResults.length,
                                      itemBuilder: (context, index) {
                                        print("index is " + index.toString());
                                        print("dict at index is " +
                                            searchResults[index].toString());
                                        if (searchResults[index] != null) {
                                          if (searchResults[index]['type'] ==
                                              "profile") {
                                            return ListTile(
                                              onTap: () {
                                                if (searchResults[index]
                                                        ['profile_id'] ==
                                                    widget.profileID) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Profile(
                                                        profileId:
                                                            searchResults[index]
                                                                ['profile_id'],
                                                        isOwner: true,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Profile(
                                                        profileId:
                                                            searchResults[index]
                                                                ['profile_id'],
                                                        isOwner: false,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    "https://picsum.photos/250?image=18"),
                                              ),
                                              title: Text(searchResults[index]
                                                      ['name']
                                                  .toString()),
                                              subtitle: Text(
                                                  searchResults[index]['type']
                                                      .toString()),
                                            );
                                          } else {
                                            return ListTile(
                                              onTap: () {
                                                if (true) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Topic(
                                                        profileId:
                                                            widget.profileID,
                                                        topicId:
                                                            searchResults[index]
                                                                ['topic_id'],
                                                        isOwner: true,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Topic(
                                                        profileId:
                                                            widget.profileID,
                                                        topicId:
                                                            searchResults[index]
                                                                ['topic_id'],
                                                        isOwner: false,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    "https://picsum.photos/250?image=18"),
                                              ),
                                              title: Text(searchResults[index]
                                                      ['topic_name']
                                                  .toString()),
                                              subtitle: Text(
                                                  searchResults[index]['type']
                                                      .toString()),
                                            );
                                          }
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  );
                                } else {
                                  if (searchTextController.text.isNotEmpty) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation(bgGradEnd),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              });
                        } else {
                          return Container();
                        }
                      }),
                  // ValueListenableBuilder(
                  //   valueListenable: searchNow,
                  //   builder: (_, value, __) {
                  //     return Container(
                  //       child: ListView.builder(
                  //           itemCount: searchResults.length,
                  //           itemBuilder: (context, index) {
                  //             return ListTile(
                  //               leading: Image(
                  //                   image: NetworkImage(
                  //                       "https://picsum.photos/250?image=18")),
                  //               title: searchResults[index]['name'],
                  //               subtitle: searchResults[index]['type'],
                  //             );
                  //           }),
                  //     );
                  //   },
                  // ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _handleRefresh() {
    Completer<Null> completer = new Completer<Null>();
    setState(() {
      offset = 0;
      print("Timeline refreshed");
      timeLine.clearTimeline();
    });
    completer.complete();
    return completer.future;
  }
}
