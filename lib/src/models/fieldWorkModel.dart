import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FieldWorkModel extends ChangeNotifier {
  List<FieldW> _fieldWList = [];

  List<FieldW> get listaFW => _fieldWList;

  List<String> get itemNames {
     List<String> aux =[];
    for (var item in _fieldWList) {
      aux.add(item.title);
    }
    return aux;
  }

  set listaFW(List<FieldW> list) {
    _fieldWList = list;

    notifyListeners();
  }
}

class FieldW {
  String title = "";
  String notas = "";
  DateTime date = DateTime.now();
  List<File> images = [];
  String audio = "";
  List<Position> positions = [];
  File video = new File("") ;

  FieldW({required this.title, required this.notas}) {
    this.positions = [];
    this.images = [];
    this.date = DateTime.now();
    this.video = new File("");
  }

  editFieldW(title, notas) {
    this.title = title;
    this.notas = notas;
  }

  Map<String, dynamic> toJson() {
    List<String> aux = [];
    for (var item in images) {
      aux.add(item.path);
    }

    List<Map<String, dynamic>> aux2 = [];
    for (var item in positions) {
      aux2.add(item.toJson());
    }
    

    return {
      'title': title,
      'notas': notas,
      'images': aux,
      'positions': aux2,
      'audio': audio,
      'video': video.path

    };
  }

  FieldW.fromJson(Map<String, dynamic> json) {
    List<File> aux = [];

   
      for (var item in json['images']) {
        aux.add(File(item));
      }
    
    List map = json['positions'];

    List<Position> aux2 = [];
    for (var item in map) {
      aux2.add(Position.fromMap(item));
    }
    
    title = json['title'];
    notas = json['notas'];
    images = aux;
    positions = aux2;
    audio = json['audio'];
    video = File(json["video"]);
  }
  
}
