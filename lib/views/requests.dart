import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musicApp/firebase_methods.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:musicApp/android_methods.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
/*
class requestApp extends StatefulWidget{
  @override
   requestAppState createState()=> requestAppState();
}
requestAppState
State<requestApp>
 */
const fetchBackground='fetchBackground';
bool hasUploaded=false;
bool hasStartedUploading=false;
bool isUploading=false;

void callbackDispatcher(){
  Workmanager.executeTask((taskName, inputData) async {
    //Function to upload file to fireStore
    print('Function is called');
    final FirebaseStorage storage=new FirebaseStorage(storageBucket: 'gs://nanobits-83f2b.appspot.com');
    UploadTask uploadTask;
    print('FIREBASE INSTANCE HAS BEEN INITIALIZED');
    switch(taskName){
      case fetchBackground:
        hasStartedUploading=true;
        hasUploaded=false;
        isUploading=true;
        int index=inputData['index'];

       // Notification notification=new Notification();
        //notification.showNotification('${inputData['title']} is uploading');
        print('THE FILE HAS STARTED UPLOADING');
          uploadTask=storage.ref().child('${inputData['docid']}/songs/${inputData['title']}.mp3').putFile(File(inputData['filepath']));
          uploadTask.snapshotEvents.listen((event) {
          },onDone: (){
            hasUploaded=true;
            isUploading=false;
            hasStartedUploading=false;
            print('THE FILE HAS BEEN UPLOADED');
            //notification.showNotification('${inputData['title']} has been uploaded');
          },onError: (error){
             print('AN ERROR OCCURED IN THE PROGRAM');
             //notification.showNotification('${inputData['title']} was not uploaded');
          });


        //show the notificaton given the parameter

    }
    return Future.value(true);
  });
}

class requestApp extends StatefulWidget {
  final DataBaseMethods cloud;
  final List<SongInfo> songs;
  requestApp({@required this.cloud,this.songs});
  @override
  requestAppState createState()=>requestAppState();
}
class requestAppState extends State<requestApp>{
  androidEngine engine=new androidEngine();
  File mp3;
  String docid;
  List songs;
  String title;

  @override
  void initState() {
    Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );


  }
  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
    // TODO: implement build
    return new Container(
          height: height,
          width: width,
          child:  new Column(
            children: <Widget>[
             new Container(
               padding: EdgeInsets.only(
                 top: height*0.02,
                 left: width*0.2
               ),
               height: height*0.08,
               width: width,
               child:  new Text('Notificatons',
               style: new TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 25
               ),),
             ),
             new StreamBuilder(
               stream: widget.cloud.getRequest('msughter_request').asStream(),
                 builder: (context,snapshot){
               if(!snapshot.hasData){
                 return Container(
                   child: new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),),
                   margin: EdgeInsets.all(5.0),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                     color: Colors.white,

                   ),
                 );
               }
               else if(snapshot.connectionState==ConnectionState.waiting && snapshot.data.docs.isEmpty){
                 return Container(
                   child: new Center(child: new CircularProgressIndicator(backgroundColor: Colors.pink,),),
                   margin: EdgeInsets.all(5.0),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                     color: Colors.white,

                   ),
                 );
               }

               else if(snapshot.connectionState==ConnectionState.done && snapshot.data.docs.isEmpty){
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
               return new Expanded(child:new ListView.builder(
                   itemCount: snapshot.data.docs.length,
                   itemBuilder: (BuildContext context, int index){
                     return new requestTile(
                       pressed: (){
                         int indx=widget.songs.indexWhere((element) => element.title==snapshot.data.docs[index].data()['title']);
                         setState(() {
                           title=snapshot.data.docs[index].data()['title'];
                           mp3=File(widget.songs[indx].filePath);
                           songs=widget.songs;
                           docid='msughter_request';
                         });
                         Workmanager.registerPeriodicTask(
                             "1",
                             fetchBackground,
                             frequency: Duration(minutes: 15),
                             inputData: {
                               'docid':docid,
                               'title':title,
                               'index':indx,
                               'filepath':widget.songs[indx].filePath
                             }
                         );
                       },
                       songs: widget.songs,
                        artist: snapshot.data.docs[index].data()['artist'],
                       title: snapshot.data.docs[index].data()['title'],
                       icon: FittedBox(child: Image.asset('Assets/Images/testImage.jpg',),
                         fit: BoxFit.cover,),
                       height: 130,
                       width: width,
                       sentby: snapshot.data.docs[index].data()['sentby'],
                       docid: snapshot.data.docs[index].id,
                     );
                   }),);
             })
            ],
          ),

      );
  }


}


