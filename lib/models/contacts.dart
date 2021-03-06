import 'dart:convert';

import 'package:http/http.dart';

class Contacts {
  List<Contact> data;
  int page;
  int row;
  int totalRow;

  Contacts({this.data, this.page, this.row, this.totalRow});

  Contacts.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<Contact>();
      json['data'].forEach((v) {
        data.add(new Contact.fromJson(v));
      });
    }
    page = json['page'];
    row = json['row'];
    totalRow = json['total_row'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['row'] = this.row;
    data['total_row'] = this.totalRow;
    return data;
  }
}

class Contact {
  String id;
  String firstName;
  String lastName;
  String email;
  String gender;
  DateTime dateOfBirth;
  String phoneNo;

  Contact(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.gender,
        this.dateOfBirth,
        this.phoneNo});

  factory Contact.fromJson(Map<String, dynamic> json) {

    final dobJson = json["date_of_birth"] == null ? 0 : json["date_of_birth"];
    int dobUnixTimeStamp = 0;

    try {
      dobUnixTimeStamp = int.parse(dobJson);
    } on FormatException {
      print('Format error!');
    }

    return new Contact(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      gender: json["gender"] == "male" ? "Male" : json["gender"],
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(dobUnixTimeStamp*1000),

      phoneNo: json['phone_no'],
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['phoneNo'] = this.phoneNo;
    return data;
  }

  Future<String> save() async {
    return  await _makePostRequest();
  }

  Future<String> removeContact() async {

    String userId = id;
    Map<String, String> headers = {"Content-type": "application/json"};
    String url = 'https://mock-rest-api-server.herokuapp.com/api/v1/user/$id';
    Response response = await delete(url, headers: headers);

    int statusCode = response.statusCode;
//    // this API passes back the id of the new item added to the body
    String body = response.body;

    print('delete: status: $statusCode, body: $body');

    final decodedResponse = jsonDecode(body);

    if (statusCode == 200) {
      return 'Delete successful';
    } else {
      return 'Delete failed. Status code $statusCode. ${decodedResponse['error'] ?? ""}';
    }

  }

  Future<String> _makePostRequest() async {
    // set up POST request arguments
    String userId = id != null ? "/"+id : "";
    String url = 'https://mock-rest-api-server.herokuapp.com/api/v1/user'+userId;
    Map<String, String> headers = {"Content-type": "application/json"};
    String json = "{}";
    Response response;
    // make request
    if (id != null) {
      json = '{"id": "$id", "first_name": "${firstName.trim()}", "last_name": "${lastName.trim()}", "email": "${email.trim()}", "gender": "${gender.trim()}", "date_of_birth": "${dateOfBirth.millisecondsSinceEpoch/1000}", "phone_no": "${phoneNo.trim()}"}';
      response = await put(url, headers: headers, body: json);
    } else {
      json = '{"first_name": "${firstName.trim()}", "last_name": "${lastName.trim()}", "email": "${email.trim()}", "gender": "${gender.trim()}", "date_of_birth": "${(dateOfBirth.millisecondsSinceEpoch/1000).round()}", "phone_no": "${phoneNo.trim()}"}';
      response = await post(url, headers: headers, body: json);
    }

//    // check the status code for the result
    int statusCode = response.statusCode;
//    // this API passes back the id of the new item added to the body
    String body = response.body;

    print('payload $json, url: $url, response: $body, id: $id');

    final decodedResponse = jsonDecode(body);

    if (statusCode == 200) {
      return 'Save successful';
    } else {
      return 'Save failed. Status code $statusCode. ${decodedResponse['error'] ?? ""}';
    }
  }
}