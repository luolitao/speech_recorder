import 'dart:io';
import 'package:flutter/material.dart';

// Files used by this package
import 'audio_file_list_tile.dart';
import 'package:path_provider/path_provider.dart';

class FileBrowserPage extends StatefulWidget {
  FileBrowserPage({Key key}) : super(key: key);

  @override
  FileBrowserState createState() {
    return FileBrowserState();
  }
}

class FileBrowserState extends State<FileBrowserPage> {
  FileBrowserState();

  ListView createFileListView(BuildContext context, AsyncSnapshot snapshot) {
    Directory docDir = snapshot.data;

    //Filter out all m4a files
    // create ListTile for each file
    List<FileSystemEntity> dirFiles =
        Directory('${docDir.path}/ASR_Speech').listSync();

    // Glob audio files that are not the temp file.
    List<FileSystemEntity> mavFiles =
        dirFiles.where((file) => (file.path.endsWith('.wav'))).toList();

    //Glob has a bug!!!
    //final audioFilesGlob = new Glob(p.join(docDir,"*"));
    //print (audioFilesGlob.list());
    //var audioFiles = audioFilesGlob.listSync();
    //print("${audioFiles}");

    List<Widget> audioFileTiles = new List();

    for (FileSystemEntity file in mavFiles) {
      //String nameroot = pathStr.split('/').last;

      if (file.path.endsWith('.wav')) {
        audioFileTiles.add(new AudioFileListTile(file: file));
      }
    }

    return ListView(children: audioFileTiles);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve list of files in directory
    var futureBuilder = new FutureBuilder(
      future: getExternalStorageDirectory(),
      //getApplicationDocumentsDirectory(),
      //SharedAudioContext.of(context).storage.docDir,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container();
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createFileListView(context, snapshot);
          //return createFileBrowserColumn(context, snapshot);
        }
      },
    );
    return futureBuilder;
  }
}
