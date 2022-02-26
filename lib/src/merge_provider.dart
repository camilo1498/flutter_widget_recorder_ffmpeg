import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_recorder_ffmpeg/src/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class MergeProvider with ChangeNotifier {
  bool loading = false, isPlaying = false;
  dynamic limit = 10;
  late double startTime = 0, endTime = 10;

  void setTimeLimit(dynamic value) async {
    limit = value;
    notifyListeners();
  }

  Future<void> mergeIntoVideo() async {
    loading = true;
    String timeLimit = '00:00:';
    notifyListeners();

    if (await Permission.storage.request().isGranted) {
      if (limit.toInt() < 10)
        timeLimit = timeLimit + '0' + limit.toString();
      else
        timeLimit = timeLimit + limit.toString();
      /// To combine audio with sequence of images
      // String commandToExecute = '-r 5 -pattern_type sequence -start_number 02 -f image2 -i ${Constants
      //     .IMAGES_PATH} -y ${Constants
      //     .OUTPUT_PATH}';
      /// mp4 output
      // String commandToExecute = '-r 50 -i ${Constants.IMAGES_PATH} -vf fps=60 -pix_fmt yuv420p -y ${Constants
      //     .OUTPUT_PATH}';
      /// 7mb gif output
      String commandToExecute = '-r 30 -i ${Constants.IMAGES_PATH} -vf "scale=iw/2:ih/2" -y ${Constants
          .OUTPUT_PATH}';

      await  FFmpegKit.execute(commandToExecute).then((rc) async{
        loading = false;
        notifyListeners();
        print('FFmpeg process exited with rc ==> ${await rc.getReturnCode()}');
        print('FFmpeg process exited with rc ==> ${await rc.getCommand()}');
      });
    } else if (await Permission.storage.isPermanentlyDenied) {
      loading = false;
      notifyListeners();
      openAppSettings();
    }
  }
}
