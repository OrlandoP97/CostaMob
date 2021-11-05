import 'dart:convert';
import 'dart:io';

import 'package:costamob/src/models/fieldWorkModel.dart';
import 'package:costamob/src/models/positionModel.dart';
import 'package:costamob/src/pages/new_fieldW_page.dart';

import 'package:costamob/src/widgets/field_work_element.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:costamob/src/utils/nameValidator.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final pathName_controller = TextEditingController();
  String rootpath = "";
  bool permissionGranted = false;

  @override
  void initState() {
    getRootPath().then((value) =>
        _readFieldW().then((value) => _determinePosition().then((value) {
              if (value.latitude != 0)
                Provider.of<PositionModel>(context, listen: false).position =
                    value;
            })));

    super.initState();
  }

  @override
  void setState(fn) {
    _writeFieldW().then((value) => super.setState(fn));

    //_writeFieldW();
  }

  @override
  void dispose() {
    pathName_controller.dispose();
    super.dispose();
  }

  Future<void> _writeFieldW() async {
    print('Escribiendo');

    await getRootPath();
    File file = File('${this.rootpath}/fieldws.json');
    //print(await file.exists());
    String jsonText = jsonEncode(context.read<FieldWorkModel>().listaFW);
    // print(jsonText);
    await file.writeAsString(jsonText);
  }

  Future<void> getRootPath() async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        if (await Permission.storage.isGranted) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          // print(directory);
          List<String> paths = directory!.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          super.setState(() {
            this.rootpath = newPath + "/CostaMob";
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveFile(String fieldWPath) async {
    Directory directory;
    Directory imgDir;
    try {
      if (Platform.isAndroid) {
        if (await Permission.storage.isGranted) {
          await getRootPath();
          String newPath = "";

          print(rootpath);
          newPath = this.rootpath + "/$fieldWPath";
          directory = Directory(newPath);
          imgDir = Directory("$newPath/images");

          if (!await directory.exists()) {
            await directory.create(recursive: true);
            await imgDir.create(recursive: true);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> _showMyDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Añadir nuevo trabajo de campo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: [
                    TextFormField(
                      controller: this.pathName_controller,
                      decoration: InputDecoration(
                        icon: Icon(Icons.add_location_rounded),
                        filled: true,
                        labelText: 'Nombre',
                      ),
                      // initialValue: ubicacion.position.latitude.toString(),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                saveFile(pathName_controller.text)
                    .then((value) => Navigator.of(context).pop(true));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _readFieldW() async {
    Directory dir = Directory(this.rootpath);
    File file = File('${this.rootpath}/fieldws.json');

    print(" rootpath ${this.rootpath}");

    List<FieldW> fieldws = [];

    var exist = await file.exists();

    if (exist) {
      String text = await file.readAsString();
      print(text);

      List json = jsonDecode(text);
      // print(text);

      for (var i = 0; i < json.length; i++) {
        fieldws.add(FieldW.fromJson(json[i]));
      }

      Provider.of<FieldWorkModel>((context), listen: false).listaFW = fieldws;
      print(fieldws.toString());
    } else {
      if (await Permission.manageExternalStorage.request().isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.storage.request().isDenied) {
        setState(() {
          permissionGranted = false;
        });
      }

      await dir.create();
      await file.create();

      await file.writeAsString("[{}]");

      Provider.of<FieldWorkModel>((context), listen: false).listaFW = fieldws;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debe activar la ubicación para continuar'),
        ),
      );

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Permiso denegado, debe activar el permiso de ubicación'),
          ),
        );

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final ubicacion = Provider.of<PositionModel>(context);
    final lista = Provider.of<FieldWorkModel>((context), listen: false).itemNames;
    return Scaffold(
        body: Stack(
          children: [MainScroll(rootpath)],
        ),
        floatingActionButton: (ubicacion.position.latitude != 0)
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  _showMyDialog().then((value) => {

                        print(value),
                        if (value ==true && nameValidator(this.pathName_controller.text,lista)!){ 
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (_) => FormWidgetsDemo(
                                "${this.rootpath}/${this.pathName_controller.text}"),
                          ),
                        )
                            .then((value) {
                          //si llega true se guarda y se actualiza la lista
                          setState(() {});

                          if (value != true) {
                            //si llega false de newFielW significa que se cancela por tanto hay que eliminar
                            // la carpeta que se habia creado
                            final dir = Directory(
                                "${this.rootpath}/${this.pathName_controller.text}");
                            dir.delete(recursive: true);

                            setState(() {});
                          }
                          ;
                        })}
                      });
                })
            : null);
  }
}

class MainScroll extends StatefulWidget {
  final String rootpath;

  MainScroll(this.rootpath);

  @override
  _MainScrollState createState() => _MainScrollState();
}

class _MainScrollState extends State<MainScroll> {
  Future<void> _writeFieldW() async {
    print('Escribiendo');

    File file = File('${widget.rootpath}/fieldws.json');
    //print(await file.exists());
    String jsonText = jsonEncode(context.read<FieldWorkModel>().listaFW);
    // print(jsonText);
    await file.writeAsString(jsonText);
  }

  @override
  Widget build(BuildContext context) {
    //Leer del fieldwModel y rellenar la lista de items

    final _listaFW = Provider.of<FieldWorkModel>((context)).listaFW;

    Future<void> _deleteElement(int index) async {
      Directory dir =
          new Directory("${widget.rootpath}/${_listaFW[index].title}");

      dir.delete(recursive: true);

      Provider.of<FieldWorkModel>((context), listen: false)
          .listaFW
          .removeAt(index);

      _writeFieldW();

      setState(() {});
    }

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          leading: IconButton(icon: Icon(Icons.menu_book), onPressed: () {}),
          elevation: 0,
          floating: true,
          title: Text("CostaMov"),
          actions: [IconButton(icon: Icon(Icons.gps_fixed), onPressed: () {
             
             //TODO probando si al pulsar el boton fuerza la ubicacion
             Geolocator.getCurrentPosition();
          })],
        ),
        SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return InkWell(
              onLongPress: () {
                _deleteElement(index).then((value) => print("borrado"));

                print("Long Press");
              },
              onTap: () {
                print("Tap");
              },
              child:
                  FieldWorkElement(_listaFW[index].title, _listaFW[index].date),
            );
          }, childCount: _listaFW.length),
        )
      ],
    );
  }
}
