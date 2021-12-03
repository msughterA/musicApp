/*
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:audio_manager/audio_manager.dart';
import 'Simplewidgets.dart';
import 'package:musicApp/android_methods.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'dart:math';
import 'package:audio_manager/audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';


bool  _shufflePressed=false;
bool _playPressed=false;
int _repeateValue=0;


List<Widget> _shufflIcon=[
Icon(Icons.repeat),
Icon(Icons.repeat,color: Colors.redAccent,),
Icon(Icons.repeat_one,color: Colors.redAccent,)];
//var audioManagerInstance=AudioManager.instance;
PlayMode playMode=AudioManager.instance.playMode;
bool isPlaying=false;
double _slider;
List<int> _randoms = [];
List<AudioInfo> audioSongs=[];
List<AudioInfo> shuffledSongs=[];
List<AudioInfo> _songs=[];
List<AudioInfo> rSequence=[];
List<AudioInfo> lSequence=[];
List<AudioInfo> rShuffled=[];
List<AudioInfo> lShuffled=[];
List<int> randomsl=[];
List<int> randomsr=[];
int indexofAudio=0;




class player extends StatefulWidget{
  final SongInfo songinfo;
  final List<SongInfo> songs;
   int currentIndex;
  player({this.songinfo,this.currentIndex,this.songs});
  @override
  playerState createState()=>playerState();
}


class playerState extends State<player>{
  double _value=0.0;
  int _curIndex=0;
   //int indexOfCur=0;
  @override
  void initState() {
    //print('${qeue.list[0]}');
    super.initState();
    songInfoToAudio();
    setupAudio();
    shuffle();
    updateIndex();
    print('rSequence length is${rSequence.length}');
    AudioManager.instance.play(index:widget.currentIndex);
    //AudioManager.instance.start("file://${widget.songinfo.filePath}", widget.songinfo.title).then((value) => print(value.toString()));
    AudioManager.instance.audioList.replaceRange(0, AudioManager.instance.curIndex,_shufflePressed?
    lShuffled:lSequence);
    AudioManager.instance.audioList.replaceRange( AudioManager.instance.curIndex+1,
        AudioManager.instance.audioList.length
        ,_shufflePressed? rShuffled:rSequence);
    print('AUDIO LIST LENGHT IS${AudioManager.instance.audioList.length}');
      //print(audioSongs[_curIndex]);
    operateQeue();
  }




  updateIndex(){
  indexofAudio=AudioManager.instance.audioList.indexWhere((element)=>
  element.title==widget.songs[widget.currentIndex].title);

}
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.width;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
      appBar: appBar(),
      body: new Container(
        padding: EdgeInsets.all(8.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: new Column(
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
                  child:AudioManager.instance.audioList[AudioManager.instance.curIndex].coverUrl!='file://null'?Image.file(File(AudioManager.instance.audioList[AudioManager.instance.curIndex].coverUrl.substring(7))):
                  Image.asset('Assets/Images/testImage.jpg'),
                ),),
            ),
            new SizedBox(height: height*0.2,),
            new Container(
              height: height*0.2,
              width: width,
              child: new Column(
                children: <Widget>[
                  AutoSizeText('${AudioManager.instance.audioList[AudioManager.instance.curIndex].title}',style: new TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  AutoSizeText('${widget.songs[AudioManager.instance.curIndex].artist}',style: new TextStyle(fontSize: 5,fontWeight: FontWeight.bold),
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
              child: new Row(
                children: <Widget>[
                  new Text(_formatDuration(AudioManager.instance.position)),
                 new Expanded(child:
                 SliderTheme(
                   child: Slider(
                    activeColor: Colors.red[700],
                       inactiveColor: Colors.red[100],
                       value: _slider??0,
                     onChanged: (value){
                         setState(() {
                           _slider=value;
                         });
                     },
                     onChangeEnd: (value){
                      if(AudioManager.instance.duration!=null){
                        Duration msec=Duration(
                          milliseconds: (AudioManager.instance.duration.inMilliseconds*value).round());
                        AudioManager.instance.seekTo(msec);
                      }
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
                  new Text(_formatDuration(AudioManager.instance.duration))
                ],
              ),),
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
                      AudioManager.instance.nextMode(playMode: PlayMode.single);
                    }

                    //operateQeue();

                  });
                }),
                new IconButton(icon: Icon(Icons.skip_previous), onPressed: () async {
                  operateQeue();
                  if(AudioManager.instance.curIndex!=0){
                    await AudioManager.instance.previous();
                  }
                  else if(AudioManager.instance.curIndex==0){
                    await AudioManager.instance.play(index: audioSongs.length-1);
                  }


                  setState(() {
                  });
                }),
                new GestureDetector(
                  onTap: (){
                    operateQeue();
                    AudioManager.instance.playOrPause();
                    setState(() {
                      _playPressed=!_playPressed;
                    });
                  },
                  child: new Container(
                  height: 50,
                  width: 50,
                  child: _playPressed?new Icon(Icons.play_arrow):new Icon(Icons.pause),
                  decoration: new BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                    offset: Offset(10,10),blurRadius: 10)],
                    shape: BoxShape.circle,
                    color: Colors.pink,
                  ),
                ),),
                new IconButton(icon: Icon(Icons.skip_next), onPressed:(){
                  operateQeue();
                  //setupAudio();
                  if(AudioManager.instance.curIndex!=(AudioManager.instance.audioList.lastIndexOf(
                      AudioManager.instance.audioList.last)-1)){
                    AudioManager.instance.next();
                  }
                  else if(AudioManager.instance.curIndex==(AudioManager.instance.audioList.lastIndexOf(
                      AudioManager.instance.audioList.last)-1)){
                    AudioManager.instance.play(index:0 );
                  }

                }),
                new IconButton(icon:Icon(Icons.shuffle,color: _shufflePressed?Colors.redAccent:Colors.black,), onPressed: (){
                  setState(() {
                    _shufflePressed=!_shufflePressed;
                    //shuffle();
                  });
                   int indexOfCur=audioSongs.indexWhere((element) => element.title==AudioManager.instance.audioList[
                    AudioManager.instance.curIndex
                  ].title);
                  lSequence=audioSongs.sublist(0,AudioManager.instance.curIndex);
                  rSequence=audioSongs.sublist(AudioManager.instance.curIndex+1,
                      audioSongs.length);
                  shuffle();
                  if(_shufflePressed==true){
                    AudioManager.instance.audioList.replaceRange(0, AudioManager.instance.curIndex,
                        lShuffled);
                    AudioManager.instance.audioList.replaceRange( AudioManager.instance.curIndex+1,
                        AudioManager.instance.audioList.length
                        ,rShuffled);
                  }
                  else{
                    AudioManager.instance.audioList.replaceRange(0, AudioManager.instance.curIndex,
                        lSequence);
                    AudioManager.instance.audioList.replaceRange( AudioManager.instance.curIndex+1,
                        AudioManager.instance.audioList.length
                        ,rSequence);
                  }
                })
              ],),
            )
          ],),
      ),
    );
  }
  operateQeue(){

    if(_shufflePressed==true && _repeateValue==0){
      //playMode=AudioManager.instance.nextMode(playMode: PlayMode.shuffle);
      shuffle();
      print('am here');
    }
    else if(_shufflePressed==false && _repeateValue==0){

     playMode= AudioManager.instance.nextMode(playMode: PlayMode.sequence);
      print('am not');
      print(playMode.toString());
    }

    else if(_repeateValue==1){
     playMode= AudioManager.instance.nextMode(playMode: PlayMode.sequence);
     print('am 3');
    }

    else if(_repeateValue==2){
      playMode=AudioManager.instance.nextMode(playMode: PlayMode.single);
      print('am 4');
    }
    //print(qeue.list[1]);
  }
  shuffle(){

    if(rShuffled.isEmpty==false){
      rShuffled.clear();
    }
    if(lShuffled.isEmpty==false){
      lShuffled.clear();
    }
    randomsl=lSequence.asMap().keys.toList();
    randomsl.shuffle();
    randomsl.forEach((element) {
      lShuffled.add(lSequence[element]);
    });
    randomsr=rSequence.asMap().keys.toList();
    randomsr.shuffle();
    randomsr.forEach((element) {
      rShuffled.add(rSequence[element]);
    });
  }
  setupAudio() async{
    /*
     List<AudioInfo> audioList=[];
     audioSongs.forEach((element) {
       audioList.add(element);
     });

     */
    audioSongs.forEach((element) {
      AudioManager.instance.audioList.add(element);
    });

    setState(() {

      AudioManager.instance.intercepter = false;
      AudioManager.instance.play(auto: false);
      //AudioManager.instance.play(auto: true,index: 0);
    });
    //AudioManager.instance.play(auto: true,index: 0);
    AudioManager.instance.onEvents((events, args) {
      //print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          setState(() {

            _slider = 0;
          });
          break;

        case AudioManagerEvents.ready:
          _slider=AudioManager.instance.position.inMilliseconds /
              AudioManager.instance.duration.inMilliseconds;
          setState(() {

          });
          break;

        case AudioManagerEvents.seekComplete:
          _slider = AudioManager.instance.position.inMilliseconds /
              AudioManager.instance.duration.inMilliseconds;
          setState(() {

          });
          break;

        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          setState(() {

          });
          break;
        case AudioManagerEvents.timeupdate:
          _slider = AudioManager.instance.position.inMilliseconds /
              AudioManager.instance.duration.inMilliseconds;
          AudioManager.instance.updateLrc(args["position"].toString());
          setState(() {

          });
          break;
        case AudioManagerEvents.error:
          print(args);
          break;
        case AudioManagerEvents.ended:

          setState(() {
            if(_repeateValue==1 && (AudioManager.instance.curIndex==(AudioManager.instance.audioList.lastIndexOf(
                AudioManager.instance.audioList.last)-1))){
              AudioManager.instance.play(index: 0);
            }
            else if(_repeateValue==0 &&(AudioManager.instance.curIndex==(AudioManager.instance.audioList.lastIndexOf(
                AudioManager.instance.audioList.last)-1))){
               AudioManager.instance.play(index:0 );
            }
            else if(_repeateValue==2){
              //AudioManager.instance.stop();
              //AudioManager.instance.play(index: AudioManager.instance.curIndex,);
              AudioManager.instance.start(
                  AudioManager.instance.audioList[AudioManager.instance.curIndex+1].url,
                  AudioManager.instance.audioList[AudioManager.instance.curIndex+1].title);
            }
            else{
              AudioManager.instance.next();
            }
          });
          break;
        default:
          break;
      }
    });
  }
  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

songInfoToAudio(){
    widget.songs.forEach((element){
        audioSongs.add(AudioInfo(
      'file://${element.filePath}',
      coverUrl: 'file://${element.albumArtwork}',
      title: element.title,
      desc: element.displayName
    ));

    });
    lSequence=audioSongs.sublist(0,widget.currentIndex);
    rSequence=audioSongs.sublist(widget.currentIndex+1,widget.songs.length);

}

}

.then((value) {
                                  setState(() {
                                    bstate=buttonState.sent;
                                  });
                              }).catchError((error){
                                 setState(() {
                                   print('ERORR IS ${error}');
                                   bstate=buttonState.none;
                                 });
                              });

enum repeat{
  shuffleSongs,
  shuffleOff,
  shuffleOneSong
}
 */

