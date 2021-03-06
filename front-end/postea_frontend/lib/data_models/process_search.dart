import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProcessSearch {
  var searchString;
  List<String> results = new List();

  ProcessSearch({this.searchString});

  Future<http.Response> getSearchResults() async {
    String url =
        "http://postea-server.herokuapp.com/search?text=" + searchString;

    http.Response response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer posteaadmin",
      },
    );

    var searchResults = jsonDecode(response.body);

    print("response is " + searchResults.toString());

    return response;
  }
}
