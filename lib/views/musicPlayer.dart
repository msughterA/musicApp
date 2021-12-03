import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'Simplewidgets.dart';
import 'package:musicApp/android_methods.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'dart:math';
import'package:just_audio/just_audio.dart';
import 'package:musicApp/audioPlayerMethods.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:musicApp/audioPlayerMethods.dart';


void audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => MyBackgroundTask());
}

bool  shufflePressed=false;
bool _playPressed=false;
int _repeateValue=0;

bool isPlaying=false;
String currentSong='';
String currentPlaylist='';
MediaItem currentMediaItem=null;
//test list

List<Widget> _shufflIcon=[
Icon(Icons.repeat),
Icon(Icons.repeat,color: Colors.redAccent,),
Icon(Icons.repeat_one,color: Colors.redAccent,)];
//var audioManagerInstance=AudioManager.instance;




class player extends StatefulWidget{
  final SongInfo songinfo;
  final List<SongInfo> songs;
  final String playlist;
   int currentIndex;
  player({this.songinfo,this.currentIndex,this.songs,this.playlist});
  @override
  playerState createState()=>playerState();
}


class playerState extends State<player>{
  final BehaviorSubject<double> _dragPositionSubject =
  BehaviorSubject.seeded(null);
  double _value=0.0;
  int _curIndex=0;
  double _slider=0;

  List<MediaItem> _qeue=[];
   //int indexOfCur=0;
  @override
  void initState() {
    //print('${qeue.list[0]}');
    super.initState();
    //AudioService.setShuffleMode(AudioServiceShuffleMode.all);
    currentSong='file://${widget.songs[widget.currentIndex].filePath}';
    //currentPlaylist=widget.playlist;
    _loadAudio();
    if(isPlaying==false){
      loadb();

    }
    else{
      String filepath='file://${widget.songs[widget.currentIndex].filePath}';
      if(currentSong==AudioService.currentMediaItem.id && currentPlaylist==widget.playlist){
        currentSong=AudioService.currentMediaItem.id;
        currentPlaylist=widget.playlist;
        print('I AM HERE IN LAST CONDITION 1');
      }
      else if(currentSong!=AudioService.currentMediaItem.id && currentPlaylist==widget.playlist){
        AudioService.skipToQueueItem(filepath);
        currentSong=AudioService.currentMediaItem.id;
        currentPlaylist=widget.playlist;
        print('I AM HERE IN LAST CONDITION 2');
      }
      else if(currentSong==AudioService.currentMediaItem && currentPlaylist!=widget.playlist){
        stop().then((value) {
          loadb();
        });
        currentSong=AudioService.currentMediaItem.id;
        currentPlaylist=widget.playlist;
      }
      else {
        print('I AM HERE IN LAST CONDITION 3');
        stop().then((value) {
          loadb();
        });
        currentSong=AudioService.currentMediaItem.id;
        currentPlaylist=widget.playlist;
      }
    }
  }

  loadb()async{
    await audioPlayerButton();
  }
  Future stop()async{
    await AudioService.stop();
  }
  comparison({var val,var rval,var erval}){
    if(val==null){
      return rval;
    }
    else{
      return erval;
    }
  }

