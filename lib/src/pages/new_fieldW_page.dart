import 'dart:io';

import 'package:costamob/src/models/fieldWorkModel.dart';
import 'package:costamob/src/models/positionModel.dart';
import 'package:costamob/src/widgets/insert_coords.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gpx/gpx.dart';

import 'package:record/record.dart';

class FormWidgetsDemo extends StatefulWidget {
  String fieldWpathName;

  FormWidgetsDemo(this.fieldWpathName);

  @override
  _FormWidgetsDemoState createState() => _FormWidgetsDemoState();
}

class _FormWidgetsDemoState extends State<FormWidgetsDemo> {
  final _formKey = GlobalKey<FormState>();

  //Variables del form ///////////////////
  String title = '';
  String description = '';
  DateTime date = DateTime.now();
  double maxValue = 0;
  bool brushedTeeth = false;
  bool enableFeature = false;
  ///////////////
  int counter = 1;
  bool _isRecording = false;

  ///Objeto golobal de esta pagina
  FieldW _fieldW = new FieldW(title: "",notas:"");
  AudioPlayer player=AudioPlayer();
  bool showAudio = false;
  ///////////////////////

  @override
  void initState() {
    player = new AudioPlayer();

    ///Extraer nombre del path
    final lista = widget.fieldWpathName.split("/");
    this._fieldW.title = lista[5];
    print(_fieldW.title);
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  savetoGPX() async {
    var gpx = Gpx();

    gpx.creator = "coords";

    final coordsList = this._fieldW.positions;
    for (var i = 0; i < coordsList.length; i++) {
      gpx.wpts.add(
        Wpt(
            lat: coordsList[i].latitude,
            lon: coordsList[i].longitude,
            ele: coordsList[i].altitude,
            name: this._fieldW.title,
            desc: 'CostaMobile'),
      );
    }

    // generate xml string
    var gpxString = GpxWriter().asString(gpx, pretty: true);

    File newgpx = new File('${widget.fieldWpathName}/coords.gpx');
    await newgpx.writeAsString(gpxString);

    print(gpxString);
  }

  updateList() {
    setState(() {
      this._fieldW.notas = this.description;
      this._fieldW.date = DateTime.now();

      final fieldM = Provider.of<FieldWorkModel>(context, listen: false);

      fieldM.listaFW.add(this._fieldW);
    });
  }

   grabar() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      await RecordPlatform.instance.start(
        path: "${widget.fieldWpathName}/audio.m4a", // required
        encoder: AudioEncoder.AAC, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
      setState(() {
        _isRecording = true;
      });
    } else
      print(status);
  } 
 
   stopRecording() async {
    bool isRecording = await RecordPlatform.instance.isRecording();

    if (isRecording) {
      await RecordPlatform.instance.stop();

      setState(() {
        _isRecording = false;
        showAudio = true;
        _fieldW.audio = "${widget.fieldWpathName}/audio.m4a";
      });
    }
  } 

  pickImage() async {
     try {
      final _picker = ImagePicker();
      final picked = await _picker.pickImage(source: ImageSource.camera);
      final File pickedFile = File(picked!.path);

      File newImage = await pickedFile
          .copy('${widget.fieldWpathName}/images/${counter.toString()}.jpg');

      setState(() {
        if (picked != null) {
          _fieldW.images.add(newImage);
          counter++;
        }
      });
    } catch (e) {
      print(e);
    }
  }
 
  Future<void> _showMyDialog() async {
    final ubicacion =
        Provider.of<PositionModel>(context, listen: false).position;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Añadir punto'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[InsertCoords()],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                print(ubicacion);
                setState(() {
                  _fieldW.positions.add(ubicacion);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fotos = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Trabajo de Campo '),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...[
                        TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            hintText: 'Inserte una descripción...',
                            labelText: 'Descripción',
                          ),
                          onChanged: (value) {
                            description = value;
                          },
                          maxLines: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (_fieldW.positions.length == 0)
                                ? Text("Añadir puntos de interes")
                                : Text(_fieldW.positions.length.toString()),
                            IconButton(
                                icon: Icon(
                                  Icons.add_location,
                                ),
                                onPressed: () {
                                  _showMyDialog();
                                })
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            (fotos)
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border: Border.all(width: 0.7),
                                      color: Color(0xffF5F5F5),
                                    ),
                                    height: 130,
                                    child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisSpacing: 1,
                                                crossAxisCount: 4),
                                        primary: false,
                                        padding: const EdgeInsets.all(5),
                                        itemCount: _fieldW.images.length,
                                        itemBuilder: (context, index) {
                                          return (_fieldW.images[index] != null)
                                              ? Image.file(
                                                  _fieldW.images[index],
                                                  fit: BoxFit.cover,
                                                )
                                              : Text('fw.title');
                                        }))
                                : Container(
                                    height: 1,
                                    width: 350,
                                    color: Colors.black,
                                  ),
                            IconButton(
                                icon: Icon(
                                  Icons.add_a_photo,
                                ),
                                onPressed: () {
                                  pickImage();
                                })
                          ],
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (!_isRecording)
                                  ? IconButton(
                                      onPressed: () {
                                        grabar();
                                      },
                                      icon: Icon(Icons.mic_outlined),
                                      color: Colors.green,
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                       stopRecording();
                                      },
                                      icon: Icon(Icons.stop),
                                      label: Text("Stop"),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red)),
                                    ),
                              Container(
                                child: (showAudio)
                                    ? IconButton(
                                        onPressed: () async {
                                          await player.setAudioSource(
                                              AudioSource.uri(
                                                  Uri.parse(_fieldW.audio)));
                                          player.play();
                                        },
                                        icon: Icon(Icons.play_arrow),
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                label: Text("Cancelar"),
                                icon: Icon(
                                  Icons.cancel,
                                ),
                                 style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Color(0xffC70039).withOpacity(0.7))
                                ),
                                onPressed: () {
                                  // Retorna falso, no se actualiza la lista de trabajos de campo y se elimnia el directorio que se habia creado
                                  Navigator.of(context).pop(false);
                                },
                              ),
                               ElevatedButton.icon(
                                label: Text("Guardar"),
                                icon: Icon(
                                  Icons.save,
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Color(0xff5A8745))
                                ),
                                onPressed: () {
                                  updateList();
                                  savetoGPX();
                                  Navigator.of(context).pop(true);
                                },
                              ),
                              
                            ],
                          ),
                        ),
                      ].expand(
                        (widget) => [
                          widget,
                          const SizedBox(
                            height: 2,
                          )
                        ],
                      )
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
