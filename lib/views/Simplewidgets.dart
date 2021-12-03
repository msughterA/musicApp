import 'package:audio_service/audio_service.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'musicPlayer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rxdart/rxdart.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main(){

}

Widget appBar(){
  return new AppBar(leading: new IconButton(icon: Icon(Icons.menu,color: Colors.black,), onPressed: (){})
  ,actions: <Widget>[Icon(Icons.search,size: 30,color: Colors.black,),new SizedBox(width: 10.0,)],
  elevation:0,backgroundColor: Colors.white,);
}

class myBottomNavBar extends StatefulWidget {
  final Function tabFunction;
  final int indeX;
  final songs;
  final playlist;
  myBottomNavBar({this.tabFunction,this.indeX,this.songs,this.playlist});
  @override
  bottomState createState()=>bottomState();
}
class bottomState extends State<myBottomNavBar>{

  List<MediaItem> _qeue=[];
  @override

  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    double height=160.0;
    // TODO: implement build
    return new StreamBuilder<ScreenState>(
      stream:_screenStateStream,
        builder: (context,snapshot){
        final screenState=snapshot.data;
        final qeue=screenState?.queue;
        final mediaItem=screenState?.mediaItem;
        final playbackState=screenState?.playbackState;
        final state=screenState?.playbackState;
        final processingState=playbackState?.processingState??
          AudioProcessingState.none;
        final playing = state?.playing ?? false;
      return new Container(
        width: size.width,
        height: height,
        child: Column(
          children: <Widget>[
            new Container(height:height*0.5,
              child: new Row(children: <Widget>[
                new SizedBox(width: 10,),
                 if(processingState==AudioProcessingState.none)...[
                   SizedBox(width: size.width*0.7,
                   child: new  AutoSizeText('Play a song from your playlist',style: new TextStyle(fontSize: 2,color: Colors.white),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),),
                   IconButton(icon: Icon(Icons.play_arrow,color: Colors.white,),
                   onPressed: (){
                     audioPlayerButton();
                     currentMediaItem=mediaItem;
                     isPlaying=true;
                   },)

                 ]else...[
                   new Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       SizedBox(
                           height:size.height*0.05,
                           width: size.width*0.5,
                           child:  new Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               AutoSizeText(mediaItem?.title==null?'':mediaItem.title,style: new TextStyle(fontSize: 2,fontWeight: FontWeight.bold,color: Colors.white),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                               AutoSizeText(mediaItem?.artist==null?'':mediaItem.artist,style: new TextStyle(fontSize: 2,color: Colors.white),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ],)
                       ),

                     ],
                   ),
                   new Container(
                     padding: EdgeInsets.only(left: size.width*0.05),
                     child: new Row(children: <Widget>[
                       new IconButton(icon: Icon(Icons.skip_previous,color: Colors.white,), onPressed: (){
                           setState(() {
                             if(mediaItem==qeue.first){
                               AudioService.skipToQueueItem(qeue.last.id);
                               print('HERE I AM');
                             }
                             else{
                               AudioService.skipToPrevious();
                               if(!playing){
                                 AudioService.play();
                               }
                             }
                           });
                       }),
                       new IconButton(icon:playing?Icon(Icons.pause,color: Colors.white,):Icon(Icons.play_arrow,color: Colors.white,), onPressed: (){
                         if(playing){
                           setState(() {
                             AudioService.pause();

                           });
                         }
                         else{
                           setState(() {
                             AudioService.play();
                           });
                         }
                       }),
                       new IconButton(icon: Icon(Icons.skip_next,color: Colors.white,), onPressed:(){
                         if(mediaItem==qeue.last){
                           AudioService.skipToQueueItem(qeue.first.id);
                         }
                         else{
                           AudioService.skipToNext();
                           if(!playing){
                             AudioService.play();
                           }
                         }
                       })
                     ],),
                   )
                 ]
              ],),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))),),
            new CurvedNavigationBar(
                index: widget.indeX,
                onTap: (int index){
                  widget.tabFunction(index);
                  //controller.index=index;
                  //return index;
                },
                height: 60,
                animationDuration: Duration(milliseconds: 200),
                animationCurve: Curves.bounceIn,
                backgroundColor: Colors.redAccent,
                items: <Widget>[
                  new GestureDetector(child: new Container(
                    width: 35,
                    height: 35,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.music_note,color: Colors.black,size: 20,),
                        new Text('songs',style: new TextStyle(fontSize: 10),)
                      ],),
                  ),),
                  new GestureDetector(child: new Container(
                    width: 35,
                    height: 35,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.cloud,color: Colors.black,size: 20,),
                        new Text('find',style: new TextStyle(fontSize: 10),)
                      ],),
                  ),),
                  new GestureDetector(child: new Container(
                    width: 35,
                    height: 35,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.favorite,color: Colors.black,size: 20,),
                        new Text('for you',style: new TextStyle(fontSize: 10),),
                      ],),
                  ),),
                  new GestureDetector(child: new Container(
                    width: 35,
                    height: 35,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.playlist_play,color: Colors.black,size: 20,),
                        new Text('playlist',style: new TextStyle(fontSize: 10),)
                      ],),
                  ),),
                  new GestureDetector(child: new Container(
                    width: 35,
                    height: 35,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.people,color: Colors.black,size: 20,),
                        new Text('friends',style: new TextStyle(fontSize: 10),)
                      ],),
                  ),),
                ])
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    currentSong='file://${widget.songs[0].filePath}';
    currentPlaylist=widget.playlist;
    super.initState();
    _loadAudio();
  }

  _loadAudio(){
      widget.songs.forEach((element) {
        _qeue.add(MediaItem(
            id: "file://${element.filePath}",
            title: element.title,
            album: element.album.toString(),
            artist: element.artist.toString(),
            duration: Duration(milliseconds: int.parse(element.duration)),
            artUri: "file://${element.albumArtwork}"
        ));
      });

  }
  Future audioPlayerButton() async{

    List<dynamic> list = List();
    for (int i = 0; i < _qeue.length; i++) {
      var m = _qeue[i].toJson();
      list.add(m);
    }
    var params = {"data": list};
    await AudioService.start(
        backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'Audio Service Demo',
        // Enable this if you want the Android service to exit the foreground state on pause.
        //androidStopForegroundOnPause: true,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
        params: params
    );}
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
              (queue, mediaItem, playbackState) =>
              ScreenState(queue:queue, mediaItem:mediaItem, playbackState: playbackState));
}


