import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_recorder_ffmpeg/screen_recorder.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color colors = Colors.red;
  ScreenRecorderController controller = ScreenRecorderController();
  String outPath = '';
  bool _showDialog = false;

  @override
  void initState() {
    Permission.storage.request();
    super.initState();
  }

  int _timerStart = 5;
  recordWidget() async {
    controller.start();
    startTimer();
    setState(() {
      _showDialog = true;
    });
  }

  void startTimer() {
    Duration oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (_timerStart == 0) {
          setState(() {
            controller.stop();

            timer.cancel();
          });
          var path = await controller.export(renderType: RenderType.video);
          if(path['success'] == true){
            setState((){
              outPath = path['outPath'];
            });
            await ImageGallerySaver.saveFile(outPath,
                name: "${DateTime.now()}").then((value) {

              if(value['isSuccess'] == true){
                debugPrint(value['filePath']);
              } else{
                debugPrint(value['errorMessage']);
              }
            })
                .whenComplete(() {
              setState(() {
                _showDialog = false;
              });
            });
          } else{
            setState(() {
              outPath = path['msg'];
              _showDialog = false;
            });
          }
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
    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ScreenRecorder(
                  controller: controller,
                  child: Center(
                      child: AnimatedContainer(
                    height: 200,
                    width: 200,
                    duration: const Duration(milliseconds: 300),
                    color: colors,
                    child: Center(
                      child: AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: [
                          TyperAnimatedText('aaaaaa',
                              speed: const Duration(milliseconds: 300))
                        ],
                      ),
                    ),
                  )),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _colorPalette(
                          color: Colors.red,
                          onTap: () {
                            setState(() {
                              colors = Colors.red;
                            });
                          }),
                      _colorPalette(
                          color: Colors.green,
                          onTap: () {
                            setState(() {
                              colors = Colors.green;
                            });
                          }),
                      _colorPalette(
                          color: Colors.blue,
                          onTap: () {
                            setState(() {
                              colors = Colors.blue;
                            });
                          }),
                      _colorPalette(
                          color: Colors.purpleAccent,
                          onTap: () {
                            setState(() {
                              colors = Colors.purpleAccent;
                            });
                          }),
                      _colorPalette(
                          color: Colors.orange,
                          onTap: () {
                            setState(() {
                              colors = Colors.orange;
                            });
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () {
                    recordWidget();
                  },
                  child: const Text('Start'),
                ),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    'Response => $outPath'
                  ),
                )
              ],
            ),
          ),
        ),
        if (_showDialog)
          Container(
            color: Colors.black.withOpacity(0.6),
            child: const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget _colorPalette({required Function() onTap, required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          height: 40,
          width: 40,
        ),
      ),
    );
  }
}