class requestTile extends StatefulWidget {
  final double height;
  final double width;
  final String sentby;
  final String artist;
  final String title;
  final String docid;
  final Widget icon;
  final List<SongInfo> songs;
  final Function pressed;
  requestTile(
      {this.height, this.width, this.sentby, this.icon, this.artist, this.title,this.songs,this.docid,this.pressed});
  @override
  requestTileState createState()=>requestTileState();
}
class requestTileState extends State<requestTile>{
  bool processing =false;
  androidEngine engine=new androidEngine();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  new Container(
      height: widget.height,
      width: widget.width,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          new Row(
            children: <Widget>[
      new Container(
      height: 80,
        width: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(300.0),
          child: widget.icon,
        ),
      ),
              new SizedBox(width: 10,),
              new Container(
                height: 80,
                width: 250,
                child: new RichText(
                    maxLines: 5,
                    text: TextSpan(
                        text:'${widget.sentby} ',
                        style: new TextStyle(color: Colors.black),
                        children: [
                          TextSpan(text: 'wants to listen to ',style: TextStyle(color: Colors.black),),
                          TextSpan(text: '${widget.title} ' ,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                          TextSpan(text: 'by ',style: TextStyle(color: Colors.black)),
                          TextSpan(text: '${widget.artist} ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                          TextSpan(text: 'From your playlist',style: TextStyle(color: Colors.black))
                        ]
                    )),
              )
            ],
          ),
          processing==true?new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new CircularProgressIndicator(backgroundColor: Colors.pink,)
            ],):new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Container(
                height: 30,
                width: 85,
                child: new RaisedButton(
                  child: new Text('Accept'),
                  onPressed: () async{
                    // There are many ways to kill a rat
                    setState(() {
                      processing=false;
                    });
                    int index=widget.songs.indexWhere((element) => element.title==widget.title);
                    String filepath=widget.songs[index].filePath;
                    String artpath=widget.songs[index].albumArtwork;
                    print('THE ARTWORK THAT HAS BEEN GIVING US PROBLEM ${artpath}');
                    String encodedFile=await engine.mp3Tobase64(path:filepath);
                    //String encodedArt=await engine.mp3Tobase64(path:artpath);
                   widget.pressed();
                  },color: Colors.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)
                  ),),
              ),
              new Container(
                height: 30,
                width: 85,
                child: new RaisedButton(
                  child: new Text('Decline'),
                  onPressed: (){},color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)
                  ),),
              ),

            ],
          ),
        ],
      ),
    );
  }
}

enum states{
  none,
  sending,
  sent
}

class Notification{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future showNotification(String text) async {
    var androidPlatformChannelSpecifics=new AndroidNotificationDetails('1',
    'uploadtask','fetch uploadtask in background',
    playSound: false,importance: Importance.max,priority: Priority.high);
    var IOSPlatformChannelSpecifics=new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics=new NotificationDetails(
      android: androidPlatformChannelSpecifics,iOS: IOSPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'uploaded',
      '${text}',
      platformChannelSpecifics,
      payload: ''
    );
  }
  Notification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(iOS: initializationSettingsIOS,
    android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

}