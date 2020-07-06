import 'package:flutter/material.dart';

import 'package:contact_management_flutter/models/contacts.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}
class _AddPageState extends State {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _contact = Contact();

  String _genderValue = "Male";
  String _dob_button_text = "Date of Birth: Not set";

  String _dob = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add New Contact'),
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
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your first name';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => _contact.firstName = val),
                          ),
                          TextFormField(
                              decoration:
                              InputDecoration(labelText: 'Last name'),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter your last name.';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => _contact.lastName = val)),
                        TextFormField(
                            decoration:
                            InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Plase enter your email';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => _contact.email = val)),
                        TextFormField(
                            decoration:
                            InputDecoration(labelText: 'Phone Number'),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Plase enter your phone number';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => _contact.phoneNo = val)),

                          RaisedButton(
                            child: Text(_dob_button_text),
                            onPressed: (){
                              DatePicker.showDatePicker(context,
                                  theme: DatePickerTheme(
                                    containerHeight: 210.0,
                                  ),
                                  showTitleActions: true,
                                  minTime: DateTime(1900, 1, 1),
                                  maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
                                    print('confirm $date');
                                    _dob = '${date.day}/${date.month}/${date.year}';
                                    setState(() {
                                      _dob_button_text = "Date of Birth: " + _dob;
                                      _contact.dateOfBirth = date;
                                    });
                                  }, currentTime: DateTime.now(), locale: LocaleType.en);
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
                                    _contact.gender = _genderValue;
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
                                      if (_contact.gender == null) {
                                        _contact.gender = "Male";
                                      }
                                      form.save();
                                      _showDialog(context, 'Submitting form');
                                      String status = await _contact.save();
                                      _showDialog(context, status);

                                      if (status.contains("successful")) {
                                        Navigator.pop(context);
                                      }

                                    }
                                  },
                                  child: Text('Save'))),
                        ])))));
  }
  _showDialog(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}