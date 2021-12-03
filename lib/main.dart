import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:musicApp/views/Simplewidgets.dart';
import 'package:flutter/material.dart';
import 'package:musicApp/views/requests.dart';
import 'firebase_methods.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'android_methods.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:musicApp/views/musicPlayer.dart';
import 'package:musicApp/views/songsPlay.dart';
import 'package:musicApp/views/createPlaylist.dart';
import 'package:musicApp/views/requests.dart';
import 'package:musicApp/views/forYou.dart';
import 'package:musicApp/views/logIn.dart';
import 'package:audio_service/audio_service.dart';
import 'package:auto_size_text/auto_size_text.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SimplePermissions.requestPermission(permissionFromString('Permission.WriteExternalStorage'));
  await SimplePermissions.requestPermission(permissionFromString('Permission.ReadExternalStorage'));
  //await FirebaseFirestore.instance.clearPersistence();
  // Web.
  //await FirebaseFirestore.instance.enablePersistence();

// All other platforms.
 // FirebaseFirestore.instance.settings =
  //    Settings(persistenceEnabled: false);
  //List<SongInfo> songs=await androidEngine.getSongs();
  //List<SongInfo> songs3=[];
  //print(songs.where((element) => songs3.contains(element)==false));
  //songs3.addAll(songs.where((element) => songs3.contains(element)==false));
  //print(songs3[0]);
  //var encoded_data=jsonEncode(songs3[0].toString());
  //print(jsonDecode(encoded_data));
  //DataBaseMethods.createuser(email: 'ekeke',username: 'dkdkdkd',password: 'kwkkw');
  runApp(MaterialApp(
    home:AudioServiceWidget(child:Home(engine: androidEngine(),cloud: DataBaseMethods(),)),
  ));
}


/*
class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      home:Home() ,
    );
  }
}

 */


class Home extends StatefulWidget{
  final androidEngine engine;
  final DataBaseMethods cloud;
  Home({@required this.engine,@required this.cloud});
  @override
  HomeState createState()=>HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin{
  int _current=0;
  Permission _permissionRead;
  Permission _permissionWrite;
  TabController _tabController;
  int _selectedIndex=0;
  bool _showFloatingButton=false;
  List<SongInfo> songs;
  Map cloudSongs;
  List<Map> toUpload=new List<Map>();
  List toUploadT=new List();
  List toUploadA=new List();
  List toUploadArt=new List();
  List toUploadF=new List();
  List toUploadD=new List();
  List filterIndex=[];
  List<Map> test=[];
  @override
  void initState() {
    super.initState();
    widget.engine.getSongs().then((List<SongInfo> songinfo){
      setState(() {
        songs=songinfo;

        try{
          widget.cloud.getPlaylist('msughter_playlist').then((DocumentSnapshot documentSnapshot){
            if(documentSnapshot.exists){
              print('documents exists');
              print('documents snapshot data is currently ${documentSnapshot.data()}');
              songs.forEach((element) {
                Map data=new Map();
                data['title']=element.title;
                data['artist']=element.artist;
                data['album']=element.album;
                data['duration']=element.duration;
                data['filesize']=element.fileSize;
                toUpload.add(data);
                // data.clear();

              });
              cloudSongs=documentSnapshot.data();
              //print(toUpload.toSet().difference(cloudSongs.toSet()));
              print(documentSnapshot.data().isNotEmpty);
              if(documentSnapshot.data().isNotEmpty){
                print('PRINT IS CLOUD SONGS EMPTY ${cloudSongs.isEmpty}');
                print('TO UPLOAD SONGS EMPTY ${toUpload.isEmpty}');
                for(int i=0;i<songs.length;i++){
                  //filterIndex.add(toUpload.indexWhere((element) => element['title']==cloudSongs[i]['title']));
                  toUpload.removeAt(toUpload.indexWhere((element) => element['title']==cloudSongs['title'][i]));
                  //toUpload.removeAt(toUpload.indexWhere((element) => element['artist']==cloudSongs['artists'][i]));
                  //toUpload.removeAt(toUpload.indexWhere((element) => element['duration']==cloudSongs['durations'][i]));
                  //toUpload.removeAt(toUpload.indexWhere((element) => element['filesize']==cloudSongs['filesizes'][i]));
                  //toUpload.removeAt(toUpload.indexWhere((element) => element['album']==cloudSongs['albums'][i]));
                  //print(toUpload[i]['title']);
                  filterIndex.add(toUpload.indexWhere((element) => element['title']==cloudSongs['title'][i]));
                  print(toUpload.indexWhere((element) => element['title']==cloudSongs['title'][i]));
                  print('filterInded songs length is ${filterIndex.length}');
                  print('Cloud songs length is ${cloudSongs['title'].length}');
                  print('To upload songs length is ${toUpload.length}');
                }
                toUpload.forEach((data) {
                  toUploadA.add(data['artist']);
                  toUploadArt.add(data['album']);
                  toUploadD.add(data['duration']);
                  toUploadF.add(data['filesize']);
                  toUploadT.add(data['title']);
                });
                var titles=List.from(cloudSongs['title'])..addAll(toUploadD);
                var artists=List.from(cloudSongs['artists'])..addAll(toUploadA);
                var albums=List.from(cloudSongs['albums'])..addAll(toUploadArt);
                var duration=List.from(cloudSongs['durations'])..addAll(toUploadD);
                var filesizes=List.from(cloudSongs['filesizes'])..addAll(toUploadF);

                print('UPDATED 2');
                widget.cloud.updatePlaylist(userId: 'msughter_playlist',data: {
                  'title':titles,
                  'artists':artists,
                  'albums':albums,
                  'durations':duration,
                  'filesizes':filesizes});

              }
              else{
                toUpload.forEach((data) {
                  toUploadA.add(data['artist']);
                  toUploadArt.add(data['album']);
                  toUploadD.add(data['duration']);
                  toUploadF.add(data['filesize']);
                  toUploadT.add(data['title']);
                });
                print('I AM IN THIS SECTION');
                print(toUploadT.isEmpty);
                widget.cloud.updatePlaylist(userId: 'msughter_playlist',data: {'title':toUploadT,
                  'artists':toUploadA,
                  'albums':toUploadArt,
                  'durations':toUploadD,
                  'filesizes':toUploadF});
              }

            }
            else{
              print('documents snapshot does not exist');
            }
          });
        }
        catch(e){
          print(e.toString());
        }
        //print(songs[2]);
        //cloudSongs.clear();
        //toUpload.clear();
      });
    });
    _tabController= TabController(length:5, vsync: this,);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex=_tabController.index;
      });

    });
    _permissionRead=permissionFromString('Permission.ReadExternalStorage');
    _permissionWrite=permissionFromString('Permission.WriteExternalStorage');


  }


  @override
  void dispose() {
    super.dispose();

  }
  Future<void> checkConnection() async{
    await AudioService.connect();
  }

  @override
