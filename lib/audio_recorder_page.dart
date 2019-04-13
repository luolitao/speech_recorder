import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

// Files used by this package
import 'package:audio_recorder/audio_recorder.dart';
import 'save_dialog.dart';

String fileName = 'assets/speech.txt';
var speechUrl =
    'https://gist.githubusercontent.com/luolitao/373eeef67bf3245dc94af526d58be030/raw/d3d4860d98a9c2b9da44942ecd9960d7a2b189c4/speech.txt';

class AudioRecorderPage extends StatefulWidget {
  AudioRecorderPage({Key key}) : super(key: key);

  @override
  AudioRecorderPageState createState() {
    return new AudioRecorderPageState();
  }
}

class AudioRecorderPageState extends State<AudioRecorderPage> {
  // The AudioRecorderPageState holds info based on
  // whether the app is currently
  // FIXME! Disable TabController when recording

  Recording _recording = new Recording();
  bool _isRecording = false;
  bool _doQuerySave = false; //Activates save or delete buttons
  // Note: The following variables are not state variables.
  String tempFilename = "token-" +
      DateTime.now().toString().replaceAll(
          RegExp(r'[-:. ]'), ''); //Filename without path or extension
  File defaultAudioFile;


  stopRecording() async {
    // Await return of Recording object
    var _recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;

    Directory docDir = await getExternalStorageDirectory();
    Directory directory = Directory(docDir.path + '/ASR_Speech/');
    setState(() {
      //Tells flutter to rerun the build method
      _isRecording = isRecording;
      _doQuerySave = true;
      defaultAudioFile =
          File(p.join(directory.path, this.tempFilename + '.wav'));
    });
    print("File path of the record: ${_recording.path}");
    print("File length: ${await defaultAudioFile.length()}");
    print("File Stream: ${defaultAudioFile.path}");
  }

  startRecording() async {
    try {
      Directory docDir = await getExternalStorageDirectory();
      Directory directory = Directory(docDir.path + '/ASR_Speech/');
      String newFilePath = p.join(directory.path, this.tempFilename);
      File tempAudioFile = File(newFilePath + '.wav');

      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Start recording: $tempAudioFile"),
        duration: Duration(milliseconds: 1400),
      ));
      if (await directory.exists()) {}
      await directory.create();
      if (await tempAudioFile.exists()) {
        await tempAudioFile.delete();
      }
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(
            path: newFilePath, audioOutputFormat: AudioOutputFormat.WAV);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Error! Audio recorder lacks permissions.")));
      }
      bool isRecording = await AudioRecorder.isRecording;
      setState(() {
        //Tells flutter to rerun the build method
        _recording = new Recording(duration: new Duration(), path: newFilePath);
        _isRecording = isRecording;
        defaultAudioFile = tempAudioFile;
      });
    } catch (e) {
      print(e);
    }
  }

  _deleteCurrentFile() async {
    //Clear the default audio file and reset query save and recording buttons
    if (defaultAudioFile != null) {
      setState(() {
        //Tells flutter to rerun the build method
        _isRecording = false;
        _doQuerySave = false;
        defaultAudioFile.delete();
        //RecorderWav.removeRecorderFile(fp);
      });
    } else {
      print("Error! defaultAudioFile is $defaultAudioFile");
    }
    Navigator.pop(context);
  }

  AlertDialog _deleteFileDialogBuilder() {
    return AlertDialog(
        title: Text("Delete current recording?"),
        actions: <Widget>[
          new FlatButton(
            child: const Text("YES"),
            onPressed: () => _deleteCurrentFile(), //
          ),
          new FlatButton(
            child: const Text("NO"),
            onPressed: () => Navigator.pop(context),
          )
        ]);
  }

  _showSaveDialog() {
    // Note: SaveDialog should return a File or null when calling Navigator.pop()
    // Catch this return value and update the state of the ListTile if the File has been renamed
    showDialog(
        context: context,
        builder: (context) => SaveDialog(
              defaultAudioFile: defaultAudioFile,
            ));
  }

  Future _readSpeechText() async {
    Directory docDir = await getExternalStorageDirectory();
    Directory directory = Directory(docDir.path);
    fileName = directory.path + '/ASR_Speech/speech.txt';
    print('${fileName}');
    String text = await File(fileName).readAsString();
    return text;
  }

  Future fetchPost() async {
    String text = await http.read(speechUrl);
    return text;
  }

  @override
  // TODO: do an async check of audio recorder state before building everything else
  Widget build(BuildContext context) {
    // Check if the AudioRecorder is currently recording before building the rest of the Page
    // If we do not check this,
    return FutureBuilder<bool>(
        future: AudioRecorder.isRecording, builder: audioCardBuilder);
  }

  Widget audioCardBuilder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Container();
      default:
        if (snapshot.hasError) {
          return new Text('Error: ${snapshot.error}');
        } else {
          bool isRecording = snapshot.data;

          // Note since this is being called in build(), we do not call set setState to change
          // the value of _isRecording
          _isRecording = isRecording;

          return new Card(
            child: new Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: new Padding(
                padding: new EdgeInsets.all(8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Spacer(),
                    Container(
                      child: ListTile(
                        leading: const Icon(Icons.record_voice_over),
                        title: const Text(
                          '请大声朗读以下句子：',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dashed),
                          textScaleFactor: 1.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 300.0,
                        child: ListView(
                            //scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              new FutureBuilder(
                                  future: fetchPost(),
                                  builder: (context, snapshot) {
                                    return new Text(snapshot.data ?? '',
                                        softWrap: true, textScaleFactor: 1.5);
                                  }),
                            ]),
                      ),
                    ),
                    Container(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          _doQuerySave
                              ? Text(
                                  "删除",
                                  textScaleFactor: 1.2,
                                )
                              : Container(),
                          Container(height: 12.0),
                          new FloatingActionButton(
                            child: _doQuerySave ? new Icon(Icons.cancel) : null,
                            backgroundColor: _doQuerySave
                                ? Colors.blueAccent
                                : Colors.transparent,
                            onPressed: _doQuerySave
                                ? (() => showDialog(
                                      context: context,
                                      builder: (context) =>
                                          _deleteFileDialogBuilder(),
                                    ))
                                : null,
                            mini: true,
                          ),
                        ]),
                        Container(width: 38.0),
                        Column(children: [
                          _isRecording
                              ? new Text('停止录音', textScaleFactor: 1.5)
                              : new Text('开始录音', textScaleFactor: 1.5),
                          Container(height: 12.0),
                          new FloatingActionButton(
                            child: _isRecording
                                ? new Icon(Icons.stop, size: 36.0)
                                : new Icon(Icons.mic, size: 36.0),
                            onPressed:
                                _isRecording ? stopRecording : startRecording,
                          ),
                        ]),
                        Container(width: 38.0),
                        Column(children: [
                          _doQuerySave
                              ? Text(
                                  "保存",
                                  textScaleFactor: 1.2,
                                )
                              : Container(),
                          Container(height: 12.0),
                          FloatingActionButton(
                            child: _doQuerySave
                                ? new Icon(Icons.check_circle)
                                : Container(),
                            backgroundColor: _doQuerySave
                                ? Colors.blueAccent
                                : Colors.transparent,
                            mini: true,
                            onPressed: _doQuerySave ? _showSaveDialog : null,
                          ),
                        ]),
                      ],
                    ),
                    //Spacer(),
                  ],
                ),
              ),
            ),
          );
        }
    }
  }
}
