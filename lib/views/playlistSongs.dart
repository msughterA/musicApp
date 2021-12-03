import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'Simplewidgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:musicApp/audioPlayerMethods.dart';
import 'musicPlayer.dart';
import 'createPlaylist.dart';
import 'package:musicApp/android_methods.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:audio_service/audio_service.dart';
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

class songListPlay extends StatefulWidget {
  final androidEngine engine;
  final String playlistName;
  final List<SongInfo> songs3;
  songListPlay({this.engine,this.playlistName,this.songs3});
  songListPlayState createState()=>songListPlayState();
}
class songListPlayState extends State<songListPlay>{
  TextEditingController _controller=new TextEditingController();
  List<String> filepaths=[];
  List<SongInfo> currentPlaylist=[];
  int indexofAudio;
  @override
  List<String> _options=['delete','upload'];
  String _selectedOption='';

  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width =MediaQuery.of(context).size.width;
    print(width.toString());
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(leading: new IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.black,), onPressed: (){
        Navigator.pop(context);
        //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>createPlaylist(engine: widget.engine,songs: widget.songs3,)));
      })
        ,actions: <Widget>[IconButton(icon: Icon(Icons.search,size: 30,color: Colors.black,),
            onPressed:(){
            //Search for songs
            }),new SizedBox(width: 10.0,)],
        elevation:0,backgroundColor: Colors.white,),
      bottomNavigationBar: new GestureDetector(child: myBottomNavBar2(songs: widget.songs3,),
      onTap: (){
        if(isPlaying) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
              player(playlist: widget.playlistName,songs: currentPlaylist,currentIndex: indexofAudio,songinfo: currentPlaylist[indexofAudio],)));
        }
      },),
      body: new Stack(
        children: [
          new StreamBuilder(
              stream: widget.engine.readFromPlaylist(widget.playlistName).asStream(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),);
                }
                return snapshot.data.isEmpty?new Container(
                    height: height,
                    width: width,
                    child: new Center(child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Icon(Icons.add,color: Colors.grey,),
                        new Text(' add Songs to your Playlist',style: TextStyle(color: Colors.pink),)
                      ],),)
                ):Container(
                  height: height,
                  width:width,
                  child:new Column(
                    children: <Widget>[
                      new Container(
                      height: height*0.4,
                      width: width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Container(
                              height: 140,
                              width: 140,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(300.0),
                                child:FittedBox(child: snapshot.data[0]['artUri${0}']!='null'?Image.file(File(snapshot.data[0]['artUri${0}'])):Image.asset('Assets/Images/testImage.jpg',),
                                  fit: BoxFit.cover,),
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),),
                            new SizedBox(height: 20.0,),
                            new Text('${widget.playlistName}',style: new TextStyle(fontWeight: FontWeight.bold),),
                            new SizedBox(height: 13.0,),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              new RaisedButton(
                                child: new Text('shuffle'),
                                onPressed: (){
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

                                },color: shufflePressed?Colors.pink:Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                ),),
                              new RaisedButton(
                                child: new Text('order'),
                                onPressed: (){
                                  if(isPlaying){
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

                                  }
                                },color: shufflePressed?Colors.white:Colors.pink,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)
                                ),),
                            ],)
                        ],),
                      ),
                      new Expanded(
                        child: new ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index){

                            for (int i=0;i<snapshot.data.length;i++){
                               filepaths.add(snapshot.data[i]['id${i}']);
                            }
                            widget.songs3.forEach((element) {
                              if(filepaths.contains(element.filePath)){
                                currentPlaylist.add(element);
                              }
                              else{
                                //widget.engine.Delete('playlists/${widget.playlistName}/${path.basenameWithoutExtension(element.filePath)}');
                              }
                            });

                            return new GestureDetector(
                              onTap: (){
                                //print(snapshot.data[index]);
                                 indexofAudio=currentPlaylist.indexWhere((element)=>
                                element.filePath==snapshot.data[index]['id${index}']);
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>player(songinfo: currentPlaylist[indexofAudio],songs: currentPlaylist,currentIndex: indexofAudio,playlist: widget.playlistName,)));
                              },
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                findPlaylistTile7(
                                  width: width*0.8,
                                  isavailable: true,
                                  height: height*0.1,
                                  title: snapshot.data[index]['title${index}']!='null'?AutoSizeText('${snapshot.data[index]['title${index}']}',style: new TextStyle(fontSize: 5,fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                  ):new Text('Unknown'),
                                  Artist: snapshot.data[index]['artist${index}']!='null'?AutoSizeText('${snapshot.data[index]['artist${index}']}.${parseToMinutesSeconds(int.parse(snapshot.data[index]['duration${index}']))}min',style: new TextStyle(fontSize: 2),
                                    maxLines: 1,):new Text('Unknown'),
                                  icon: FittedBox(child: snapshot.data[index]['artUri${index}']!='null'?Image.file(File(snapshot.data[index]['artUri${index}'])):Image.asset('Assets/Images/testImage.jpg',),
                                    fit: BoxFit.cover,),
                                ),
                                DropdownButtonHideUnderline(child:DropdownButton(
                                  items: _options.map((e){
                                    return DropdownMenuItem(child: new Text(e),
                                      value: e,
                                    );
                                  }).toList(), onChanged: (value){
                                  setState(() {
                                    _selectedOption=value;
                                    if(_selectedOption=='delete'){
                                      widget.engine.Delete('playlists/${widget.playlistName}/${path.basenameWithoutExtension(snapshot.data[index]['id${index}'])}');

                                    }
                                  });
                                },
                                  icon:  Icon(Icons.more_vert),
                                  isDense: false,
                                ))
                              ],)
                            );
                          },),
                      ),
                    ],
                  ),
                );
              }),
          new Positioned(
              bottom: 25.0,
              right: 20.0,
              child: new GestureDetector(
                onTap: (){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>selectSong(playlistName: widget.playlistName,
                  songs2: widget.songs3,engine: widget.engine,)));
                },
                child: new Container(
                  child: new Center(
                    child: new Icon(Icons.add),
                  ),
                  decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                          offset: Offset(10,10),
                          blurRadius: 10)],
                      color: Colors.pink,
                      shape: BoxShape.circle
                  ),
                  height: 55,
                  width: 55,
                ),
              ))
        ],
      ),
    );

  }

  @override
  void initState() {
    widget.engine.mkdir("playlists").then((value){
            widget.engine.readFromPlaylist(widget.playlistName).then((value){
              print('CURRENT PLAYLIST LENGTH IS ${value.length}');
            });
    });
    super.initState();
  }

  dialog(BuildContext context) async {
    return showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: Container(
          height: 200,
          width: 200,
          padding: EdgeInsets.all(20.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                child: new Text("Are you sure you want to add to playlist"),
                width: 150,),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  new RaisedButton(
                    child: new Text('ok'),
                    onPressed: ()async {
                      //await widget.engine.createplaylist(_controller.text);
                      //print('Playlist created successfully');
                      //playlists=await widget.engine.readPlaylists();
                      setState(() {

                      });
                      Navigator.pop(context);
                    },color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)
                    ),),
                  new RaisedButton(
                    child: new Text('cancel'),
                    onPressed: (){
                      Navigator.pop(context);
                    },color: Colors.pink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0)
                    ),)
                ],)
              //new Center(child: ,)
            ],),
        ),
      );
    });
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



