import 'dart:io';
import 'package:event_pro/data/remote/api_value.dart';
import 'package:event_pro/sharedwidget/deleteFileConfirmationDialog.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/scanned_visitor_list_Model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:event_pro/view/commonScreen/view_image.dart';
import 'package:event_pro/view/commonScreen/view_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

import '../../menuScreens/exhibitor/scanned_visitors.dart';

// ignore: must_be_immutable
class FeedbackForVisitor extends StatefulWidget {
  bool? isFav;
  ScannedVisitorListModel? visitorData;
  String? exhibitionId;

  FeedbackForVisitor(
      {super.key, this.isFav, this.visitorData, this.exhibitionId});
  @override
  State<FeedbackForVisitor> createState() => _FeedbackForVisitorState();
}

class _FeedbackForVisitorState extends State<FeedbackForVisitor> {
  List callActionList = ['Call', 'Meeting', 'WhatsApp Message', 'Email'];
  String? callActionListValue;
  TextEditingController _additionalInfoControlller = TextEditingController();
  TextEditingController _feedbackController = TextEditingController();
  int selectedIndex = -1;
  bool isFav = false;
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isRecordingComplete = false;
  String? _audioPath;
  // String? _photoPath;
  List<String> _photoPaths = [];
  String? _videoPath;

  bool isLoading = true;
  bool isButtonLoading = false;
  File? _audioFile;
  // File? _photoFile;
  List<File> _photoFiles = [];
  File? _videoFile;

