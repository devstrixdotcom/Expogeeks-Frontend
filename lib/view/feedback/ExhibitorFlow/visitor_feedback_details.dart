import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/visitor_feedback_from_exhibitor_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/circular_image_widget.dart';
import 'package:event_pro/sharedwidget/feedbackTextFields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class ViewFeedbackDetailsScreen extends StatefulWidget {
  VisitorFeedbackFromExhibitorModel feedbackData;
  ViewFeedbackDetailsScreen({super.key, required this.feedbackData});
  @override
  State<ViewFeedbackDetailsScreen> createState() =>
      _ViewFeedbackDetailsScreenState();
}

class _ViewFeedbackDetailsScreenState extends State<ViewFeedbackDetailsScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = -1;

  bool isPlayed = false;
  late VideoPlayerController _controllers;
  FlutterSoundPlayer? _audioPlayer;
  bool _isAudioPlaying = false;
  late AnimationController _animationController;

  @override
  void initState() {
    print('-----------------------');
    debugPrint('${widget.feedbackData}');
    debugPrint("FEED: ${widget.feedbackData.feedbackImage}");
    print(widget.feedbackData.interestLevel.toString());
    int temp = int.parse(widget.feedbackData.interestLevel ?? '1');
    selectedIndex = temp - 1;
    print(selectedIndex);

    if (widget.feedbackData.feedbackVideo.toString() != 'null' &&
        widget.feedbackData.feedbackVideo.toString() != '') {
      _controllers =
          VideoPlayerController.network(widget.feedbackData.feedbackVideo ?? '')
            ..initialize().then((value) {
              setState(() {});
            });
    }
    if (widget.feedbackData.feedbackAudio.toString() != 'null' &&
        widget.feedbackData.feedbackAudio.toString() != '') {
      _initializeAudioPlayer();
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat(reverse: true);

    super.initState();
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
  }

  void _togglePlay() async {
    if (_isAudioPlaying) {
      await _audioPlayer!.stopPlayer();
      _animationController.stop();
    } else {
      await _audioPlayer!.startPlayer(
        fromURI: widget.feedbackData.feedbackAudio,
        whenFinished: () {
          _animationController.stop();
          setState(() {
            _isAudioPlaying = false;
          });
        },
      );
      _animationController.repeat(reverse: true);
    }
    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });
  }

  @override
  void dispose() {
    if (widget.feedbackData.feedbackVideo.toString() != 'null' &&
        widget.feedbackData.feedbackVideo.toString() != '') {
      _controllers.dispose();
    }
    if (widget.feedbackData.feedbackAudio.toString() != 'null' &&
        widget.feedbackData.feedbackAudio.toString() != '') {
      _audioPlayer!.closePlayer();
      _audioPlayer = null;
    }
    _animationController.dispose();
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

    // return WillPopScope(
    //   onWillPop: () async {
    //     // Navigate to MenuScreen when back button is pressed
    //     print("hello");
    //     Navigator.pushReplacementNamed(
    //         context, '/scannedVisitors'); // Replace with your MenuScreen route
    //     return true; // Prevent default back navigation
    //   },
    //   child: BaseScreen(
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
          flexibleSpace: Container(
            height: convertFigmaToUIWidth(155, width),
            decoration: BoxDecoration(
              color: cyangreen,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
          ),
          bottom: PreferredSize(
            
            preferredSize: Size.fromHeight(convertFigmaToUIWidth(100, width) ?? 100),
            child: Container(
              height: convertFigmaToUIWidth(100, width),
              width: size.width,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    child: getCircularImageWidget(
                        convertFigmaToUIWidth(100, width) ?? 100,
                        widget.feedbackData.userImageLink ?? '',
                        white,
                        cyangreen,
                        25,
                        getNameInitials(widget.feedbackData.name.toString()),
                        borderColor: cyangreen),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color:  Color.fromRGBO(204, 232, 234, 0.7),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: convertFigmaToUIWidth(10, width),),
                      //--------------------------vip text----------------------------//
          
                      Text(widget.feedbackData.name ?? '-',
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(17, width),
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(85, 85, 85, 1))),
                  
                      SizedBox(height: convertFigmaToUIWidth(4, width),),
                      Text(
                        DateFormatter.formatDayWithSuffix(
                            widget.feedbackData.expectedDate ?? ''),
                        style: TextStyle(
                          fontSize: convertFigmaToUIWidth(17, width),
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(85, 85, 85, 1),
                        ),
                      ),
                      SizedBox(height: convertFigmaToUIWidth(8, width),),
                      
                      Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          spacing: 10, // Space between buttons
                          alignment: WrapAlignment
                              .center, // Ensures buttons stay centered
                          children: [
                            if (widget.feedbackData.mobile != null &&
                                widget.feedbackData.mobile!.isNotEmpty)
                              circleButton(
                                image: callIcon,
                                w: size.width,
                                onPress: () => makingPhoneCall(
                                  '${widget.feedbackData.countryCode ?? ""}${widget.feedbackData.mobile ?? ""}',
                                ),
                              ),
                            if (widget.feedbackData.email != null &&
                                widget.feedbackData.email!.isNotEmpty)
                              circleButton(
                                image: mailIcon,
                                w: size.width,
                                onPress: () =>
                                    sendingMails(widget.feedbackData.email ?? ""),
                              ),
                            if (widget.feedbackData.mobile != null &&
                                widget.feedbackData.mobile!.isNotEmpty)
                              circleButton(
                                image: whatsappIcon,
                                w: size.width,
                                onPress: () => sharingOnTap(
                                  'https://api.whatsapp.com/send/?phone=${widget.feedbackData.mobile}&type=phone_number&app_absent=0',
                                ),
                              ),
                          ],
                        ),
                      ),
          
                     
                      SizedBox(height: convertFigmaToUIWidth(15, width),),
          
                      //--------------------------additional info----------------------------//
          
                       SizedBox(height: convertFigmaToUIWidth(10, width),),
                      feedbackTextFields(
                          'Notes', widget.feedbackData.additionalInfo ?? ""),
                      SizedBox(height: convertFigmaToUIWidth(15, width),),
          
                      //--------------------------call to action drop down----------------------------//
          
                       SizedBox(height: convertFigmaToUIWidth(10, width),),
                      feedbackTextFields('Call to Action',
                          widget.feedbackData.callToAction ?? ""),
                       SizedBox(height: convertFigmaToUIWidth(20, width),),
          
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Interest Level',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: textColor,
                                fontSize: convertFigmaToUIWidth(12, width),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                       SizedBox(height: convertFigmaToUIWidth(10, width),),
          
                      
                      Container(
                        width: size.width,
                        height: convertFigmaToUIWidth(55, width),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center items horizontally
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: index < 4
                                          ? 25
                                          : 0), // Avoid extra margin on last item
                                  
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
                                        color: selectedIndex == index
                                            ? Colors.white
                                            : cyangreen,
                                        fontSize:
                                            selectedIndex == index ? convertFigmaToUIWidth(16, width) : convertFigmaToUIWidth(14, width),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                       SizedBox(height: convertFigmaToUIWidth(10, width),),
          
                      // //--------------------------feedback----------------------------//
                      // HERE
                      if (widget.feedbackData.feedback != "")
                        feedbackTextFields(
                            'Feedback', widget.feedbackData.feedback ?? ""),
                     SizedBox(height: convertFigmaToUIWidth(10, width),),
          
                      //--------------------------audio photo video----------------------------//
          
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.feedbackData.feedbackAudio.toString() !=
                                    'null' &&
                                widget.feedbackData.feedbackAudio.toString() !=
                                    '')
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Audio',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: convertFigmaToUIWidth(12, width),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            if (widget.feedbackData.feedbackAudio.toString() !=
                                    'null' &&
                                widget.feedbackData.feedbackAudio.toString() !=
                                    '')
                              Container(
                                height: convertFigmaToUIWidth(50, width),
                                width: double.infinity,
                                padding: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: cyangreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                          _isAudioPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white),
                                      onPressed: _togglePlay,
                                    ),
                                    Expanded(
                                      child: AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            painter: WaveVisualizerPainter(
                                                animation: _animationController,
                                                isPlaying: _isAudioPlaying),
                                            child: Container(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            if (widget.feedbackData.feedbackImageList != null &&
                                widget.feedbackData.feedbackImageList!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Photos',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
          
                            if (widget.feedbackData.feedbackImageList != null &&
                                widget.feedbackData.feedbackImageList!.isNotEmpty)
                              Center(
                                child: SizedBox(
                                  height: convertFigmaToUIWidth(350, width),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget
                                        .feedbackData.feedbackImageList!.length,
                                    itemBuilder: (context, index) {
                                      String imageUrl = widget
                                          .feedbackData.feedbackImageList![index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Container(
                                          width: convertFigmaToUIWidth(300, width),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: cyangreen,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                    child: Text(
                                                        'Image not available'));
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
          
                            if (widget.feedbackData.feedbackVideo.toString() !=
                                    'null' &&
                                widget.feedbackData.feedbackVideo.toString() !=
                                    '')
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Video',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: textColor,
                                        fontSize: convertFigmaToUIWidth(12, width),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            if (widget.feedbackData.feedbackVideo.toString() !=
                                    'null' &&
                                widget.feedbackData.feedbackVideo.toString() !=
                                    '')
                              Container(
                               
                                width: size.width,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: isPlayed
                                          ? _controllers.value.isInitialized
                                              ? GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isPlayed = false;
                                                      _controllers.pause();
                                                    });
                                                  },
                                                  child: AspectRatio(
                                                    aspectRatio: _controllers
                                                        .value.aspectRatio,
                                                    child:
                                                        VideoPlayer(_controllers),
                                                  ),
                                                )
                                              : const CircularProgressIndicator()
                                         
                                          : Container(
                                              height: convertFigmaToUIWidth(350, width),
                                              width: size.width,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: cyangreen,
                                                  width: 1, // 1px border
                                                ),
                                              ),
                                            ),
                                    ),
                                    if (!_controllers.value.isPlaying)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isPlayed = true;
                                            _controllers.play();
                                          });
                                        },
                                        child: Container(
                                          height: convertFigmaToUIWidth(47.3, width),
                                          width: convertFigmaToUIWidth(47.3, width),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(0, 0, 0, 0.6),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          child: Icon(
                                              isPlayed
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: convertFigmaToUIWidth(25.8, width),
                                              color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
          
                      SizedBox(
                        height: convertFigmaToUIWidth(200, width) ?? 200,
                      ),
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
