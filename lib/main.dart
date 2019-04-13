import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'file_recorder_page.dart';
import 'audio_recorder_page.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Run the app
void main() => runApp(new UmmLikeApp());

class _Page {
  const _Page({this.icon, this.text});
  final IconData icon;
  final String text;
}

//Set up list of pages for tab navigation
const List<_Page> _allPages = const <_Page>[
  const _Page(icon: Icons.mic, text: '录音'),
  const _Page(icon: Icons.folder, text: '文件'),
];

class UmmLikeApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SimpleFlutterAudioRecorder',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new UmmLikeHomePage(
        title: '语音识别训练语料采集',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UmmLikeHomePage extends StatefulWidget {
  //HomePage constructor

  final String title;
  UmmLikeHomePage({Key key, this.title}) : super(key: key);
  UmmLikeHomePageState createState() => new UmmLikeHomePageState();
}

class UmmLikeHomePageState extends State<UmmLikeHomePage>
    with SingleTickerProviderStateMixin {
  SnackBar errorSnackBar = new SnackBar(content: Text("Tapped button"));
  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
        appBar: new AppBar(
            // Set AppBar title
            title: new Text(widget.title),
            bottom: new TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const UnderlineTabIndicator(),
              tabs: _allPages.map((_Page page) {
                return new Tab(text: page.text, icon: new Icon(page.icon));
              }).toList(),
            )),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            new SafeArea(top: false, bottom: false, child: AudioRecorderPage()),
            new SafeArea(top: false, bottom: false, child: FileBrowserPage()),
          ],
        ));

    return scaffold;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _allPages.length);
    _tabController.addListener(_onTabChange);
    requestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    //Stop any ongoing recording
  }

  requestPermissions() async {
    bool audioRes =
        await SimplePermissions.checkPermission(Permission.RecordAudio);
    bool readRes =
        await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    bool writeRes = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    return (audioRes && readRes && writeRes);
  }
}