class findPlaylistTile extends StatefulWidget {
  final double height;
  final double width;
  final Function dowRe;
  final Widget title;
  final Widget Artist;
  final Widget icon;
  final bool isavailable;
  final Function onPressed;
  final String A;
  final String T;
  final String U;

  findPlaylistTile(
      {this.isavailable, this.height, this.width, this.dowRe, this.icon, this.Artist, this.title,this.onPressed,
      this.A,this.T,this.U});
  findPlaylistTileState createState()=>findPlaylistTileState();
}
class findPlaylistTileState extends State<findPlaylistTile>{
  bool requested=false;
  buttonState state=buttonState.none;
  List<Widget> buttonWidgets=[
    new Text('send'),
    new SizedBox(
      height: 36,
      width: 36,
      child: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),),
    ),
    new Text('sent')
  ];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new  Container(
      padding: EdgeInsets.only(left: 8,right: 8),
      height: widget.height,
      width: widget.width,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,

          )
        )
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        new Container(
          height: widget.height*0.9,
        width: widget.width*0.2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: widget.icon,
        ),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),),
          new SizedBox(
            height: widget.height*0.6,
            width: widget.width*0.6,
            child: new Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 0),
              child: new Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  widget.title,
                  widget.Artist
                ],),
            ),),
       widget.isavailable? new GestureDetector(
         child: new Container(height: 28,
           width: 28,
           child:new Icon(Icons.arrow_downward),
           decoration: BoxDecoration(
             color: Colors.green,
             shape: BoxShape.circle,
           ),),
         onTap: (){
           widget.dowRe;
         },
       ):new GestureDetector(
         child: new Container(
           padding: EdgeInsets.all(6),
           height: 52,
           width: 52,
           child: new Center(child: buttonWidgets[state.index]),
           decoration: new BoxDecoration(
               color: Colors.pink,
               borderRadius: BorderRadius.all(Radius.circular(10))
           ),
         ),
         onTap: (){
           print('TAPPED');
           setState(() {
             state=buttonState.sending;
           });
           Firestore.instance.collection('requests')
               .add({
             'sentby':widget.U,
             'title':widget.T,
             'artist':widget.A,
           }).then((value) {
             setState(() {
               state=buttonState.sent;
             });
           }).catchError((error){
             setState(() {
               state=buttonState.none;
             });
           });
         },
       )
      ],),
    );
  }
}



