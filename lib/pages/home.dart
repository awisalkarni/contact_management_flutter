import 'package:contact_management_flutter/pages/add.dart';
import 'package:contact_management_flutter/pages/detail.dart';
import 'package:contact_management_flutter/pages/favourite.dart';
import 'package:contact_management_flutter/models/contacts.dart';
import 'package:flutter/material.dart';
import 'package:contact_management_flutter/pages/edit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  final TextEditingController _filter = new TextEditingController();

  Contacts _records = new Contacts();
  Contacts _filteredRecords = new Contacts();

  String _searchText = "";


  Icon _searchIcon = new Icon(Icons.search);

  Widget _appBarTitle = new Text("ContactApp");

  @override
  void initState() {
    super.initState();

    _records.data = new List();
    _filteredRecords.data = new List();
    _getOfflineContacts();
//    _getContacts();
  }

  void _getOfflineContacts() async {
    Contacts contacts = await _readOfflineJson();
    setState(() {
      if (contacts.data != null) {
        for (Contact contact in contacts.data) {
          this._records.data.add(contact);
          this._filteredRecords.data.add(contact);
        }
      }

      _getContacts();
    });
  }

  Future<Contacts> _readOfflineJson() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'contacts_key';
    final value = prefs.getString(key) ?? 0;
    final responseJson = value != 0 ? json.decode(value) : json.decode('{"data": []}');

    Contacts contactList = new Contacts.fromJson(responseJson);

    return value != 0 ? contactList : Contacts();
  }

  void _getContacts() async {
    Contacts contacts = await fetchUserFromAPI();
    setState(() {
      //flush first
      _resetRecords();

      for (Contact contact in contacts.data) {
        this._records.data.add(contact);
        this._filteredRecords.data.add(contact);
      }

    });
  }

  Future<Contacts> fetchUserFromAPI() async {
    final response = await http.get('https://mock-rest-api-server.herokuapp.com/api/v1/user');

    final responseJson = json.decode(response.body.toString());
    final offlineJsonString = response.body.toString();
    _saveOfflineJson(offlineJsonString);

    Contacts contactList = new Contacts.fromJson(responseJson);

    return contactList;
  }

  _saveOfflineJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'contacts_key';

    prefs.setString(key, json);
  }

  void _resetRecords() {
    this._records.data = new List();
    this._filteredRecords.data = new List();
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          style: new TextStyle(color: Colors.white),
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            fillColor: Colors.white,
            hintText: 'Search by name',
            hintStyle: TextStyle(color: Colors.white),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text("ContactApp");
        _filter.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: Colors.blue,
      body: _buildList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => new AddPage()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FavouritePage(contactList: _records,)));
            },
          )
        ],
        leading: IconButton(icon: _searchIcon, onPressed: _searchPressed));
  }

  Widget _buildList(BuildContext context) {
    if (_searchText.isNotEmpty) {
      _filteredRecords.data = new List();
      for (int i = 0; i < _records.data.length; i++) {
        if (_records.data[i].firstName
            .toLowerCase()
            .contains(_searchText.toLowerCase()) ||
            _records.data[i].lastName
                .toLowerCase()
                .contains(_searchText.toLowerCase())) {
          _filteredRecords.data.add(_records.data[i]);
        }
      }
    }

    print('records count: ${this._records.data.length}, filtered count: ${this._filteredRecords.data.length}');

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: this
          ._filteredRecords
          .data
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, Contact contact) {
    return Slidable(
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

  _HomeState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _filteredRecords.data = _records.data;
//          this._filteredRecords = this._records;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }




}
