import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

/*
-creating instances for storage of
users
playlist
followers
following
-setting them to null initialy
-updating them with the users current info
 */
class DataBaseMethods{
 CollectionReference users=Firestore.instance.collection('users');
 CollectionReference followers=Firestore.instance.collection('songs');
 CollectionReference following=Firestore.instance.collection('following');
 CollectionReference playlist=Firestore.instance.collection('playlist');
 CollectionReference songs=Firestore.instance.collection('songs');
 CollectionReference request=Firestore.instance.collection('requests');
  // add new user to the database and initializes all parameters that are required;
 Future<void> createuser({String email,String password,String userId}) {
  Map<String, String> emptyu = {
    'username': userId,
    'email': email,
    'password': password
  };
  Map<String,String> empty=Map<String,String>();
   users.doc(userId).set(emptyu);
    playlist.doc(userId).set(empty);
    songs.doc(userId).set(empty);
    followers.doc(userId).set(empty);
    following.doc(userId).set(empty);
    request.doc(userId).set(empty);
  }
  //UPDATING THE REQUIRED PARAMETERS WITH NEW DATA ON FIREBASE

// first we would updater playlist then the rest would follow
Future<void> updatePlaylist({Map<String ,dynamic> data, String userId}){
    return playlist.doc(userId).set(data).then((value){print('playlist updated');})
       .catchError((value){print('failed to update due to error');
       print(value.toString());});
    QuerySnapshot querySnapshot;
}

  Future<void> updateSongs({Map data, String userId}){
    return songs.doc(userId).set(data).then((value){print('playlist updated');});
  }
  Future<void> updateRequest({Map data, String userId}){
    return request.doc(userId).set(data).then((value){print('playlist updated');})
        .catchError((value){print('failed to update due to error');});
  }
  Future<void> updateFollowers({Map data, String userId}){
    return followers.doc(userId).set(data).then((value){print('playlist updated');})
        .catchError((value){print('failed to update due to error');});
  }
  Future<void> updateFollowing({Map data, String userId}){
    return playlist.doc(userId).set(data).then((value){print('playlist updated');})
        .catchError((value){print('failed to update due to error');});
  }
  Future<DocumentSnapshot> getFollowers(String userId){
   return FirebaseFirestore.instance.collection('followers').doc(userId).get();
}
  Future<DocumentSnapshot> getFollowing(String userId){
   return FirebaseFirestore.instance.collection('following').doc(userId).get();
}
  Future<DocumentSnapshot> getSongs(String userId){
   return FirebaseFirestore.instance.collection('songs').doc(userId).get();
}
  Future<DocumentSnapshot> getPlaylist(String userId){
    return FirebaseFirestore.instance.collection('playlist').doc(userId).get();
  }
  Future<QuerySnapshot> getRequest(String userid){
    return FirebaseFirestore.instance.collection('requests')
    .where('sentby',isEqualTo: userid).getDocuments();
  }
  Future<QuerySnapshot> getUserCollection(String collec){
     //QueryDocumentSnapshot queryDocumentSnapshot;

   return FirebaseFirestore.instance.collection(collec).get();
  }
  // We have to implement the search function
  // We have to implement the request functionality
  Future<bool> sendRequest({String userId,String title,String artist}){
    request.doc(userId).set({
      'sentby':userId,
      'title':title,
      'artist':artist
    }).then((value) {
      return true;
    }).catchError((error){
      return false;
    });
    //.then((value)=> print("user added"))
    //.catchError((error)=>print("Failed to add user"));
  }

}
