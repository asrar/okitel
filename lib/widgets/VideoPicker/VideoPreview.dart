//*************   © Copyrighted by OkiTel. An Exclusive item of Kostricani. *********************

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/widgets/DownloadManager/save_image_videos_in_gallery.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  final bool isdownloadallowed;
  final String filename;
  final String videourl;
  final String? id;
  final double? aspectratio;

  PreviewVideo(
      {required this.id,
      required this.videourl,
      required this.isdownloadallowed,
      required this.filename,
      this.aspectratio});
  @override
  _PreviewVideoState createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  late VideoPlayerController _videoPlayerController1;
  // late VideoPlayerController _videoPlayerController2;
  late ChewieController _chewieController;
  String videoUrl = '';
  bool isShowvideo = false;
  double? thisaspectratio = 1.14;

  @override
  void initState() {
    setState(() {
      thisaspectratio = widget.aspectratio;
    });
    super.initState();

    _videoPlayerController1 = VideoPlayerController.network(
        // 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
        widget.videourl);
    // _videoPlayerController2 = VideoPlayerController.network(widget.videourl
    //     // 'https://www.radiantmediaplayer.com/media/bbb-360p.mp4'
    //     );
    _chewieController = ChewieController(
      cupertinoProgressColors:
          ChewieProgressColors(bufferedColor: fiberchatgreen),
      videoPlayerController: _videoPlayerController1,
      allowFullScreen: true,
      showControlsOnInitialize: false,
      materialProgressColors:
          ChewieProgressColors(bufferedColor: fiberchatgreen),
      aspectRatio: thisaspectratio,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    // _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqdseqeqsseaadqeqe');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.2,
        elevation: 0.4,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          widget.isdownloadallowed == true
              ? IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () async {
                    _videoPlayerController1.pause();
                    GalleryDownloader.saveNetworkVideoInGallery(context,
                        widget.videourl, false, widget.filename, _keyLoader);
                  })
              : SizedBox()
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: Padding(
        padding: EdgeInsets.only(bottom: Platform.isIOS ? 30 : 10),
        child: Stack(
          children: [
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
              ),
            ),
            Chewie(
              controller: _chewieController,
            ),
          ],
        ),
      )),
    );
  }
}
