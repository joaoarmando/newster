import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class NewsData {
  String objectId;
  String newsId;
  String title;
  String description;
  String thumbnail;
  String url;
  String mainTag;

  NewsData.fromJSON(Map<String,dynamic> _news,String _mainTag){
    title = _news["title"];
    description = _news["description"];
    thumbnail = _news["thumbnail"];
    url = _news["url"];
    mainTag = _mainTag;
  }


NewsData.fromParseObject({@required ParseObject news, String categoryName}){
    objectId = news.objectId;
    newsId = news.get('newsId');
    if (newsId == null) newsId = objectId;
    title = news.get("title");
    description = news.get("description");
    thumbnail = news.get("thumbnail");
    url = news.get("url");
    mainTag = categoryName;
  }

}