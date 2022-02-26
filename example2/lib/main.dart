import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Color colors = Colors.red;
  ScreenRecorderController controller = ScreenRecorderController();

  @override
  void initState() {
    // TODO: implement initState
    Permission.storage.request();
    super.initState();
  }
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Timer? _timer;
  int _timerStart = 10;
  recordWidget() async {
    controller.start();
    startTimer();
  }
  void startTimer() {
    Duration oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) async{
        if (_timerStart == 0) {
          setState(() {
            controller.stop();

            timer.cancel();
          });
          await controller.export();
        } else {
          setState(() {
            _timerStart--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            ScreenRecorder(
              height: 200,
              width: 200,
              controller: controller,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: colors,
                  child: Center(
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TyperAnimatedText('Hello Manco >:v !', speed: const Duration(milliseconds: 300))
                      ],
                    ),
                  ),
                )
              ),
            ),
            ElevatedButton(
              onPressed: () {
                recordWidget();
              },
              child: Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {
                //ntroller.stop();
              },
              child: Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () async {
                //List<String> gif = await controller.export();
                //print(gif);
                await MergeProvider().mergeIntoVideo();
              },
              child: Text('show recoded video'),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  colors = Colors.red;
                });
              },
              child: Container(
                color: Colors.red,
                height: 50,
                width: 50,
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  colors = Colors.green;
                });
              },
              child: Container(
                color: Colors.green,
                height: 50,
                width: 50,
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  colors = Colors.blue;
                });
              },
              child: Container(
                color: Colors.blue,
                height: 50,
                width: 50,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
