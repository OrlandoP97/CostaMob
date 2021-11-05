import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionModel extends ChangeNotifier {
  Position _position = new Position(accuracy: 10, altitude: 0,latitude: 0,longitude: 0,speed: 0,timestamp: DateTime.now(),heading: 0,speedAccuracy: 10);
  
  Position get position => this._position;

  set position(Position pos) {
    this._position = pos;
    notifyListeners();
  }
}
