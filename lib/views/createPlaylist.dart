import 'package:flutter/material.dart';
import 'Simplewidgets.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:musicApp/android_methods.dart';
import 'playlistSongs.dart';
/*
class creatPlaylist extends StatefulWidget{
  @override
   createStatePlay createState()=>createStatePlay();
}
 */
class createPlaylist extends StatefulWidget{
  final List<SongInfo> songs;
  final androidEngine engine;
  createPlaylist({this.songs,@required this.engine});
  @override
  createPlayState createState()=>createPlayState();
}

class  createPlayState extends State<createPlaylist>{
  TextEditingController _controller=new TextEditingController();
  List<Map<String,String>> playlists=[];
  List<String> _options=['delete','upload'];
  String _selectedOption='';
  @override
  void initState() {
    widget.engine.mkdir('playlists').then((value) {
      print('Playlist initialized');
    });
  }

  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Stack(
      children: <Widget>[
        StreamBuilder(
           stream: widget.engine.readPlaylists().asStream(),
            builder: (context,snapshot){
             if(!snapshot.hasData){
               return new Center(child: new CircularProgressIndicator(),);

             }
             print(snapshot.data.isEmpty);
             return snapshot.data.isEmpty?new Container(
                 height: height,
                 width: width,
                 child: new Center(child: new Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     new Icon(Icons.add,color: Colors.grey,),
                     new Text(' add your first playlist',style: TextStyle(color: Colors.pink),)
                   ],),)
             ):new Column(
               children: <Widget>[new Expanded(child: new ListView.builder(
                 itemBuilder: (BuildContext context,int index){
                   return new Row(
                     children: [
                       new Expanded(
                         child: new GestureDetector(
                           behavior: HitTestBehavior.translucent,
                           onTap: (){
                             Navigator.of(context).push(MaterialPageRoute(builder:(context)=>songListPlay(engine: widget.engine,playlistName:snapshot.data[index]['playlist'],songs3: widget.songs,)));
                           },
                           child: new createplaylistTile(
                             title: new Text('${snapshot.data[index]['playlist']}',
                               style: new TextStyle(
                                   fontSize: 15,
                                   fontWeight: FontWeight.bold
                               ),),
                             height: height*0.2,
                             width: width,
                             icon: FittedBox(child:snapshot.data[index]['artUri']!='null'&&snapshot.data[index]['artUri']!=null?Image.file(File(snapshot.data[index]['artUri'])):Image.asset('Assets/Images/testImage.jpg',),
                               fit: BoxFit.cover,),
                           ),
                         ),
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
                       widget.engine.Delete('playlists/${snapshot.data[index]['playlist']}');
                     }
                   });
                   },
                   icon:  Icon(Icons.more_vert),
                   isDense: false,
                   ))
                     ],
                   );
                 },
                 itemCount:snapshot.data.length,))],
             );
        }),

        new Positioned(
            bottom: 25.0,
            right: 20.0,
            child: new GestureDetector(
              onTap: (){
                dialog(context);
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
    );
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
                child: new TextField(
                  controller: _controller,
                  maxLength: 10,autofocus: true,decoration: InputDecoration(
                  hintText: 'Enter playlist name'
                ),),
                width: 150,),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                new RaisedButton(
                  child: new Text('ok'),
                  onPressed: ()async {
                    await widget.engine.createplaylist(_controller.text);
                    print('Playlist created successfully');
                      playlists=await widget.engine.readPlaylists();
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


}
class selectSong extends StatefulWidget{
  final String playlistName;
  final androidEngine engine;
  final List<SongInfo> songs2;
  selectSong({this.playlistName,this.songs2,this.engine});
  @override
  selectSongState createState()=>selectSongState();
}
class selectSongState extends State<selectSong>{
  bool isChecked=false;
  List<SongInfo> checkedSongs=[];
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Scaffold(
      appBar: appBar(),
      body: new Stack(
        children: <Widget>[
          new Column(children: <Widget>[
            new Expanded(
              child: new ListView.builder(
                itemCount:widget.songs2.length,
                itemBuilder: (BuildContext context, int index){

                  return findPlaylistTile3(
                    height: height*0.1,
                    width: width,
                    title: AutoSizeText('${widget.songs2[index].title.trimLeft()}',style: new TextStyle(fontSize: 2,fontWeight: FontWeight.bold),
                      maxLines: 1,),
                    Artist: AutoSizeText('${widget.songs2[index].artist.trimLeft()}.${parseToMinutesSeconds(int.parse(widget.songs2[index].duration))}min',style: new TextStyle(fontSize: 2),
                      maxLines: 1,),
                    icon: FittedBox(child:widget.songs2[index].albumArtwork==null?Image.asset('Assets/Images/testImage.jpg',):
                    Image.file(File(widget.songs2[index].albumArtwork)),
                      fit: BoxFit.cover,),
                    checkTheBox: (checkedValue){
                      checkedSongs.add(widget.songs2[index]);
                      print('${widget.songs2[index].title} added to playlist');
                    },
                  );
                },
              ),
            )
          ],),
          new Positioned(
            bottom: 10,
            left: 50,
            child: new GestureDetector(onTap: () async{
              //Add the checked songs to Playlist
               if(checkedSongs.isNotEmpty) {
                 checkedSongs.forEach((element) async{
                   await widget.engine.addToPlaylist(widget.playlistName, element);
                   print('IT WORKED');
                 });
               }
               //Navigator.pop(context);
               
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>songListPlay(
                engine: widget.engine,
                playlistName: widget.playlistName,
                songs3: widget.songs2,
              )));
               
            },
            child: new Container(
              child:new Center(
                child:  new Text('Add to playlist ${widget.playlistName}',style: new TextStyle(
                    fontWeight: FontWeight.bold
                ),),
              ),
              decoration: new BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),offset: Offset(10,10),
                      blurRadius: 10)],
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.pink
              ),
              height: height*0.1,
              width: width*0.8,),),)
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