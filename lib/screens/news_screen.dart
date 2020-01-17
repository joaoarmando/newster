import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:upnews/blocs/news_screen_bloc.dart';
import 'package:upnews/blocs/user_bloc.dart';
import 'package:upnews/generated/i18n.dart';
import 'package:upnews/models/news.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../app_theme.dart';
import 'package:upnews/widgets/custom_dialog.dart' as customDialog;

class NewsScreen extends StatefulWidget {
  final NewsData news;
  NewsScreen(this.news);
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
   NewsScreenBloc _newsScreenBloc;
  final UserBloc _userBloc = BlocProvider.getBloc();

  @override
  void initState() {
     _newsScreenBloc =  NewsScreenBloc(widget.news);
     _newsScreenBloc.checkSavedNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //return Container();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(widget.news.title,
          style: newsTitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          _buildSaveButton()
        ],
      ),
      body: WebView(
          initialUrl: widget.news.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ),
      floatingActionButton: _buildShareNewsButton(),
    ); 
  }



  Widget _buildShareNewsButton() {
   // return Container();
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return Material(
              type: MaterialType.transparency,
              child: Container(
                alignment: Alignment.center,
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradientAccent,
                  boxShadow: [
                    BoxShadow(
                      color: secondaryAccent.withOpacity(.2),
                      blurRadius: 5,
                      spreadRadius: 3,
                      offset: Offset(1, 1)
                    )
                  ]
                ),
                child: Material(
                  type: MaterialType.transparency,
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Share.share("${widget.news.title}\n${widget.news.url}\n #NewsterAPP"),
                    borderRadius: BorderRadius.circular(999),
                    splashColor: splashColor,
                    child: SizedBox(height:56,width:56, child: Icon(Icons.share, color: primaryText))
                  ),
                ),
              ),
            );
          }
          return Container();
        }); 
  }
  
  Widget _buildSaveButton(){
    return StreamBuilder<SavedState>(
      stream: _newsScreenBloc.outSavedState,
      builder: (context,snapshot){
        if (!snapshot.hasData) return Container();
        else if (snapshot.data == SavedState.LOADING){
          return Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            child: SizedBox(width:20, height:20,child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(secondaryAccent.withOpacity(.5)),strokeWidth: 1,)),
          );
        }
        else {
          bool saved = snapshot.data == SavedState.SAVED;
          return IconButton(
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
              onPressed: (){
                if (_userBloc.user != null){
                   saved ? _newsScreenBloc.unsaveNews() : _newsScreenBloc.saveNews();
                }
                else {
                  //mostra dialog login necessário
                  showDialogNeedLogin(context);
                }
               
              }
            );
        }
      },
    );
  }

   void showDialogNeedLogin(BuildContext context) async{

     return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return customDialog.AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                 color: secondaryBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(S.of(context).login,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(S.of(context).you_need_log_in_to_save_news,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        child: Text(S.of(context).cancel,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 18
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text(S.of(context).login,
                          style: TextStyle(
                            color: secondaryAccent,
                            fontSize: 18
                          ),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/loginScreen");
                          
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

          );
        },
      );

  }

}


