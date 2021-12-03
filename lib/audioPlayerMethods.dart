import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

AudioPlayer Aplayer=AudioPlayer();
MediaControl playControl=MediaControl(
  androidIcon: 'drawable/play',
  label: 'Play',
  action: MediaAction.play
);

MediaControl skipToNextControl=MediaControl(
    androidIcon: 'drawable/skip_to_next',
    label: 'Next',
    action: MediaAction.skipToNext
);

MediaControl skipToPreviousControl=MediaControl(
    androidIcon: 'drawable/skip_to_previous',
    label: 'Previous',
    action: MediaAction.skipToPrevious
);

MediaControl stopControl=MediaControl(
    androidIcon: 'drawable/stop',
    label: 'Stop',
    action: MediaAction.stop
);


class MyBackgroundTask extends BackgroundAudioTask {

  List<MediaItem> _qeue=[];
  Seeker _seeker;
  int get index=> Aplayer.currentIndex;
  AudioProcessingState _skipState;
  StreamSubscription<PlaybackEvent> _eventSubscription;
  MediaItem get mediaItem => index==null?null:_qeue[index];

  // Initialise your audio task.
  @override
  Future<void> onStart(Map<String, dynamic> params) async{
    print('something went wrong');
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    _qeue.clear();
    List mediaItems = params['data'];
    for (int i = 0; i < mediaItems.length; i++) {
      MediaItem mediaItem = MediaItem.fromJson(mediaItems[i]);
      _qeue.add(mediaItem);
    }
    Aplayer.currentIndexStream.listen((index){
      if(index!=null)AudioServiceBackground.setMediaItem(_qeue[index]);
    });

    _eventSubscription=Aplayer.playbackEventStream.listen((event) {
      _broadcastState();
    });
    Aplayer.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
        // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.loading:
          break;
        case ProcessingState.ready:
        // If we just came from skipping between tracks, clear the skip
        // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    AudioServiceBackground.setQueue(_qeue);
    _loadFiles();
  }


  _loadFiles() async{
    List<AudioSource> _audioSource=[];
    _qeue.forEach((element) {
      _audioSource.add(AudioSource.uri(
        Uri.parse(element.id)
      ));
    });
    try{
      await Aplayer.load(
          ConcatenatingAudioSource(children: _audioSource)
      );
      onPlay();
    } catch(e){
      print("SOMETHING WENT WRONG");
      print("Error:$e");
      onStop();
    }
  }
  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = _qeue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    Aplayer.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<Function> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) {
    if(shuffleMode==AudioServiceShuffleMode.all){
      Aplayer.setShuffleModeEnabled(true);
    }
    else{
      Aplayer.setShuffleModeEnabled(false);
    }
  }

  @override
  Future<Function> onSetRepeatMode(AudioServiceRepeatMode repeatMode) {
    if(repeatMode==AudioServiceRepeatMode.one){
      Aplayer.setLoopMode(LoopMode.one);

    }
    else if(repeatMode==AudioServiceRepeatMode.all){
      Aplayer.setLoopMode(LoopMode.all);

    }
    else{
      Aplayer.setLoopMode(LoopMode.off);
    }
  } // Handle a request to stop audio and finish the task.
  @override
  Future<void> onStop() async {
    await Aplayer.pause();
    await Aplayer.dispose();
    _eventSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }
  // Handle a request to play audio.
  @override
  Future<void> onPlay() {
    Aplayer.play();
  }
  // Handle a request to pause audio.
  @override
  Future<void> onPause() {
    Aplayer.pause();
  }
  // Handle a headset button click (play/pause, skip next/prev).
  @override
  Future<void> onClick(MediaButton button) {

    if(button.index==1){
      print('THE BUTTON INDEX IS${button.index}');
      onSkipToNext();
    }
    else if(button.index==2){
      print('THE BUTTON INDEX IS${button.index}');
      onSkipToPrevious();
    }
    else{
      playPause();
    }
  }
  // Handle a request to skip to the next queue item.
  @override
  Future<void> onSkipToNext() {
    Aplayer.seekToNext();
    if(!Aplayer.playing){
      Aplayer.play();
    }
  }
  // Handle a request to skip to the previous queue item.
  onSkipToPrevious() {
    Aplayer.seekToPrevious();
    if(!Aplayer.playing){
      Aplayer.play();
    }
  }
  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);
  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);
  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);
  // Handle a request to seek to a position.
  @override
  Future<void> onSeekTo(Duration position) {
    Aplayer.seek(position);
  }
  void playPause() {
    if (AudioServiceBackground.state.playing)
      onPause();
    else
      onPlay();
  }
  Future<void> _seekRelative(Duration offset) async{
    var newPosition=Aplayer.position+offset;
    if(newPosition<Duration.zero) newPosition=Duration.zero;
    if(newPosition >mediaItem.duration) newPosition=mediaItem.duration;

    await Aplayer.seek(newPosition);
  }

  void _seekContinuously(bool begin, int direction){
       _seeker?.stop;
       if(begin){
         _seeker=Seeker(player: Aplayer,mediItem:mediaItem,
             positionInterval: Duration(seconds: 10*direction),
         stepInterval: Duration(seconds: 1))..start();
       }
  }
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (Aplayer.playing) MediaControl.pause else MediaControl.play,
        //MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      processingState: _getProcessingState(),
      playing: Aplayer.playing,
      position: Aplayer.position,
      bufferedPosition: Aplayer.bufferedPosition,
      speed: Aplayer.speed,
    );
  }
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (Aplayer.processingState) {
      case ProcessingState.none:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${Aplayer.processingState}");
    }
  }
}

class Seeker{
  final AudioPlayer player;
  final Duration positionInterval;
  final MediaItem mediItem;
  final Duration stepInterval;
  bool _running=false;
  Seeker({this.player,
  this.mediItem,
  this.positionInterval,
  this.stepInterval
  });

  start() async{
    _running=true;
    while(_running){
      Duration newPosition=player.position+positionInterval;
      if(newPosition<Duration.zero)newPosition=Duration.zero;
      if(newPosition>mediItem.duration)newPosition=mediItem.duration;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }
  stop(){
    _running=false;
  }
}