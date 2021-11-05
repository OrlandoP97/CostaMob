import 'package:flutter/material.dart';

class FieldWorkElement extends StatelessWidget {
  final String title;
  final DateTime date;
  const FieldWorkElement(this.title, this.date);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 2),
        height: 60,
        width: double.infinity,
        decoration:
            BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [
          BoxShadow(
              blurRadius: 1,
              color: Colors.black26,
              spreadRadius: 1,
              offset: Offset(0.5, 0.5)),
        ]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.black54,
                    size: 18,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    this.title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),

                  // IconButton(icon: Icon(Icons.delete), onPressed: (){})
                ],
              ),
            ),
            SizedBox(
              height: 9,
            ),
            Text(
              this.date.toString(),
              style: TextStyle(
                  fontSize:12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
