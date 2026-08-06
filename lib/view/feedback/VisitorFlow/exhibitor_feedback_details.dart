import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_pro/utils/helper_functions.dart';
import 'package:event_pro/utils/images.dart';
import 'package:event_pro/models/exhibitor_feedback_from_visitor_model.dart';
import 'package:event_pro/view/base_screen.dart';
import 'package:event_pro/utils/basic_route.dart';
import 'package:event_pro/utils/color.dart';
import 'package:event_pro/sharedwidget/feedbackTextFields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class ViewExhibitorFeedbackDetailsScreen extends StatefulWidget {
  ExhibitorFeedbackFromVisitorModel feedbackData;
  ViewExhibitorFeedbackDetailsScreen({super.key, required this.feedbackData});
  @override
  State<ViewExhibitorFeedbackDetailsScreen> createState() =>
      _ViewExhibitorFeedbackDetailsScreenState();
}

class _ViewExhibitorFeedbackDetailsScreenState
    extends State<ViewExhibitorFeedbackDetailsScreen>
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
    debugPrint(
        'FeedbackForExhibitor COUNTRY CODE: ${widget.feedbackData.exhibitorCountryCode}');
    debugPrint("feed: ${widget.feedbackData.feedbackImageList}");
    print(widget.feedbackData.interestLevel.toString());
    String temp = widget.feedbackData.interestLevel ?? '1';
    selectedIndex = int.parse(temp) - 1;
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

  Widget _buildFallbackText(String? exhibitorName) {
    String initials = exhibitorName != null && exhibitorName.isNotEmpty
        ? exhibitorName.substring(0, 2).toUpperCase()
        : "--";

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
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
          // elevation: 0,
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
            preferredSize:
                Size.fromHeight(convertFigmaToUIWidth(110, width) ?? 110),
            child: Container(
              height: convertFigmaToUIWidth(100, width),
              width: size.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 0,
                    child: Container(
                      height: convertFigmaToUIWidth(100, width),
                      width: convertFigmaToUIWidth(100, width),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: Color.fromRGBO(255, 194, 194, 1),
                      ),
                      child: widget.feedbackData.teamPic != null &&
                              widget.feedbackData.teamPic!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: widget.feedbackData.teamPic!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return _buildFallbackText(
                                      widget.feedbackData.exhibitorName);
                                },
                              ),
                            )
                          : _buildFallbackText(
                              widget.feedbackData.exhibitorName),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
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
                      SizedBox(height: convertFigmaToUIWidth(10, width)),
                      Text(widget.feedbackData.teamName ?? '-',
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(17, width),
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(85, 85, 85, 1))),
                      // SizedBox(height: 4),
                      SizedBox(
                        height: convertFigmaToUIWidth(4, width),
                      ),
                      // Text(widget.feedbackData.exhibitionName ?? '-', // MADHU
                      Text(widget.feedbackData.exhibitorName ?? '-',
                          style: TextStyle(
                              fontSize: convertFigmaToUIWidth(17, width),
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(85, 85, 85, 1))),
                      // SizedBox(height: 8),
                      SizedBox(
                        height: convertFigmaToUIWidth(8, width),
                      ),

                      Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          spacing: 20, // Space between buttons
                          alignment:
                              WrapAlignment.center, // Ensures proper centering
                          children: [
                            if (widget.feedbackData.teamCountryCode != '')
                              circleButton(
                                image: callIcon,
                                w: size.width,
                                onPress: () => makingPhoneCall(
                                  '${widget.feedbackData.teamCountryCode}${widget.feedbackData.teamMobile}',
                                ),
                              ),
                            if (widget.feedbackData.teamEmail != '')
                              circleButton(
                                image: mailIcon,
                                w: size.width,
                                onPress: () => sendingMails(
                                    widget.feedbackData.teamEmail ?? ""),
                              ),
                            if (widget.feedbackData.exhibitorInstagramLink !=
                                '')
                              circleButton(
                                image: instaIcon,
                                w: size.width,
                                onPress: () => sharingOnTap(widget
                                        .feedbackData.exhibitorInstagramLink ??
                                    ""),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: convertFigmaToUIWidth(15, width),
                      ),

                      //--------------------------team menber name----------------------------//

                      SizedBox(
                        height: convertFigmaToUIWidth(10, width),
                      ),
                      feedbackTextFields(
                          'Notes', widget.feedbackData.additionalInfo ?? ""),

                      SizedBox(
                        height: convertFigmaToUIWidth(15, width),
                      ),
                      //--------------------------call to action drop down----------------------------//

                      SizedBox(
                        height: convertFigmaToUIWidth(10, width),
                      ),
                      feedbackTextFields('Call to Action',
                          widget.feedbackData.callToAction ?? ""),

                      SizedBox(
                        height: convertFigmaToUIWidth(25, width),
                      ),

                      //--------------------------Interest level----------------------------//

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Interest Level',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                height: 1.5,
                                color: textColor,
                                fontSize: convertFigmaToUIWidth(12, width),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: convertFigmaToUIWidth(10, width),
                      ),

                      Container(
                        width: size.width,
                        height: convertFigmaToUIWidth(55, width),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centers the Row content
                          children: [
                            Expanded(
                              // Allows ListView to size properly
                              child: Center(
                                // Ensures ListView is centered
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          right: index == 4 ? 0 : 25),
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
                                            fontSize: selectedIndex == index
                                                ? convertFigmaToUIWidth(
                                                    16, width)
                                                : convertFigmaToUIWidth(
                                                    14, width),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: convertFigmaToUIWidth(10, width),
                      ),

                      //--------------------------Feedback----------------------------//

                      if (widget.feedbackData.feedback != null &&
                          widget.feedbackData.feedback?.trim() != '')
                        SizedBox(
                          height: convertFigmaToUIWidth(10, width),
                        ),
                      if (widget.feedbackData.feedback != null &&
                          widget.feedbackData.feedback?.trim() != '')
                        feedbackTextFields('Feedback for exhibitor',
                            widget.feedbackData.feedback ?? ""),

                      SizedBox(
                        height: convertFigmaToUIWidth(20, width),
                      ),

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
                                        height: 1.5,
                                        color: textColor,
                                        fontSize:
                                            convertFigmaToUIWidth(12, width),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            if (widget.feedbackData.feedbackAudio.toString() !=
                                    'null' &&
                                widget.feedbackData.feedbackAudio.toString() !=
                                    '')
                              Container(
                                // height: 50,
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
                                widget.feedbackData.feedbackImageList!
                                    .isNotEmpty) ...[
                              // Title: "Photos"
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
                                      fontSize:
                                          convertFigmaToUIWidth(12, width),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),

                              // Horizontal List of Images
                              Center(
                                child: SizedBox(
                                  height: convertFigmaToUIWidth(350, width),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget
                                        .feedbackData.feedbackImageList!.length,
                                    itemBuilder: (context, index) {
                                      String imageUrl = widget.feedbackData
                                          .feedbackImageList![index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Container(
                                          width:
                                              convertFigmaToUIWidth(300, width),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  cyangreen, // Use your theme color
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
                            ],
                            SizedBox(
                              height: convertFigmaToUIWidth(20, width),
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
                                        fontSize:
                                            convertFigmaToUIWidth(12, width),
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
                                      child: _controllers.value.isInitialized
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
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                widget.feedbackData
                                                        .feedbackVideo ??
                                                    '',
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: Colors.grey[300],
                                                    ),
                                                    child: Center(
                                                      child: Icon(Icons.error,
                                                          size:
                                                              convertFigmaToUIWidth(
                                                                  50, width),
                                                          color: Colors.grey),
                                                    ),
                                                  );
                                                },
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
                                          height: convertFigmaToUIWidth(
                                              47.3, width),
                                          width: convertFigmaToUIWidth(
                                              47.3, width),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(0, 0, 0, 0.6),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: cyangreen, width: 2),
                                          ),
                                          child: Icon(
                                              isPlayed
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: convertFigmaToUIWidth(
                                                  25, width),
                                              color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: convertFigmaToUIWidth(200, width)),
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
        padding: EdgeInsets.all(
          image == instaIcon ? 5 : 4,
        ),
        decoration: BoxDecoration(
            border: Border.all(color: cyangreen, width: 1),
            shape: BoxShape.circle),
        child: Image(image: AssetImage(image), color: cyangreen),
      ),
    );
  }
}