class findPlaylistTile2 extends StatelessWidget{
  final double height;
  final double width;
  final Function dowRe;
  final Widget title;
  final Widget Artist;
  final Widget icon;
  final bool isavailable;
  bool _showOptions=true;
  findPlaylistTile2({this.isavailable,this.height,this.width,this.dowRe,this.icon,this.Artist,this.title});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _showOptions?new  Container(
      padding: EdgeInsets.only(left: 8,right: 8),
      height: height,
      width: width,
      decoration: new BoxDecoration(
          border: Border(
              bottom: BorderSide(
                color: Colors.black12,

              )
          )
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Container(
            height: height*0.9,
            width: width*0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: icon,
            ),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),),
          new SizedBox(
            height: height*0.6,
            width: width*0.6,
              child: new Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 2),
                child: new Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    title,
                     Artist
                  ],),
              ),),
          isavailable? new GestureDetector(
            child: new Container(height: 28,
              width: 28,
              child:new Icon(Icons.arrow_upward),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),),
            onLongPress: (){
              _showOptions=false;
            },
            onTap: (){
              dowRe;
            },
          ):new GestureDetector(
            child: new Container(
              padding: EdgeInsets.all(6),
              height: 38,
              width: 52,
              child: new Center(child: new Text('post',style: new TextStyle(fontSize: 10),),),
              decoration: new BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
            ),
            onTap: (){
              dowRe;
            },
          )
        ],),
    ):new Container(height: height,width: width,color: Colors.pink,);
  }

}


class createplaylistTile extends StatelessWidget{
  final double height;
  final double width;
  final Widget icon;
  final Text title;
  createplaylistTile({this.height,this.width,this.icon,this.title});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      padding: EdgeInsets.only(left:8,right:8),
      height: height,
      width: width,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[

        new Container(
          height: 80,
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(300.0),
            child: icon,
          ),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),),
        title,
          new SizedBox(width: width*0.2,),
        //new IconButton(icon: Icon(Icons.), onPressed: null)
      ],),
    );
  }
}

class findPlaylistTile3 extends StatefulWidget{
  final double height;
  final double width;
  final Function dowRe;
  final Widget title;
  final Widget Artist;
  final Widget icon;
  findPlaylistTile3({this.height,this.width,this.dowRe,this.icon,this.Artist,this.title,this.checkTheBox});
  final Function checkTheBox;
  @override
  findPlaylistTile3State createState()=>findPlaylistTile3State();

}

class findPlaylistTile3State extends State<findPlaylistTile3>{
  bool isChecked=false;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new  Container(
      padding: EdgeInsets.only(left: 8,right: 8),
      height: widget.height,
      width: widget.width,
      decoration: new BoxDecoration(
          border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.1)
              )
          )
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Container(
            height: widget.height*0.9,
            width: widget.width*0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: widget.icon,
            ),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),),
          new SizedBox(
            height: widget.height*0.6,
            width: widget.width*0.6,
            child: new Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 2),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  widget.title,
                  widget.Artist
                ],),
            ),),
          new Checkbox(
            activeColor: Colors.pink,
              value:isChecked, onChanged: (newValue){
              setState(() {
                isChecked=newValue;
              });
              widget.checkTheBox(isChecked);
          })
        ],),
    );
  }
}

class findPlaylistTile7 extends StatelessWidget{
  final double height;
  final double width;
  final Function dowRe;
  final Widget title;
  final Widget Artist;
  final Widget icon;
  final bool isavailable;
  bool _showOptions=true;
  findPlaylistTile7({this.isavailable,this.height,this.width,this.dowRe,this.icon,this.Artist,this.title});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _showOptions?new  Container(
      padding: EdgeInsets.only(left: 8,right: 8),
      height: height,
      width: width,
      decoration: new BoxDecoration(
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Container(
            height: height*0.9,
            width: width*0.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: icon,
            ),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),),
          new SizedBox(
            height: height*0.6,
            width: width*0.6,
            child: new Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 0),
              child: new Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  title,
                  Artist
                ],),
            ),),
        ],),
    ):new Container(height: height,width: width,color: Colors.pink,);
  }

}


