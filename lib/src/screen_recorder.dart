import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screen_recorder_ffmpeg/screen_recorder.dart';
import 'package:flutter_screen_recorder_ffmpeg/src/constants.dart';
import 'dart:ui' as ui show Image, ImageByteFormat;

import 'package:path_provider/path_provider.dart';

class ScreenRecorderController {
  ScreenRecorderController({
    SchedulerBinding? binding,
  })  : _containerKey = GlobalKey(),
        _binding = binding ?? SchedulerBinding.instance!;

  /// key of the content widget to render
  final GlobalKey _containerKey;
  /// frame callback
  final SchedulerBinding _binding;
  /// save frames
  final List<ui.Image> _frames = [];

  /// is recording frames
  bool _record = false;


  void start() {
    /// only start a video, if no recording is in progress
    if (_record == true) {
      return;
    }
    _record = true;
    _binding.addPostFrameCallback(postFrameCallback);
  }

  void stop() {
    _record = false;
  }

  void postFrameCallback(Duration timestamp) async {
    if (_record == false) {
      return;
    }

    try {
      final image = await capture();
      if (image == null) {
        debugPrint('capture returned null');
        return;
      }
      _frames.add(image);
    } catch (e) {
      debugPrint(e.toString());
    }
    _binding.addPostFrameCallback(postFrameCallback);
  }

  Future<ui.Image?> capture() async {
    final renderObject = _containerKey.currentContext?.findRenderObject();

    if (renderObject is RenderRepaintBoundary) {
      final image = await renderObject.toImage(pixelRatio: 3.0);
      return image;
    } else {
      FlutterError.reportError(_noRenderObject());
    }
    return null;
  }

  FlutterErrorDetails _noRenderObject() {
    return FlutterErrorDetails(
      exception: Exception(
        '_containerKey.currentContext is null. '
        'Thus we can\'t create a screenshot',
      ),
      library: 'feedback',
      context: ErrorDescription(
        'Tried to find a context to use it to create a screenshot',
      ),
    );
  }

  Future<String> export() async {
    String dir;
    String imagePath;
    /// get application temp directory
    Directory appDocDirectory = await getTemporaryDirectory();
    dir = appDocDirectory.path;
    /// delete last directory
    appDocDirectory.deleteSync(recursive: true);
    /// create new directory
    appDocDirectory.create();

    /// iterate all frames
    for (int i = 0; i < _frames.length; i++) {
      /// convert frame to byte data png
      final val = await _frames[i].toByteData(format: ui.ImageByteFormat.png);
      /// convert frame to buffer list
      Uint8List pngBytes = val!.buffer.asUint8List();
      /// create temp path for every frame
      imagePath = '$dir/$i.png';
      /// create image frame in the temp directory
      File capturedFile = File(imagePath);
      await capturedFile.writeAsBytes(pngBytes);
    }
    /// clear frame list
    _frames.clear();
    /// render frames.png to video/gif
    await FfmpegProvider().mergeIntoVideo(renderType: RenderType.video);
    /// return
    return Constants.videoOutputPath;
  }

}

class ScreenRecorder extends StatelessWidget {
  const ScreenRecorder({
    Key? key,
    required this.child,
    required this.controller,
  })  : super(key: key);

  /// The child which should be recorded.
  final Widget child;

  /// This controller starts and stops the recording.
  final ScreenRecorderController controller;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller._containerKey,
      child: child,
    );
  }
}

