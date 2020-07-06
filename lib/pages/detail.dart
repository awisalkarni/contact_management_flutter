import 'dart:convert';

import 'package:contact_management_flutter/pages/edit.dart';
import 'package:flutter/material.dart';
import 'package:contact_management_flutter/models/contacts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final Contact contact;
  DetailPage({this.contact});

  @override
  State<StatefulWidget> createState() {
    return _DetailPageState(contact: contact);
  }
}

class _DetailPageState extends State<DetailPage> {
  final Contact contact;
  _DetailPageState({this.contact});
  bool isFaved = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((SharedPreferences sp) {

      final rawFav = sp.getString('fav_user_ids') ?? "[]";
      final existingFavList = jsonDecode(rawFav);

      setState(() {
        isFaved = existingFavList.contains(contact.id);
      });

    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(contact.firstName + " " + contact.lastName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => new EditPage(
                              contact: contact,
                            )));
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              color: isFaved ? Colors.red : Colors.grey,
              onPressed: () {
                setState(() {
                  print('saved');
                  if (isFaved) {
                    _removeFromFav(contact);
                    isFaved = false;
                  } else {
                    _saveFavToPref(contact);
                    isFaved = true;
                  }
                });
              },
            ),
          ],
        ),
        body: new ListView(children: <Widget>[
          Hero(
            tag: "avatar_" + contact.firstName,
            child: new Image.network("https://via.placeholder.com/150"),
          ),
          GestureDetector(
              onTap: () {},
              child: new Container(
                padding: const EdgeInsets.all(32.0),
                child: new Row(
                  children: [
                    // First child in the Row for the name and the
                    new Expanded(
                      // Name and Address are in the same column
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Code to create the view for name.
                          new Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Name: " +
                                  contact.firstName +
                                  " " +
                                  contact.lastName,
                              style: new TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Code to create the view for address.
                          Text(
                            "Email: " + contact.email,
                            style: new TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            "Date of Birth: " +
                                DateFormat("dd/MM/yyyy")
                                    .format(contact.dateOfBirth),
                          ),
                          Text(
                            "Gender: " + contact.gender,
                          ),
                        ],
                      ),
                    ),
                    // Icon to indicate the phone number.
                    new Icon(
                      Icons.phone,
                      color: Colors.red[500],
                    ),
                    new Text(' ${contact.phoneNo}'),
                  ],
                ),
              )),
        ]));
  }

  _saveFavToPref(Contact contact) async{
    final prefs = await SharedPreferences.getInstance();

    // read
    final existingFavList = prefs.getString('fav_user_ids') ?? "[]";

    List ids = jsonDecode(existingFavList);
    ids.add(contact.id);


    // write
    prefs.setString('fav_user_ids', jsonEncode(ids));


  }

  _removeFromFav(Contact contact) async{
    final prefs = await SharedPreferences.getInstance();

    // read
    final existingFavList = prefs.getString('fav_user_ids') ?? "";

    List ids = jsonDecode(existingFavList);

    ids.remove(contact.id);

    // write
    prefs.setString('fav_user_ids', jsonEncode(ids));


  }
}
