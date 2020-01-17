import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:upnews/models/news.dart';

enum SavedState{LOADING,SAVED,UNSAVED}

class NewsScreenBloc extends BlocBase{

  final _savedStateController = BehaviorSubject<SavedState>();

  NewsData news;

  NewsScreenBloc(this.news);



 

  Stream<SavedState> get outSavedState => _savedStateController.stream;



  void checkSavedNews() async{
    _savedStateController.sink.add(SavedState.LOADING);

    ParseUser user = await ParseUser.currentUser();
    var queryBuilder = QueryBuilder(ParseObject("SavedNews"))
      ..whereEqualTo("owner", user)
      ..whereEqualTo("newsId",  news.newsId);
      
    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null) _savedStateController.sink.add(SavedState.SAVED);
      else _savedStateController.sink.add(SavedState.UNSAVED);
    }
    else _savedStateController.sink.add(SavedState.UNSAVED);

  }

  void saveNews() async{
    _savedStateController.sink.add(SavedState.LOADING);

    //VERIFICA SE O ITEM JÁ NÃO EXISTE PARA DEPOIS SALVAR
    ParseUser user = await ParseUser.currentUser();
    var queryBuilder = QueryBuilder(ParseObject("SavedNews"))
      ..whereEqualTo("owner", user)
      ..whereEqualTo("newsId", news.newsId);

    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.result != null) _savedStateController.sink.add(SavedState.SAVED);
      else _saveNews();
    }
    else _savedStateController.sink.add(SavedState.UNSAVED);

  }

  void _saveNews() async{
   ParseUser user = await ParseUser.currentUser();

    ParseObject savedNews = ParseObject("SavedNews")
      ..set("newsId", news.newsId)
      ..set("title", news.title)
      ..set("description", news.description)
      ..set("thumbnail", news.thumbnail)
      ..set("url", news.url)
      ..set("owner", user)
      ..setACL(ParseACL(owner: user));

      ParseResponse apiResponse = await savedNews.save();

      if (apiResponse.success) _savedStateController.sink.add(SavedState.SAVED);
      else {
        print(apiResponse.error);
        _savedStateController.sink.add(SavedState.UNSAVED);
      }
  }

  void unsaveNews() async{
    _savedStateController.sink.add(SavedState.LOADING);

    //VERIFICA SE O ITEM JÁ NÃO EXISTE PARA DEPOIS SALVAR
    ParseUser user = await ParseUser.currentUser();
    var queryBuilder = QueryBuilder(ParseObject("SavedNews"))
      ..whereEqualTo("owner", user)
      ..whereEqualTo("newsId", news.newsId)
      ..setLimit(1);

    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success){
      if (apiResponse.results != null) {
        ParseObject savedNews = apiResponse.results[0];
        ParseResponse deleteResponse = await savedNews.delete();
        if (deleteResponse.success) _savedStateController.sink.add(SavedState.UNSAVED);
        else _savedStateController.sink.add(SavedState.SAVED);
      }
      else _savedStateController.sink.add(SavedState.UNSAVED);
    }
    else _savedStateController.sink.add(SavedState.UNSAVED);

  }

  @override
  void dispose(){
    _savedStateController.close();
    super.dispose();
  }
}
