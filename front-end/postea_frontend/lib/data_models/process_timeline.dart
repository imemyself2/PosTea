import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post.dart';

class ProcessTimeline{

  List<Post> postList = [];
  var offset = 0;
  var temp;
  int profile_id;
  Map<String, dynamic> posts;

  ProcessTimeline(this.profile_id);

  Future<http.Response> getPosts() async {

    var url = "http://postea-server.herokuapp.com/refreshTimeline?profile_id="+profile_id.toString()+"&post_offset="+offset.toString();
    http.Response resp = await http.get(url);
    posts = jsonDecode(resp.body);
    print("OFFSET IS: "+offset.toString());
    processPosts();
    // print(resp.body);
    return resp;
  }

  processPosts() {

    for(int i = 0; i < posts['result'].length; i++){

      Post newPost = Post(
        posts['result'][i]['post_id'].toString(),
        posts['result'][i]['profile_id'].toString(),
        posts['result'][i]['post_description'].toString(),
        posts['result'][i]['topic_id'].toString(),
        posts['result'][i]['post_img'].toString(),
        posts['result'][i]['creation_date'].toString(),
        posts['result'][i]['post_likes'].toString(),
        posts['result'][i]['post_dislikes'].toString(),
        posts['result'][i]['post_comments'].toString(),
        posts['result'][i]['post_title'].toString()
      );
      print(posts['result'][i]);
      postList.add(newPost);

    }
    print(postList.length);
    
  }

  setOffset(offset){

    this.offset = offset;

  }

}