Widget build(BuildContext context){
    print(_tabController.index);
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
return new Scaffold(
  body:TabBarView(
    dragStartBehavior: DragStartBehavior.down,
  controller: _tabController,
  children: <Widget>[
    songs!=null?songList(songinfo: songs,):new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),),
    HomeBody(width: width,height: height,cloud: widget.cloud,),
    forYou(),
    createPlaylist(songs: songs,engine: widget.engine,),
  requestApp(cloud: widget.cloud,songs: songs,),
  ],
) ,
appBar: appBar(),
bottomNavigationBar:songs!=null?new GestureDetector(
  onTap: (){
    if(isPlaying){
      int indexofAudio=songs.indexWhere((element)=>
      'file://${element.filePath}'==AudioService.currentMediaItem.id);
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
          player(playlist: 'My Songs',songs: songs,currentIndex: indexofAudio,songinfo:songs[indexofAudio],)));
    }
  },
  child: myBottomNavBar(
  playlist: 'My Songs',
  songs: songs,
  indeX: _tabController.index,
  tabFunction: (int index){
    setState(() {

      _tabController.index=index;
    });

  },),): new Text('Loading Your Songs',style: new TextStyle(color: Colors.pink,fontSize: 15),),);
}
}

class HomeBody extends StatefulWidget {
  final double height;
  final double width;
  final DataBaseMethods cloud;

  HomeBody({this.width, this.height,this.cloud});
  HomeBodyState createState()=>HomeBodyState();
}