  final FocusNode _feedbackFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isFav != null) {
      isFav = widget.isFav ?? false;
    }
    _audioRecorder = FlutterSoundRecorder();
    _initializePlayer();
    _initAudioRecorder();

    debugPrint('HELLLLOOOOOOOO,${widget.visitorData!}');
  }

  void _initializePlayer() async {
    if (!_audioPlayer.isOpen()) {
      await _audioPlayer.openPlayer();
    }
  }

  Future<void> _initAudioRecorder() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      await _audioRecorder!.openRecorder();
    } else {
      print('Microphone permission not granted');
      showToast(
          "Microphone Permission is not granted. Please grant permission in device settings");
    }
  }

  Future<void> recordAudio() async {
    if (_isRecording) {
      await _audioRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _isRecordingComplete = true;
      });
      print('Audio recorded: $_audioPath');
    } else {
      // Directory appDocDir = await getApplicationDocumentsDirectory();
      // Directory audioDir = Directory('${appDocDir.path}/audio_recordings');
      // if (!await audioDir.exists()) {
      //   await audioDir.create(recursive: true);
      // }
      Directory tempDir = await getTemporaryDirectory();
      _audioPath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      // _audioPath = '${audioDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      _audioFile = File(_audioPath!);
      await _audioRecorder!.startRecorder(toFile: _audioPath);
      setState(() {
        _isRecording = true;
      });
      print('Recording audio...');
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera, color: cyangreen),
                title: Text('Camera'),
                onTap: () {
                  _captureImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: cyangreen),
                title: Text('Gallery'),
                onTap: () {
                  _captureImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _captureImage(ImageSource source) async {
  //   final XFile? image = await _picker.pickImage(source: source);

  //   if (image != null) {
  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: image.path,
  //       aspectRatioPresets: [CropAspectRatioPreset.square],
  //       uiSettings: [
  //         AndroidUiSettings(
  //             toolbarTitle: 'Edit',
  //             toolbarColor: cyangreen,
  //             toolbarWidgetColor: Colors.white,
  //             initAspectRatio: CropAspectRatioPreset.square,
  //             lockAspectRatio: true),
  //         IOSUiSettings(minimumAspectRatio: 0.0),
  //       ],
  //     );
  //     if (croppedFile != null) {
  //       // final Directory appDocDir = await getApplicationDocumentsDirectory();
  //       // final Directory imageDir = Directory('${appDocDir.path}/feedback_images');
  //       // if (!await imageDir.exists()) {
  //       // await imageDir.create(recursive: true);
  //       // }
  //       // final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //       // final String newPath = '${imageDir.path}/$fileName';
  //       // final File newImage = await File(croppedFile.path).copy(newPath);
  //       final File newImage = await File(croppedFile.path);
  //       setState(() {
  //         _photoPath = newImage.path;
  //         _photoFile = newImage;
  //       });
  //       showToast('Image Selected');
  //     } else {
  //       showToast('Image Not Selected');
  //     }
  //   } else {
  //     showToast('Image Not Selected');
  //   }
  // }

  Future<void> _captureImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        // aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
            aspectRatioPresets: [CropAspectRatioPreset.square],
            toolbarTitle: 'Edit',
            toolbarColor: cyangreen,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(minimumAspectRatio: 0.0),
        ],
      );
      if (croppedFile != null) {
        final File newImage = File(croppedFile.path);
        setState(() {
          _photoPaths.add(newImage.path);
          _photoFiles.add(newImage);
        });
        showToast('Image Selected');
      } else {
        showToast('Image Not Selected');
      }
    } else {
      showToast('Image Not Selected');
    }
  }

  Future<void> showVideoSourceSelector() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.videocam, color: cyangreen),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.of(context).pop();
                  recordVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: cyangreen),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  recordVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> recordVideo(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: source);
    if (video != null) {
      // final Directory appDocDir = await getApplicationDocumentsDirectory();
      // final Directory videoDir = Directory('${appDocDir.path}/feedback_videos');
      // if (!await videoDir.exists()) {
      //   await videoDir.create(recursive: true);
      // }
      // final String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      // final String newPath = '${videoDir.path}/$fileName';
      // final File newVideo = await File(video.path).copy(newPath);
      final File newVideo = await File(video.path);
      setState(() {
        _videoPath = newVideo.path;
        _videoFile = File(newVideo.path);
      });
      showToast('Video Selected');
    }
  }

  @override
  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String day = DateFormat('d').format(date);
      String monthYear = DateFormat('MMM yyyy').format(date);
      String suffix = getDaySuffix(date.day);
      return '$day$suffix $monthYear';
    } catch (e) {
      return '-'; // Return '-' if the date is invalid
    }
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var width = MediaQuery.of(context).size.width;
    return BaseScreen(
      onItemSelected: (index) {
        Navigator.pushNamed(context, getRouteForIndex(index));
      },
      selectedIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.transparent,
          // backgroundColor: Colors.transparent,
          backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          scrolledUnderElevation: 0,
          elevation: 0,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 10),
          //     child: InkWell(
          //       onTap: () async {
          //         setState(() {
          //           isFav = !isFav;
          //         });
          //       },
          //       child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
          //           color: isFav ? Colors.amber : Colors.white, size: 20),
          //     ),
          //   ),
          // ],
          flexibleSpace: Container(
            height: convertFigmaToUIWidth(160, width),
            decoration: BoxDecoration(
              color: cyangreen,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
          ),
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(convertFigmaToUIWidth(120, width) ?? 120),
            child: Container(
              height: convertFigmaToUIWidth(120, width),
              width: size.width,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    child: getCircularImageWidget(
                        convertFigmaToUIWidth(100, width) ?? 100,
                        widget.visitorData!.imageLink ?? '',
                        white,
                        cyangreen,
                        25,
                        getNameInitials(widget.visitorData!.name.toString()),
                        borderColor: cyangreen),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(204, 232, 234, 0.7),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //--------------------------vip text----------------------------//

                      Text(widget.visitorData!.name ?? '-',
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(17, width),
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(85, 85, 85, 1))),
                      SizedBox(height: 4),
                      Text(
                        formatDate(widget.visitorData!.weddingDate ?? '-'),
                        style: TextStyle(
                          fontSize: convertFigmaToUIWidth(17, width),
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(85, 85, 85, 1),
                        ),
                      ),
                      // SizedBox(height: 8),
                      SizedBox(height: convertFigmaToUIWidth(8, width)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          circleButton(
                              image: callIcon,
                              w: size.width,
                              onPress: () => makingPhoneCall(
                                    // widget.visitorData!.mobile ?? ""
                                    '${widget.visitorData!.countryCode ?? ""}${widget.visitorData!.mobile ?? ""}',
                                  )),
                          SizedBox(width: 10),
                          circleButton(
                              image: mailIcon,
                              w: size.width,
                              onPress: () => sendingMails(
                                  widget.visitorData!.email ?? "")),
                          SizedBox(width: 10),
                          circleButton(
                              image: whatsappIcon,
                              w: size.width,
                              onPress: () => sharingOnTap(
                                  'https://api.whatsapp.com/send/?phone=${widget.visitorData!.mobile ?? ""}&type=phone_number&app_absent=0')),
                        ],
                      ),
                      // SizedBox(height: 15),
                      SizedBox(height: convertFigmaToUIWidth(15, width)),

                      //--------------------------additional info----------------------------//

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color.fromRGBO(235, 246, 247, 1),
                        ),
                        child: TextField(
                          controller: _additionalInfoControlller,
                          maxLines: 4,
                          minLines: 2,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 5),
                            hintText: 'Notes',
                            hintStyle: TextStyle(
                                color: Color.fromRGBO(85, 85, 85, 1),
                                // fontSize: 15,
                                fontSize: convertFigmaToUIWidth(15, width),
                                fontWeight: FontWeight.w400),
                          ),
                          maxLength: 200,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200)
                          ],
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      // SizedBox(height: 15),
                      SizedBox(height: convertFigmaToUIWidth(15, width)),

                      //--------------------------call to action drop down----------------------------//

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color.fromRGBO(235, 246, 247, 1),
                        ),
                        child: DropdownButtonFormField(
                          value: callActionListValue,
                          isExpanded: true,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_drop_down_sharp,
                              color: Color.fromRGBO(2, 141, 148, 0.6),
                              size: 30),
                          style: TextStyle(
                              height: 1.5,
                              color: Color.fromRGBO(85, 85, 85, 1),
                              // fontSize: 15,
                              fontSize: convertFigmaToUIWidth(15, width),
                              fontWeight: FontWeight.w400),
                          onChanged: (value) {
                            setState(() {
                              callActionListValue = value;
                            });
                          },
                          items: callActionList.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type,
                                  style: TextStyle(
                                      height: 1.5,
                                      // height: convertFigmaToUIWidth(1.5, width),
                                      fontWeight: FontWeight.w400)),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            hintText: 'Call to Action',
                            hintStyle: TextStyle(
                                height: 1.5,
                                color: Color.fromRGBO(85, 85, 85, 1),
                                // fontSize: 15,
                                fontSize: convertFigmaToUIWidth(15, width),
                                fontWeight: FontWeight.w400),
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      // SizedBox(height: 25),
                      SizedBox(height: convertFigmaToUIWidth(25, width)),

                      //--------------------------Interest level----------------------------//

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Interest Level',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                height: 1.5,
                                color: Colors.black,
                                // fontSize: 12,
                                fontSize: convertFigmaToUIWidth(12, width),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      SizedBox(height: convertFigmaToUIWidth(10, width)),

                      SizedBox(
                        height: convertFigmaToUIWidth(
                            55, width), // Fixed height to avoid unbounded error
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: index < 4 ? 25 : 0),
                                  // width: 40,
                                  // height: 40,
                                  width: convertFigmaToUIWidth(40, width),
                                  height: convertFigmaToUIWidth(40, width),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectedIndex == index
                                        ? cyangreen
                                        : cyangreenLight,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        height: 1.5,
                                        color: selectedIndex == index
                                            ? white
                                            : cyangreen,
                                        fontSize: selectedIndex == index
                                            ? convertFigmaToUIWidth(16, width)
                                            : convertFigmaToUIWidth(14, width),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      // SizedBox(height: 20),
                      SizedBox(height: convertFigmaToUIWidth(20, width)),

                      //--------------------------audio photo video----------------------------//

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: convertFigmaToUIWidth(120, width),
                                child: _isRecordingComplete
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: cyangreenLight,
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.1))),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                  onTap: () async {
                                                    if (_isPlaying) {
                                                      await _audioPlayer
                                                          .pausePlayer();
                                                      setState(() {
                                                        _isPlaying = false;
                                                      });
                                                    } else {
                                                      if (_audioPath != null &&
                                                          await File(
                                                                  _audioPath!)
                                                              .exists()) {
                                                        setState(() {
                                                          _isPlaying = true;
                                                        });
                                                        await _audioPlayer
                                                            .startPlayer(
                                                                fromURI:
                                                                    _audioPath,
                                                                whenFinished:
                                                                    () {
                                                                  setState(() {
                                                                    _isPlaying =
                                                                        false;
                                                                  });
                                                                });
                                                      } else {
                                                        showToast(
                                                            'Audio file not found or not recorded');
                                                      }
                                                    }
                                                  },
                                                  child: Icon(
                                                      _isPlaying
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      color: cyangreen,
                                                      // size: 18
                                                      size:
                                                          convertFigmaToUIWidth(
                                                              18, width))),
                                              SizedBox(width: 4),
                                              Text('Play',
                                                  style: TextStyle(
                                                      height: 1.5,
                                                      color: Colors.black87,
                                                      // fontSize: 9,
                                                      fontSize:
                                                          convertFigmaToUIWidth(
                                                              9, width),
                                                      fontWeight:
                                                          FontWeight.w400)),
                                              SizedBox(width: 4),
                                              InkWell(
                                                onTap: () =>
                                                    deleteFileConfirmationPopup(
                                                  'audio',
                                                  () async {
                                                    _audioPlayer.pausePlayer();

                                                    try {
                                                      if (Platform.isIOS) {
                                                        if (_audioPath !=
                                                                null &&
                                                            await File(
                                                                    _audioPath!)
                                                                .exists()) {
                                                          await File(
                                                                  _audioPath!)
                                                              .delete();
                                                          debugPrint(
                                                              "Audio file deleted successfully");
                                                        } else {
                                                          debugPrint(
                                                              "Audio file not found.");
                                                        }
                                                      } else {
                                                        await _audioRecorder!
                                                            .deleteRecord(
                                                                fileName:
                                                                    _audioPath!);
                                                      }
                                                    } catch (e) {
                                                      print(
                                                          "Audio deletion error : \n$e");
                                                    }
                                                    setState(() {
                                                      _isRecording = false;
                                                      _isRecordingComplete =
                                                          false;
                                                      _audioPath = null;
                                                      _audioFile = null;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  context,
                                                ),
                                                child: Icon(Icons.close,
                                                    color: cyangreen,
                                                    size:
                                                        // 18
                                                        convertFigmaToUIWidth(
                                                            18, width)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: recordAudio,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  _isRecording ? 20 : 16,
                                              vertical: _isRecording ? 0 : 6),
                                          decoration: BoxDecoration(
                                              color: cyangreenLight,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              border:
                                                  Border.all(color: cyangreen)),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                _isRecording
                                                    ? SizedBox(
                                                        // height: 28,
                                                        // width: 28,
                                                        height:
                                                            convertFigmaToUIWidth(
                                                                28, width),
                                                        width:
                                                            convertFigmaToUIWidth(
                                                                28, width),
                                                        child: Image(
                                                            image: AssetImage(
                                                                microPhoneGif)),
                                                      )
                                                    : Icon(
                                                        _isRecording
                                                            ? Icons.stop
                                                            : Icons.mic,
                                                        color: cyangreen,
                                                        size:
                                                            // 18
                                                            convertFigmaToUIWidth(
                                                                18, width)),
                                                SizedBox(
                                                    width:
                                                        _isRecording ? 10 : 4),
                                                Text(
                                                    _isRecording
                                                        ? 'Stop'
                                                        : 'Add Audio',
                                                    style: TextStyle(
                                                        height: 1.5,
                                                        color: Colors.black87,
                                                        // fontSize: 9,
                                                        fontSize:
                                                            convertFigmaToUIWidth(
                                                                9, width),
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: convertFigmaToUIWidth(120, width),
                                child: InkWell(
                                  onTap: () => _showPicker(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cyangreenLight,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: cyangreen),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                              Icons.add_photo_alternate_rounded,
                                              color: cyangreen,
                                              size: convertFigmaToUIWidth(
                                                  18, width)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Add Photo',
                                            style: TextStyle(
                                              height: 1.5,
                                              color: Colors.black87,
                                              // fontSize: 9,
                                              fontSize: convertFigmaToUIWidth(
                                                  9, width),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: convertFigmaToUIWidth(120, width),
                                child: InkWell(
                                  onTap: () {
                                    if (_videoPath != null) {
                                    } else {
                                      showVideoSourceSelector();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: cyangreenLight,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(color: cyangreen)),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (_videoPath == null)
                                            Icon(Icons.video_call,
                                                color: cyangreen,
                                                size:
                                                    // 18
                                                    convertFigmaToUIWidth(
                                                        18, width)),
                                          if (_videoPath == null)
                                            SizedBox(width: 4),
                                          _videoPath != null
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewVideoScreen(
                                                                    path:
                                                                        _videoPath!)));
                                                  },
                                                  child: Text('View Video',
                                                      style: TextStyle(
                                                          height: 1.5,
                                                          color: Colors.black87,
                                                          // fontSize: 9,
                                                          fontSize:
                                                              convertFigmaToUIWidth(
                                                                  9, width),
                                                          fontWeight:
                                                              FontWeight.w400)))
                                              : Text('Add Video',
                                                  style: TextStyle(
                                                      height: 1.5,
                                                      color: Colors.black87,
                                                      // fontSize: 9,
                                                      fontSize:
                                                          convertFigmaToUIWidth(
                                                              9, width),
                                                      fontWeight:
                                                          FontWeight.w400)),
                                          if (_videoPath != null)
                                            SizedBox(width: 4),
                                          if (_videoPath != null)
                                            InkWell(
                                              onTap: () =>
                                                  deleteFileConfirmationPopup(
                                                'video',
                                                () async {
                                                  setState(() {
                                                    _videoPath = null;
                                                    _videoFile == null;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                context,
                                              ),
                                              child: Icon(Icons.close,
                                                  color: cyangreen,
                                                  size:
                                                      //  18
                                                      convertFigmaToUIWidth(
                                                          18, width)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // SizedBox(height: 25),
                      SizedBox(
                        height: convertFigmaToUIWidth(25, width),
                      ),
                      if (_photoPaths.isNotEmpty)
                        Container(
                          height: 100, // Adjust height as needed
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photoPaths.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 80,
                                margin: EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewImageScreen(
                                                    path: _photoPaths[index]),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_photoPaths[index]),
                                          fit: BoxFit.cover,
                                          // width: 80,
                                          // height: 80,
                                          width:
                                              convertFigmaToUIWidth(80, width),
                                          height:
                                              convertFigmaToUIWidth(80, width),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: InkWell(
                                        onTap: () =>
                                            deleteFileConfirmationPopup(
                                          'photo',
                                          () {
                                            setState(() {
                                              _photoPaths.removeAt(index);
                                              _photoFiles.removeAt(index);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          context,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.close,
                                              color: cyangreen,
                                              size: convertFigmaToUIWidth(
                                                  16, width)
                                              // 16
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      SizedBox(
                          height: _photoPaths.isNotEmpty
                              ? convertFigmaToUIWidth(10, width)
                              : convertFigmaToUIWidth(0, width)),

                      //--------------------------save button----------------------------//

                      isButtonLoading
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: cyangreen))
                          : GestureDetector(
                              onTap: () async {
                                if (callActionListValue == null) {
                                  showToast('Select Call To Action');
                                  return;
                                }

                                if (_additionalInfoControlller.text.isEmpty) {
                                  showToast('Enter Notes');
                                  return;
                                }

                                if (selectedIndex < 0 || selectedIndex >= 5) {
                                  // Changed validation condition
                                  showToast('Please select an interest level');
                                  return;
                                }
                                setState(() {
                                  isButtonLoading = true;
                                });
                                dynamic response =
                                    await apiValue.submitVisitorFeedback(
                                        context,
                                        widget.visitorData!.visitorId ?? '',
                                        _additionalInfoControlller.text,
                                        callActionListValue,
                                        (selectedIndex + 1).toString(),
                                        _audioFile,
                                        // _photoFile,
                                        _photoFiles,
                                        _videoFile,
                                        widget.exhibitionId ?? '');
                                if (response != null) {
                                  showToast('Feedback saved');
                                  setState(() {
                                    isButtonLoading = false;
                                  });
                                  Navigator.push<void>(
                                      context,
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              ScaneedVistors(
                                                isAfterScan: true,
                                              )));
                                } else {
                                  setState(() {
                                    isButtonLoading = false;
                                  });
                                  showToast('Error while saving feedback');
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                    color: cyangreen,
                                    borderRadius: BorderRadius.circular(27)),
                                child: Center(
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        height: 1.5,
                                        // fontSize: 13,
                                        fontSize:
                                            convertFigmaToUIWidth(13, width),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),

                      SizedBox(height: convertFigmaToUIWidth(200, width))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  circleButton({image, onPress, w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: convertFigmaToUIWidth(30, w),
        width: convertFigmaToUIWidth(30, w),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            border: Border.all(color: cyangreen, width: 1),
            shape: BoxShape.circle),
        child: Image(image: AssetImage(image), color: cyangreen),
      ),
    );
  }
}
