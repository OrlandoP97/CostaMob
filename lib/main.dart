import 'package:costamob/src/models/positionModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/models/fieldWorkModel.dart';
import 'src/pages/start_page.dart';
void main() {
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => new FieldWorkModel()),
    ChangeNotifierProvider(create: (_) => new PositionModel()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     theme: ThemeData(
         primaryColor: Color(0xff571845),
         appBarTheme: AppBarTheme(color: Color(0xff131414)),
         floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor:Color(0xff571845) )

       ),
       
      title: 'Costa Mobile',
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}