class myBottomNavBar2 extends StatefulWidget {
  final Function tabFunction;
  final int indeX;
  final songs;
  final playlist;
  myBottomNavBar2({this.tabFunction,this.indeX,this.songs,this.playlist});
  @override
  bottomState2 createState()=>bottomState2();
}
class bottomState2 extends State<myBottomNavBar2>{

  List<MediaItem> _qeue=[];
  @override

  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    double height=80.0;
    // TODO: implement build
    return new StreamBuilder<ScreenState>(
        stream:_screenStateStream,
        builder: (context,snapshot){
          final screenState=snapshot.data;
          final qeue=screenState?.queue;
          final mediaItem=screenState?.mediaItem;
          final playbackState=screenState?.playbackState;
          final state=screenState?.playbackState;
          final processingState=playbackState?.processingState??
              AudioProcessingState.none;
          final playing = state?.playing ?? false;
          return new Container(
            width: size.width,
            height: height,
            child: Column(
              children: <Widget>[

                new Container(height:height,
                  child: new Row(children: <Widget>[
                    new SizedBox(width: 10,),
                    if(processingState==AudioProcessingState.none)...[
                      SizedBox(width: size.width*0.7,
                        child: new  AutoSizeText('Play a song from your playlist',style: new TextStyle(fontSize: 2,color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),),

                    ]else...[
                      new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                              height:size.height*0.05,
                              width: size.width*0.5,
                              child:  new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(mediaItem?.title==null?'':mediaItem.title,style: new TextStyle(fontSize: 2,fontWeight: FontWeight.bold,color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AutoSizeText(mediaItem?.artist==null?'':mediaItem.artist,style: new TextStyle(fontSize: 2,color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],)
                          ),

                        ],
                      ),
                      new Container(
                        padding: EdgeInsets.only(left: size.width*0.05),
                        child: new Row(children: <Widget>[
                          new IconButton(icon: Icon(Icons.skip_previous,color: Colors.white,), onPressed: (){
                            setState(() {
                              if(mediaItem==qeue.first){
                                AudioService.skipToQueueItem(qeue.last.id);
                                print('HERE I AM');
                              }
                              else{
                                AudioService.skipToPrevious();
                                if(!playing){
                                  AudioService.play();
                                }
                              }
                            });
                          }),
                          new IconButton(icon:playing?Icon(Icons.pause,color: Colors.white,):Icon(Icons.play_arrow,color: Colors.white,), onPressed: (){
                            if(playing){
                              setState(() {
                                AudioService.pause();

                              });
                            }
                            else{
                              setState(() {
                                AudioService.play();
                              });
                            }
                          }),
                          new IconButton(icon: Icon(Icons.skip_next,color: Colors.white,), onPressed:(){
                            if(mediaItem==qeue.last){
                              AudioService.skipToQueueItem(qeue.first.id);
                            }
                            else{
                              AudioService.skipToNext();
                              if(!playing){
                                AudioService.play();
                              }
                            }
                          })
                        ],),
                      )
                    ]
                  ],),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(20))),),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    currentSong='file://${widget.songs[0].filePath}';
    currentPlaylist=widget.playlist;
    super.initState();
    _loadAudio();
  }

  _loadAudio(){
    widget.songs.forEach((element) {
      _qeue.add(MediaItem(
          id: "file://${element.filePath}",
          title: element.title,
          album: element.album.toString(),
          artist: element.artist.toString(),
          duration: Duration(milliseconds: int.parse(element.duration)),
          artUri: "file://${element.albumArtwork}"
      ));
    });

  }
  Future audioPlayerButton() async{

    List<dynamic> list = List();
    for (int i = 0; i < _qeue.length; i++) {
      var m = _qeue[i].toJson();
      list.add(m);
    }
    var params = {"data": list};
    await AudioService.start(
        backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'Audio Service Demo',
        // Enable this if you want the Android service to exit the foreground state on pause.
        //androidStopForegroundOnPause: true,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
        params: params
    );}
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
              (queue, mediaItem, playbackState) =>
              ScreenState(queue:queue, mediaItem:mediaItem, playbackState: playbackState));
}



enum buttonState{
  none,
  sending,
  sent
}