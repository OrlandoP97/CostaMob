import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:costamob/src/models/fieldWorkModel.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class View_FieldW extends StatefulWidget {
  final index;
  const View_FieldW(this.index);

  @override
  _View_FieldWState createState() => _View_FieldWState();
}

class _View_FieldWState extends State<View_FieldW> {
  AudioPlayer player = AudioPlayer();

  VideoPlayerController _controller = VideoPlayerController.file(File(""));
  void initState() {
    final video = Provider.of<FieldWorkModel>((context), listen: false)
        .listaFW[widget.index]
        .video;
    if (video.path != "") {
      _controller = VideoPlayerController.file(video)
      
        ..initialize().then((_) {
          _controller.play();
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
      super.initState();
    }
    void dispose() {
    super.dispose();
    _controller.dispose();
  }
  }

  @override
  Widget build(BuildContext context) {
    final fieldw =
        Provider.of<FieldWorkModel>((context), listen: false).listaFW;

    return Scaffold(
      appBar: AppBar(
        title: Text(fieldw[widget.index].title),
      ),
      body: Form(
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8.0, left: 4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 800),
                  child: Column(
                    children: [
                      if (fieldw[widget.index].images.length != 0)
                        CarouselSlider(
                            items: fieldw[widget.index].images.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Image(
                                        image: FileImage(i),
                                        fit: BoxFit.cover,
                                      ));
                                },
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height:
                                  300.0, /* autoPlay: true,autoPlayCurve: Curves.decelerate, */
                            )),
                      Stack(alignment: Alignment.center, children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          height: 200,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadiusDirectional.all(
                                    Radius.circular(50))),
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                icon: Icon(_controller.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
                                color: Colors.black)),
                      ]),
                      Container(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            fieldw[widget.index].notas,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15),
                          ),
                        ),
                      ),
                     (fieldw[widget.index].audio !="")? IconButton(
                        onPressed: () async {
                          print(fieldw[widget.index].audio);
                          if (fieldw[widget.index].audio != "") {
                            await player.setAudioSource(AudioSource.uri(
                                Uri.parse(fieldw[widget.index].audio)));
                            player.play();
                          }
                        },
                        icon: Icon(Icons.play_arrow),
                        color: Theme.of(context).primaryColor,
                      ):SizedBox()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
