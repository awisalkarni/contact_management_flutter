
import 'dart:convert';

import 'package:contact_management_flutter/pages/edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contact_management_flutter/models/contacts.dart';
import 'package:intl/intl.dart';

import 'package:contact_management_flutter/pages/detail.dart';


class FavouritePage extends StatefulWidget {
  final Contacts contactList;
  FavouritePage({this.contactList});

  @override
  State<StatefulWidget> createState() {
    return _FavouritePageState(contactList: contactList);
  }

}

class _FavouritePageState extends State<FavouritePage> {
  final Contacts contactList;
  Contacts _filteredRecords = new Contacts();
  _FavouritePageState({this.contactList});


  @override
  void initState() {
    this._filteredRecords.data = new List();
    _getContacts();
    super.initState();
  }

  void _getContacts() async {
    List contacts = await _loadFavContacts(contactList);
    setState(() {
      for (Contact contact in contacts) {
        if (!this._filteredRecords.data.contains(contacts)) {
          this._filteredRecords.data.add(contact);
        }

      }
    });
  }

  Future<List> _loadFavContacts(Contacts contactList) async{
    final prefs = await SharedPreferences.getInstance();
    // read
    final rawFav = prefs.getString('fav_user_ids') ?? "[]";
    List favStringList = jsonDecode(rawFav);

    print(favStringList);
    List filteredContacts = new List();

    for (int i = 0; i < contactList.data.length; i++) {
      if (favStringList.contains(contactList.data[i].id)) {
        if (!filteredContacts.contains(contactList.data[i])) {
          print(i);
          print(contactList.data[i].firstName);
          filteredContacts.add(contactList.data[i]);
        }
      }
    }

    return filteredContacts;


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: Text("Favourite Contacts"),
      ),
      backgroundColor: Colors.blue,
      body: ReorderableListView(
        padding: const EdgeInsets.only(top: 20.0),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            _updateMyItems(oldIndex, newIndex);
          });
        },
        children: this
            ._filteredRecords
            .data
            .map((data) => _buildListItem(context, data))
            .toList(),
      ),


    );
  }

  void _updateMyItems(int oldIndex, int newIndex) {
    if(newIndex > oldIndex){
      newIndex -= 1;
    }

    final Contact item = this._filteredRecords.data.removeAt(oldIndex);
    this._filteredRecords.data.insert(newIndex, item);

  }

//  Widget _buildListItem(BuildContext context, Contact contact) {
//    return ListTile(
//      key: ValueKey(contact.id),
//      leading: Container(
//        width: 100.0,
//        height: 100.0,
//        color: Colors.blue,
//      ),
//      trailing:  CircleAvatar(
//        radius: 32,
//        backgroundImage:
//        NetworkImage('https://via.placeholder.com/150'),
//      ),
//      title: Text(contact.firstName + " " + contact.lastName,),
//      subtitle: Text(contact.email),
//
//    );
//  }

  Widget _buildListItem(BuildContext context, Contact contact) {
    return Slidable(
      key: ValueKey(contact.id),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.blueAccent,
        child: Card(
          key: ValueKey(contact.firstName),
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0, color: Colors.white24))),
                  child: Hero(
                      tag: "avatar_" + contact.lastName,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                      ))),
              title: Text(
                contact.firstName + " " + contact.lastName,
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  new Flexible(
                      child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                text: contact.email,
                                style: TextStyle(color: Colors.white),
                              ),
                              maxLines: 3,
                              softWrap: true,
                            ),
                            Text(
                              'Date of Birth: ' +
                                  new DateFormat("dd/MM/yyyy").format(contact.dateOfBirth),
                              style: TextStyle(color: Colors.white),
                            ),
                          ]))
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right,
                  color: Colors.white, size: 30.0),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new DetailPage(
                          contact: contact,
                        )));
              },
            ),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          color: Colors.orange,
          icon: Icons.edit,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => new EditPage(
                      contact: contact,
                    )));
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              _filteredRecords.data.remove(contact);
            });
          },
        ),
      ],
    );
  }


}


