import 'package:flutter/material.dart';
import 'package:contact_management_flutter/pages/home.dart';

void main() {
  runApp(ContactApp());
}

class ContactApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ContactApp",
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: HomePage(),
//        routes: routes
    );
  }
}