 _loadAudio(){
  if(widget.currentIndex==0){
    widget.songs.forEach((element) {
      _qeue.add(MediaItem(
        id: "file://${element.filePath}",
        album: element.album.toString(),
        artist: element.artist.toString(),
        duration: Duration(milliseconds: int.parse(element.duration)),
        artUri: "file://${element.albumArtwork}"
      ));
    });
  }
  else{
    for(int i=widget.currentIndex;i<widget.songs.length;i++){
      _qeue.add(MediaItem(
        id: "file://${widget.songs[i].filePath}",
        album: widget.songs[i].album.toString(),
          title: widget.songs[i].title,
          artist: widget.songs[i].artist,
        duration: Duration(milliseconds: int.parse(widget.songs[i].duration)),
        artUri: "file://${widget.songs[i].albumArtwork}"
      ));

    }
    for(int i=0;i<widget.songs.length;i++){
      _qeue.add(MediaItem(
          id: "file://${widget.songs[i].filePath}",
          title: widget.songs[i].title,
          artist: widget.songs[i].artist,
          album: widget.songs[i].album.toString(),
          duration: Duration(milliseconds: int.parse(widget.songs[i].duration)),
          artUri: "file://${widget.songs[i].albumArtwork}"
      ));

    }

  }

}


  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.width;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      floatingActionButton: new FloatingActionButton(onPressed: (){
        //Like a song and increase the number of likes in the database
      },child: new Icon(Icons.thumb_up),backgroundColor: Colors.pink,),
      appBar: appBar(),
      body: new Container(
        padding: EdgeInsets.all(8.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context,snapshot){
            final screenState = snapshot.data;
            final hasData=screenState?.mediaItem??null;
            //print(' THIS IS THE CURRENT SCREEN STATE${screenState.mediaItem==null}');
            
              if(hasData==null){
                return new Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: new Center(
                    child: new CircularProgressIndicator(backgroundColor: Colors.pink,),
                  ),
                );
              }
            else{
                final queue = screenState?.queue;
                final mediaItem = screenState?.mediaItem;
                final state = screenState?.playbackState;
                final processingState =
                    state?.processingState ?? AudioProcessingState.none;

                final playing = state?.playing ?? false;
                isPlaying=playing;
                final running=snapshot.hasData;
                currentSong=mediaItem.id;
                currentPlaylist=widget.playlist;
               isPlaying=playing;
               //currentMediaItem=mediaItem;

                return new Column(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      height:height*0.8,
                      width: width*0.8,
                      decoration: new BoxDecoration(
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(10,10),
                            blurRadius: 10,
                          )]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child:
                        FittedBox(
                          fit: BoxFit.cover,
                          child:mediaItem?.artUri!='file://null'?Image.file(File(mediaItem?.artUri?.substring(7))):
                          Image.asset('Assets/Images/testImage.jpg'),
                        ),),
                    ),
                    new SizedBox(height: height*0.2,),
                    new Container(
                      height: height*0.2,
                      width: width,
                      child: new Column(
                        children: <Widget>[
                          AutoSizeText('${mediaItem?.title}',style: new TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                            maxLines: 1,
                          ),
                          AutoSizeText('${mediaItem?.artist}',style: new TextStyle(fontSize: 5,fontWeight: FontWeight.bold),
                            maxLines: 1,
                          )

                        ],
                      ),
                    ),
                    //new SizedBox(height:height*0.1 ,),
                    new Container(
                      padding: EdgeInsets.only(left: 8,right: 8),
                      height: height*0.1,
                      width: width,
                      child:positionIndicator(mediaItem, state),),
                    new Container(
                      height: height*0.2,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new IconButton(icon:_shufflIcon[_repeateValue], onPressed: (){

                            setState(() {

                              if(_repeateValue==2){
                                _repeateValue=0;
                              }
                              else{
                                _repeateValue+=1;
                              }
                              if (_repeateValue == 2) {

                              }
                              //operateQeue();

                            });
                            if(_repeateValue==2){
                              AudioService.setRepeatMode(AudioServiceRepeatMode.one);
                            }
                            else if(_repeateValue==1){
                              AudioService.setRepeatMode(AudioServiceRepeatMode.all);
                            }
                            else{
                              AudioService.setRepeatMode(AudioServiceRepeatMode.none);
                            }

                          }),
                          new IconButton(icon: Icon(Icons.skip_previous), onPressed: () async {
                            setState(() {
                                      if(mediaItem==queue.last){
                                      AudioService.skipToQueueItem(queue.first.id);
                                      }
                                      else {
                                        AudioService.skipToNext();
                                        if (!playing) {
                                          AudioService.play();
                                        }
                                      }});
                          }),
                          new GestureDetector(
                            onTap: (){
                              playing?AudioService.pause():AudioService.play();
                            },
                            child: new Container(
                              height: 50,
                              width: 50,
                              child: playing?new Icon(Icons.pause):new Icon(Icons.play_arrow),
                              decoration: new BoxDecoration(
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                                    offset: Offset(10,10),blurRadius: 10)],
                                shape: BoxShape.circle,
                                color: Colors.pink,
                              ),
                            ),),
                          new IconButton(icon: Icon(Icons.skip_next), onPressed:(){
                            //Play the next song
                            AudioService.skipToNext();

                          }),
                          new IconButton(icon:Icon(Icons.shuffle,color: shufflePressed?Colors.redAccent:Colors.black,), onPressed: (){
                            setState(() {
                              shufflePressed=!shufflePressed;
                             if(shufflePressed==true){
                               AudioService.setShuffleMode(AudioServiceShuffleMode.all);
                             }
                             else{
                               AudioService.setShuffleMode(AudioServiceShuffleMode.none);
                             }
                              //shuffle();
                            });

                          })
                        ],),
                    )
                  ],);
              }


          },
        ),
      ),
    );


  }
  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
              (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position =
            snapshot.data ?? state.currentPosition.inMilliseconds.toDouble();
        double duration = mediaItem?.duration?.inMilliseconds?.toDouble();
        return new Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              new Text(_formatDuration(state.currentPosition)),
              if (duration != null)
               new Expanded(child:  SliderTheme(
                 child: Slider(
                   activeColor: Colors.red[600],
                   inactiveColor: Colors.red[100],
                   min: 0.0,
                   max: duration,
                   value: seekPos ?? max(0.0, min(position, duration)),
                   onChanged: (value) {
                     _dragPositionSubject.add(value);
                   },
                   onChangeEnd: (value) {
                     AudioService.seekTo(Duration(milliseconds: value.toInt()));
                     // Due to a delay in platform channel communication, there is
                     // a brief moment after releasing the Slider thumb before the
                     // new position is broadcast from the platform side. This
                     // hack is to hold onto seekPos until the next state update
                     // comes through.
                     // TODO: Improve this code.
                     seekPos = value;
                     _dragPositionSubject.add(null);
                   },
                 ),
                 data: SliderTheme.of(context).copyWith(
                   //activeTickMarkColor: Colors.redAccent,
                   //inactiveTickMarkColor: Colors.red[100],

                   thumbColor: Colors.redAccent,
                   thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                   //overlayColor: Colors.red.withAlpha(32),
                   overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                 ),
               )),
              new Text(_formatDuration(mediaItem.duration)),
            ],
          );
      },
    );
  }

  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
              (queue, mediaItem, playbackState) =>
              ScreenState(queue:queue, mediaItem:mediaItem, playbackState: playbackState));

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
      );

      }



  IconButton playButton() => IconButton(
    icon: Icon(Icons.play_arrow),
    onPressed: AudioService.play,
  );

  IconButton pauseButton() => IconButton(
    icon: Icon(Icons.pause),
    onPressed: AudioService.pause,
  );

  IconButton stopButton() => IconButton(
    icon: Icon(Icons.stop),
    onPressed: AudioService.stop,
  );



  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }


}



enum repeat{
  shuffleSongs,
  shuffleOff,
  shuffleOneSong
}

class ScreenState{
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;
  ScreenState({this.queue,this.mediaItem,this.playbackState});
}