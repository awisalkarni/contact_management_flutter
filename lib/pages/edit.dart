import 'package:flutter/material.dart';

import 'package:contact_management_flutter/models/contacts.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';


class EditPage extends StatefulWidget {
  final Contact contact;
  EditPage({this.contact});

  @override
  _EditPageState createState() => _EditPageState(contact: contact);
}

class _EditPageState extends State {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Contact contact;
  _EditPageState({this.contact});

  String _genderValue;
  String _dob_button_text;

  String _dob;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _genderValue = contact.gender;
      _dob_button_text = "Date of Birth: " + DateFormat("dd/MM/yyyy").format(contact.dateOfBirth);
      _dob = DateFormat("dd/MM/yyyy").format(contact.dateOfBirth);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Edit'),
          elevation: 0.1,
          backgroundColor: Colors.blue,
          centerTitle: true,),
        body: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Builder(
                builder: (context) => Form(
                    key: _formKey,
                    child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(15.0),
                        children: <Widget>[
                          Image.network(
                            'https://via.placeholder.com/150',
                          ),
                          TextFormField(
                            decoration:
                            InputDecoration(labelText: 'First name'),
                            keyboardType: TextInputType.text,
                            initialValue: contact.firstName,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your first name';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => contact.firstName = val),
                          ),
                          TextFormField(
                              decoration:
                              InputDecoration(labelText: 'Last name'),
                              keyboardType: TextInputType.text,
                              initialValue: contact.lastName,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your last name.';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => contact.lastName = val)),
                          TextFormField(
                              decoration:
                              InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              initialValue: contact.email,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Plase enter your email';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => contact.email = val)),
                          TextFormField(
                              decoration:
                              InputDecoration(labelText: 'Phone Number'),
                              keyboardType: TextInputType.phone,
                              initialValue: contact.phoneNo,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Plase enter your phone number';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => contact.phoneNo = val)),

                          RaisedButton(
                            child: Text(_dob_button_text),
                            onPressed: (){
                              DatePicker.showDatePicker(context,
                                  theme: DatePickerTheme(
                                    containerHeight: 210.0,
                                  ),
                                  showTitleActions: true,
                                  minTime: DateTime(2000, 1, 1),
                                  maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
                                    print('confirm $date');
                                    _dob = '${date.day}/${date.month}/${date.year}';
                                    setState(() {
                                      _dob_button_text = "Date of Birth: " + _dob;
                                      contact.dateOfBirth = date;
                                    });
                                  }, currentTime: contact.dateOfBirth);
                            },
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: <Widget>[
                              Text(
                                "Gender: ",
                              ),
                              DropdownButton<String>(
                                value: _genderValue,
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,

                                underline: Container(
                                  height: 2,

                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _genderValue = newValue;
                                    contact.gender = _genderValue;
                                  });
                                },
                                items: <String>['Male', 'Female']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                    .toList(),

                              ),
                            ],
                          ),




                          Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              child: RaisedButton(
                                  onPressed: () async {
                                    final form = _formKey.currentState;
                                    if (form.validate()) {
                                      if (contact.gender == null) {
                                        contact.gender = "Male";
                                      }
                                      form.save();
                                      _showDialog(context, 'Submitting form');
                                      String status = await contact.save();
                                      _showDialog(context, status);
                                    }
                                  },
                                  child: Text('Save'))),
                        ])))));
  }
  _showDialog(BuildContext context, text) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }
}