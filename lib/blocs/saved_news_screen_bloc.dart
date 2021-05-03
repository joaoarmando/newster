import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:upnews/models/news.dart';
import 'package:upnews/utils.dart';


class SavedNewsBloc extends BlocBase {
  
  final _refreshCourseListController = BehaviorSubject<LoadingCoursesState>();

  final _coursesController = BehaviorSubject<Map<String,dynamic>>();

  Stream<Map<String,dynamic>> get outCourses => _coursesController.stream;
  Stream<LoadingCoursesState> get outCourseListRefresh => _refreshCourseListController.stream;
  List<String> savedCourses = [];
  Map<String,dynamic> savedNews;
  double positionList; 


  void nextPage(){
    getNews(true);
  }



  void tryAgainNextPage(){
   // _coursesController.sink.add(getNewsCache());
  }



  void getNews(bool nextPage) async{
    ParseUser user = await ParseUser.currentUser();



    if (!nextPage) {
        _refreshCourseListController.sink.add(LoadingCoursesState.LOADING);
        bool isConnected = await hasInternetConnection(true); // <= ISSO NÃO FUNCIONA NO FLUTTER WEB
        if (!isConnected){
          _refreshCourseListController.sink.add(LoadingCoursesState.NO_INTERNET_CONNECTION);
          return null;
        }
    }
 

   

    if (!nextPage) _refreshCourseListController.sink.add(LoadingCoursesState.SUCCESS);
    var queryBuilder = QueryBuilder(ParseObject('SavedNews'))..setLimit(10)..orderByDescending("createdAt");

    if (nextPage) queryBuilder.setAmountToSkip(savedNews["news"].length);

    queryBuilder.whereEqualTo("owner",user);
    
    
    List<NewsData> newsList = [];
    

    var apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null){
        //Há noticias
        for (var news in apiResponse.result){
          print(news);
          newsList.add(NewsData.fromParseObject(news: news));
        }
      }
      
      bool hasMoreNews = newsList.length > 9;

      if (savedNews == null){
        savedNews = {
          "news":newsList, 
          "hasMore":hasMoreNews,
          "canAnimate":true,
        };
        
      }else {
        savedNews["news"].addAll(newsList);
        savedNews["hasMore"] = hasMoreNews;
        savedNews["canAnimate"] = false;
        savedNews["country"] = country;
      }

      if(!nextPage) _refreshCourseListController.sink.add(LoadingCoursesState.IDLE);
      _coursesController.sink.add(savedNews);

    } 
    return null;    
  }

  int getNewsIndex(String objectId,List<NewsData> newsList){
    for (var i = 0; i < newsList.length; i++){
      if (newsList[i].objectId == objectId){
          return i;
      }
    }
    return -1;
  }
  
  void retryLoad(){
    getNews(false);
  }


  


  void dispose(){
    _refreshCourseListController.close();
    _coursesController.close();
    super.dispose();
  }
}