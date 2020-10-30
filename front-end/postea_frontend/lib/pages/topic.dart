import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:postea_frontend/customWidgets/postTile.dart';
import 'package:postea_frontend/main.dart';
import 'package:postea_frontend/data_models/process_topic.dart';

import '../colors.dart';

class Topic extends StatefulWidget {

  var profileId;
  var isOwner;
  var topicId;
  Topic({this.profileId, this.isOwner, this.topicId});
  @override
  _TopicState createState() => _TopicState();
}



class _TopicState extends State<Topic> {

  var offset = 0;
  var checkPosScrollController = new ScrollController();

  _scrollListener() {
    if (checkPosScrollController.offset <=
            checkPosScrollController.position.minScrollExtent &&
        !checkPosScrollController.position.outOfRange) {
      setState(() {
        offset = 0;
        print("Timeline refreshed");
        topic.clearTimeline();       
      });
    }

    if (checkPosScrollController.offset >=
            checkPosScrollController.position.maxScrollExtent &&
        !checkPosScrollController.position.outOfRange) {
      print("ISPOST" + topic.postRetrieved.toString());
      if (!topic.isEnd && topic.postRetrieved)
        setState(() {
          print("SETSTATE CALLED");
          offset = offset + 3;
          // updatePost();
        });
    }
  }
  ProcessTopic topic;
  Map<String, dynamic> topicInfo;

  getTopicInfo() async {
    topic.getTopicInfo().then((value){
      topicInfo = value;
      print(topicInfo);
    });
  }

  Future<Response> getTopicContent() async {
    await topic.setOffset(offset);
    return await topic.getPosts();
  }

  @override void initState() {
    // TODO: implement initState
    topic = new ProcessTopic(profile_id: widget.profileId, topic_id: int.parse(widget.topicId));
    topicInfo = {
      "name": "",
      "desc": ""
    };
    getTopicInfo();
    setState(() {
    });
    // getTopicContent();
    checkPosScrollController.addListener(_scrollListener);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.greenAccent,
                alignment: Alignment.center,
                child: Text("Image Here"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  topicInfo['name'],
                  style: TextStyle(fontSize: 20),
                ),
              )
            ),
            Expanded(
              flex: 1,
              child: Card(
                // margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                clipBehavior: Clip.hardEdge,
                elevation: 0,
                child: Container(
                  width: screenWidth,
                  child: SingleChildScrollView(
                    child: Text(topicInfo['desc'])
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              // child: Container(
              //   // color: Colors.limeAccent,
              //   child: ListView(
              //     addRepaintBoundaries: false,
              //     shrinkWrap: true,
              //     padding: EdgeInsets.all(0),
              //     children: [
              //       Container(height: screenHeight/3, width: screenWidth, color: Colors.grey,),
              //       Container(height: screenHeight/3, width: screenWidth, color: Colors.pinkAccent,),
              //       Container(height: screenHeight/3, width: screenWidth, color: Colors.orangeAccent,),
              //       Container(height: screenHeight/3, width: screenWidth, color: Colors.yellowAccent,),
              //       Container(height: screenHeight/3, width: screenWidth, color: Colors.blueAccent,)
              //     ],
              //   ),
              // )
              child: FutureBuilder(
                future: getTopicContent(),
                builder: (context,AsyncSnapshot snapshot) {
                  if(snapshot.hasData)
                  return ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: BouncingScrollPhysics(),
                    controller: checkPosScrollController,
                    itemCount: topic.postList.length,
                    itemBuilder: (context, index) {

                      return PostTile(
                            topic.postList.elementAt(index).post_id,
                            topic.postList.elementAt(index).profile_id,
                            topic.postList.elementAt(index).post_description,
                            topic.postList.elementAt(index).topic_id,
                            topic.postList.elementAt(index).post_img,
                            topic.postList.elementAt(index).creation_date,
                            topic.postList.elementAt(index).post_likes,
                            topic.postList.elementAt(index).post_dislikes,
                            topic.postList.elementAt(index).post_comments,
                            topic.postList.elementAt(index).post_title,
                            topic.postList.elementAt(index).post_name,
                            widget.profileId.toString()
                          );
                      
                    },
                  );
                  else
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(bgGradEnd),
                    ));
                },
              ),
            )
          ],
        ),
      ),
      
    );
  }
}