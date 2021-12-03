import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'Simplewidgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:musicApp/audioPlayerMethods.dart';
import 'musicPlayer.dart';

void main(){
  runApp(MaterialApp());
}

/*
class songsList extends StatefulWidget{
  @override
  songState createState()=>songState();
}
songState
State<songsList>
 */

class songList extends StatelessWidget {
  final List<SongInfo> songinfo;
  songList({this.songinfo});
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width =MediaQuery.of(context).size.width;
    print(width.toString());
    // TODO: implement build
    return new Container(
        height: height,
        width:width,
        child:new Column(
          children: <Widget>[
            new Expanded(
              child: new ListView.builder(
                itemCount: songinfo.length,
                itemBuilder: (BuildContext context, int index){
                  return new GestureDetector(
                    onTap: (){
                      print(songinfo[index]);
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>player(songinfo: songinfo[index],songs: songinfo,currentIndex: index,playlist: 'My Songs',)));
                    },
                    child: findPlaylistTile2(
                      width: width,
                      isavailable: true,
                      height: height*0.1,
                      title: songinfo[index].title!=null?AutoSizeText('${songinfo[index].title.trimLeft()}',style: new TextStyle(fontSize: 5,fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ):new Text('Unknown'),
                      Artist: songinfo[index].artist!=null?AutoSizeText('${songinfo[index].artist.trimLeft()}.${parseToMinutesSeconds(int.parse(songinfo[index].duration))}min',style: new TextStyle(fontSize: 2),
                        maxLines: 1,):new Text('Unknown'),
                      icon: FittedBox(child: songinfo[index].albumArtwork!=null?Image.file(File(songinfo[index].albumArtwork)):Image.asset('Assets/Images/testImage.jpg',),
                        fit: BoxFit.cover,),
                    ),
                  );
                },),
            ),
          ],
        ),
      );

  }
  String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }
}


