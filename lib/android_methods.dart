import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_audio_query/flutter_audio_query.dart';

/*
 -we need a function to read all the mp3 files available
 -we need a function to cache the directories of the songs,
   their title,artist,thumbnail picture, their discovery timestamp,
   and other properties
 -we need a function to clear all the properties from cache when the documents
  are not found in their reference directories
 - we need a function to make sure we are not getting duplicate songs from
   multiple directories
 -function to get the applications document documents directory
 */

Permission permissionFromString(String value){
  Permission permission;
  for (Permission item in Permission.values){
    if (item.toString()==value){
      permission=item;
    }
  }
  return permission;
}

class androidEngine{
//Get Applications Documents
 Future<String> getdir() async{
   final directory=await getApplicationDocumentsDirectory();
   return directory.path;
 }

 //Make directories in the Applications Documents Directory
Future<String> mkdir(String path) async{
   final dir= await getdir();
   final directory= await Directory('${dir}/${path}');
   if(await directory.exists()){
     return directory.path;
   }
   else {
     Directory newDirectory=await directory.create(recursive: true);
     return newDirectory.path;
   }
}

Future<List<SongInfo>> getSongs(){
   return FlutterAudioQuery().getSongs(sortType: SongSortType.ALPHABETIC_ARTIST);
}
// Write playtimes for a single song
writePlayTimes({SongInfo songinfo,int timesPlayed,String path}) async{
   var encoded_info=jsonEncode(songinfo.toString());
   Map data={'info':encoded_info,'timesPlayed':timesPlayed.toString()};
   var encoded_data=jsonEncode(data.toString());
  String dir=await getdir();
   File ('${dir}/${path}/${songinfo.toString()}').writeAsString(encoded_data);
}
//Read playtimes for a all the songs
Future<List<Map>> readPlayTimes(String path) async{
   String dir=await getdir();
   final directory= await Directory('${dir}/${path}');
   List<Map> data=List<Map>();
   await for (FileSystemEntity entity in directory.list(recursive: false,followLinks: false )){
     File e =File(entity.path);
     var value=await e.readAsString();
     data.add(jsonDecode(value));
   }
}
createplaylist(String path){
   mkdir('playlists/${path}');

}
Future<void> addToPlaylist(String filepath,SongInfo song) async{
   String dir=await getdir();
   var encoded_info=jsonEncode(song.toString());
     await mkdir('${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}');
     File('${dir}/${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}/id').writeAsString(song.filePath.toString());
     File('${dir}/${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}/album').writeAsString(song.album.toString());
     File('${dir}/${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}/artist').writeAsString(song.artist.toString());
     File('${dir}/${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}/duration').writeAsString(song.duration.toString());
     File('${dir}/${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}/artUri').writeAsString(song.albumArtwork.toString());
     File('${dir}/${'playlists'}/${filepath}/${path.basenameWithoutExtension(song.filePath)}/title').writeAsString(song.title.toString());

   //final directory=await Directory('${dir}/${'playlists'}/${path}');
}
Future<List<Map>> readFromPlaylist(String filepath) async{
   String dir=await getdir();
   List<Map> maps=[];
   print('I AM HERE');
   int _count=0;
   final directory=await Directory('${dir}/${'playlists'}/${filepath}');
   await for (FileSystemEntity entity in directory.list(recursive: false,followLinks: false )) {
     print(entity.path);
     //File e = File(entity.path);
     //var value = await e.readAsString();
     //print(value);

     //data.add(jsonDecode(value));
     Directory direc=await Directory(entity.path);
     Map data=new Map();
     await for (FileSystemEntity ent in direc.list(recursive: false,followLinks: false)){
       if(path.basename(ent.path)=='id'){

         File id=new File(ent.path);
         data['id${_count}']=await id.readAsString();
       }
       else if(path.basename(ent.path)=='album'){
         File album=new File(ent.path);
         data['album${_count}']=await album.readAsString();
       }
       else if(path.basename(ent.path)=='artist'){
         File artist=new File(ent.path);
         print(await artist.readAsString());
         data['artist${_count}']=await artist.readAsString();
       }
       else if(path.basename(ent.path)=='duration'){
         File duration=new File(ent.path);
         data['duration${_count}']=await duration.readAsString();
       }
       else if(path.basename(ent.path)=='artUri'){
         File artUri=new File(ent.path);
         data['artUri${_count}']=await artUri.readAsString();
       }
       else{
         File title=new File(ent.path);
         data['title${_count}']=await title.readAsString();
         //data['title${_count}']
         //print(await title.readAsString());
       }
     }
     maps.add(data);
     _count++;
   }
   //print('FIRST DATA IS ${maps[0]}');
   return maps;
}

Future<List<Map<String,String>>> readPlaylists() async{
   String dir=await getdir();
   List<Map<String,String>> playlists=[];
   final directory=await Directory('${dir}/${'playlists'}');
   int _count=0;
   await for(FileSystemEntity entity in directory.list(recursive: false,followLinks: false)){

     List<Map> songs=await readFromPlaylist(path.basename(entity.path));
     print('SOMETHING WENT WRONG');
     //print(songs.first);
     playlists.add({
       'artUri':songs.isEmpty?null:songs[0]['artUri${0}'],
       'playlist':path.basename(entity.path)
     });
    // print(songs[0].filePath);
     _count++;
   }
   return playlists;
  }

verifyCachedList(List<SongInfo> songs,List<Map> cahcedSongs,String path){
   final dir=getdir();
   final directory=Directory("${dir}/${path}");
   List songsString=[];
   songs.forEach((element) {
     songsString.add(element.toString());});
   List cahcedList =[];
   cahcedSongs.forEach((element) {
     cahcedList.add(element['info']);
   });
   List union=cahcedList.where((element) => songsString.contains(element)==false);
   for (String item in union){
     final deldir=Directory('${directory.path}/${item}');
     Delete(deldir.path);
   }
   List union2=songsString.where((element)=> cahcedList.contains(element)==false);

   for (String item in union2){
     final deldir=Directory('${directory.path}/${item}');
     Delete(deldir.path);
   }

}

  Future<void> Delete(String filepath)async{
    //Delete all the files in the directory
    final basepath=await getdir();
    final dir=Directory('${basepath}/${filepath}');
    dir.deleteSync(recursive: true);
    //Delete the directory
    // dir.delete(recursive: true);
  }

  Future<String> mp3Tobase64({String path})async{
   final dir=await getdir();
   File file=File('${path}');
   List<int> fileBytes=await file.readAsBytes();
   String base64String=base64Encode(fileBytes);
   return jsonEncode(base64String);
  }
  //Function to convert base64String to mp3
   base64Tomp3({String base64String}){
   return base64Decode(base64String);
  }

  writeSongToStorage(){

  }
}

