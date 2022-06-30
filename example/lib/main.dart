import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cast_video/flutter_cast_video.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CastSample()
    );
  }
}

class CastSample extends StatefulWidget {
  static const _iconSize = 50.0;

  @override
  _CastSampleState createState() => _CastSampleState();
}

class _CastSampleState extends State<CastSample> {
  late ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool _playing = false;
  Map<dynamic,dynamic> _mediaInfo = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin example app'),
        actions: <Widget>[
          AirPlayButton(
            size: CastSample._iconSize,
            color: Colors.white,
            activeColor: Colors.amber,
            onRoutesOpening: () => print('opening'),
            onRoutesClosed: () => print('closed'),
          ),
          ChromeCastButton(
            size: CastSample._iconSize,
            color: Colors.white,
            onButtonCreated: _onButtonCreated,
            onSessionStarted: _onSessionStarted,
            onSessionEnded: () => setState(() => _state = AppState.idle),
            onRequestCompleted: _onRequestCompleted,
            onRequestFailed: _onRequestFailed,
          ),
        ],
      ),
      body: Center(child: _handleState()),
    );
  }

  Widget _handleState() {
    switch(_state) {
      case AppState.idle:
        return Text('ChromeCast not connected');
      case AppState.connected:
        return Text('No media loaded');
      case AppState.mediaLoaded:
        return _mediaControls();
      case AppState.error:
        return Text('An error has occurred');
      default:
        return Container();
    }
  }

  Widget _mediaControls() {
    return
    Column(
     children:[

      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _RoundIconButton(
          icon: Icons.replay_10,
          onPressed: () => _controller.seek(relative: true, interval: -10.0),
        ),
        _RoundIconButton(
            icon: _playing
                ? Icons.pause
                : Icons.play_arrow,
            onPressed: _playPause
        ),
        _RoundIconButton(
          icon: Icons.forward_10,
          onPressed: () => _controller.seek(relative: true, interval: 10.0),
        ),

      ],
    )
      ,
    Text(jsonEncode(_mediaInfo))
    ]
    )
    ;
  }

  Future<void> _playPause() async {
    final playing = await _controller.isPlaying();
    if (playing == null) return;
    if(playing) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    setState(() => _playing = !playing);
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    setState(() => _state = AppState.connected);
    await _controller.loadMedia('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', title: "TestTitle",
      subtitle: "test Sub title",
      image: "https://smaller-pictures.appspot.com/images/dreamstime_xxl_65780868_small.jpg"
    );
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    if (playing  == null) return;
    final mediaInfo = await _controller.getMediaInfo();
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
      if (mediaInfo !=null) {
        _mediaInfo = mediaInfo;
      }
    });
  }

  Future<void> _onRequestFailed(String? error) async {
    setState(() => _state = AppState.error);
    print(error);
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  _RoundIconButton({
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Icon(
            icon,
            color: Colors.white
        ),
        padding: EdgeInsets.all(16.0),
        color: Colors.blue,
        shape: CircleBorder(),
        onPressed: onPressed
    );
  }
}

enum AppState {
  idle,
  connected,
  mediaLoaded,
  error
}