class HomeBodyState extends State<HomeBody>{
  String whosePlaylist='';
  int userIndex=0;
  int usersLength=0;
  List usersList=[];
  //List btemp=[];
  bool hasdata=false;
  int playlength=0;
  List<buttonState> bstates;
  buttonState bstate=buttonState.none;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
     bstates=List.filled(playlength, buttonState.none);
    return new Container(
      height: widget.height,
      width: widget.width,
      child: new Column(children: <Widget>[
      new Container(
        height: widget.height*0.08,
        width: widget.width,
        child: Column(
          children: <Widget>[
            new Text('Discover',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
            new Text('Top playlist'),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,),),
      new StreamBuilder(
        stream: widget.cloud.getUserCollection('playlist').asStream(),
          builder: (context,snaphotUser){
          print('WE HAVE ENTERED HERE');
        if(!snaphotUser.hasData){
          return Container(
            child: new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,

            ),
          );
        }
         else if(snaphotUser.connectionState==ConnectionState.waiting && snaphotUser.data.docs.isEmpty){
            return Container(
              child: new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),),
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Colors.white,

              ),
            );
          }

        else if(snaphotUser.connectionState==ConnectionState.done && snaphotUser.data.docs.isEmpty){
          return Container(
            child: new Column(
              children: [
                new Center(child: new Text('OOOpss sorry there is no internet connection !!!',style: new TextStyle(color: Colors.pink),),),
                new Center(child: new Text('try again later',style: new TextStyle(color: Colors.pink),),),
                new RaisedButton(onPressed: (){
                 setState(() {
                   //usersLength=snaphotUser.data.docs.length;
                   //usersList=snaphotUser.data.docs;
                 });
                },child: new Text('Refresh'),)
              ],
            ),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,

            ),
          );
        }
          usersList=snaphotUser.data.docs;
          usersLength=snaphotUser.data.docs.length;
         // bstates=List.filled(usersLength, buttonState.none);

          hasdata=true;
          //print('${usersList[0].id}');

        return new Expanded(child: new Column(
          children: [
            CarouselSlider.builder(
              //initialPage: 0,
              height: widget.height*0.3,
              onPageChanged: (int index){
                //Do something with the index when the page has changed
                setState(() {
                  userIndex=index;
                });
              },
              enlargeCenterPage: true,
              aspectRatio: 16/9,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.7,
              itemCount: usersLength,
              itemBuilder: (BuildContext context,int index){
                return new StreamBuilder(
                    stream: widget.cloud.getUserCollection('playlist').asStream(),
                    builder: (context,snaphot){
                      if(!snaphot.hasData){

                        return Container(
                          child: new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),),
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.white,

                          ),
                        );
                      }
                      else if(snaphot.hasError){
                        return Container(
                          child: new Center(child: new Text('OOOpss sorry there is no internet connection'),),
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.white,

                          ),
                        );
                      }
                      return Container(
                        margin:EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                                image: AssetImage('Assets/Images/testImage.jpg'),
                                fit: BoxFit.cover
                            )
                        ),
                      );
                    });
              },
            ),
            new Container(
              alignment: Alignment.center,
              height: widget.height*0.05,
              width: widget.width,
              child: new Text('${usersList[userIndex].id}'.replaceAll('_', '\'s '),style: new TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 25),),
            ),
            new StreamBuilder(
                stream:widget.cloud.getPlaylist(usersList[userIndex].id).asStream(),
                builder: (context,snapshot){
                  if(!snapshot.hasData){
                    return new Center(
                      child: new CircularProgressIndicator(backgroundColor: Colors.pink,),
                    );
                  }
                  else if(snapshot.hasError){
                    return Container(
                      child: new Center(child: new Text('OOOpss sorry there is no internet connection'),),
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.white,

                      ),
                    );
                  }
                  return snapshot.data.data().isEmpty? new Center(child: new Column(children: [
                    new SizedBox(height: widget.height*0.07,),
                    new Text('No Songs Found in This Playlist')
                  ],),):new Expanded(
                    child: new ListView.builder(
                        itemCount: snapshot.data['title'].length,
                        itemBuilder:
                            (BuildContext context, int index){
                          return findPlaylistTile(
                            A:snapshot.data['artists'][index] ,
                            T: snapshot.data['title'][index],
                            U: "msughter_request",
                            onPressed: (){
                              print('WE ARE CALLED${snapshot.data['artists'][index]}');
                              //return bstate;
                            },
                            width: widget.width,
                            isavailable: false,
                            height: widget.height*0.1,
                            title: AutoSizeText('${snapshot.data['title'][index].trimLeft()}',style: new TextStyle(fontSize: 5,fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                            Artist:AutoSizeText('${snapshot.data['artists'][index].trimLeft()}',style: new TextStyle(fontSize: 5,fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                            icon: FittedBox(child: Image.asset('Assets/Images/testImage.jpg',),
                              fit: BoxFit.cover,),);
                        }),
                  );
                })
          ],
        ));
      }),


    ],),);
  }


}

class buttonData{
 final buttonState state;
 final int index;
 buttonData(this.state,this.index);
}

