import 'package:costamob/src/models/fieldWorkModel.dart';
import 'package:costamob/src/models/positionModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class InsertCoords extends StatefulWidget {
  @override
  _InsertCoordsState createState() => _InsertCoordsState();
}

class _InsertCoordsState extends State<InsertCoords> {
  TextEditingController latitud_controller =TextEditingController();
  TextEditingController longitud_controller =TextEditingController();

  @override
  void initState() {
    final ubicacion = Provider.of<PositionModel>(context, listen: false);

    super.initState();
    latitud_controller =
        TextEditingController(text: ubicacion.position.latitude.toString());
    longitud_controller =
        TextEditingController(text: ubicacion.position.longitude.toString());
  }

  @override
  void dispose() {
    latitud_controller.dispose();
    longitud_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          
          controller: this.latitud_controller,
          decoration: InputDecoration(
            filled: true,
            labelText: 'Latitud',
          ),
          // initialValue: ubicacion.position.latitude.toString(),
        ),
        SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: this.longitud_controller,
          decoration: InputDecoration(
            filled: true,
            labelText: 'Longitud',
            
          ),
          // initialValue:  ubicacion.position.longitude.toString(),
        ),
      ],
    );
  }
}
