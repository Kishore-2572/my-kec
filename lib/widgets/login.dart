import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/forgetpasswordscree.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/*
It is the login card 
It has two text fields like Email & Password field
Addtional Packges :
    => shared_preferences - To store the staff data into the mobiles local storage
    => http   - Used for getting data data from PHP backend
    => crypto - for hashing passwords using MD5 format
*/

class LoginandSignup extends StatefulWidget {
  VoidCallback func;
  LoginandSignup({Key? key, required this.func}) : super(key: key);

  @override
  State<LoginandSignup> createState() => _LoginandSignupState();
}

class _LoginandSignupState extends State<LoginandSignup> {
  final _fkey = GlobalKey<FormState>();
  final pc = TextEditingController();
  bool isvisible = true;
  bool isLoading = false;
  String email = '';
  String pass = '';
  List<String> students = [];

  //To store the logined staff detail in local storage
  void savePreferences(staffEmail, passcode, staffName, designation, section,
      currentSemester, studentBatch, department, staffid) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('email', staffEmail);
    pref.setString('password', passcode);
    pref.setBool('islogin', true);
    pref.setString('name', staffName);
    pref.setString('designation', designation);
    pref.setString('staffId', staffid);
    //Checks if login staff designation
    // If advisor fetch corresponding students for the class
    if (designation == "1") {
      final response =
          await http.post(Uri.https(DOMAIN_NAME, ASSIGNSTUDENTSTOSTAFF), body: {
        'department': department,
        'studentBatch': studentBatch,
        'semester': currentSemester,
        'section': section
      });
      var stu = jsonDecode(response.body);
      List<String> studentList = [];
      //Adding students to the list
      for (var i in stu) {
        studentList.add(i['rollNumber']);
      }
      pref.setString('section', section);
      pref.setString('studentBatch', studentBatch);
      pref.setStringList('students', studentList);
      pref.setString('department', department);
    }

    //Call function in main.dart file to indicate state change
    widget.func();
  }

  //To handle error to user response
  void _showErrorDialog(String msg) {
    var brightness = MediaQuery.of(context).platformBrightness;
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text(
                'An Error has occured',
                style: TextStyle(color: Colors.orange),
              ),
              backgroundColor: brightness == Brightness.dark
                  ? const Color.fromARGB(255, 33, 33, 33)
                  : Colors.white,
              content: Text(msg),
              actions: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ],
            ));
  }

  //To handle submit of the form
  void submit() async {
    if (!_fkey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _fkey.currentState!.save();
    try {
      //Hashing the password for verification
      var bytesToHash = utf8.encode(pass);
      var md5Digest = md5.convert(bytesToHash);
      final response = await http.post(Uri.https(DOMAIN_NAME, STAFFLOGIN),
          body: {'email': email, 'pass': md5Digest.toString()});
      var data = jsonDecode(response.body);
      //Cheching for login contraints
      if (data == 'Wrong password') {
        _showErrorDialog('Wrong Password');
      } else if (data == 'Account not found') {
        _showErrorDialog('Account doesn\'t exist');
      } else {
        savePreferences(
            email,
            pass,
            data[0]['staffName'],
            data[0]['designation'],
            data[0]['section'],
            data[0]['currentSemester'],
            data[0]['studentBatch'],
            data[0]['department'],
            data[0]['staffId']);
      }
    } catch (e) {
      _showErrorDialog('Something went Wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    // To get Dark or Bright theme used
    var brightness = MediaQuery.of(context).platformBrightness;
    return Container(
        height: 360,
        padding:
            const EdgeInsets.only(top: 60, left: 10, right: 10, bottom: 20),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 2,
              color: Colors.black,
            ),
            color: Colors.white),
        margin: const EdgeInsets.only(left: 20, right: 20, top: 200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20),
          child: Form(
              key: _fkey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      border: OutlineInputBorder(),
                      label: Text('Email'),
                    ),
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      // checking validity for email to check wheather it is kongu.ac.in mailID
                      if (val!.isEmpty) {
                        return 'Enter the mail address';
                      } else if (!RegExp(r'^[a-z0-9.&_]+@kongu.ac.in$')
                          .hasMatch(val.toLowerCase())) {
                        return 'Enter the valid mail Id';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      email = val!.toLowerCase();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        border: const OutlineInputBorder(),
                        label: const Text('Password'),
                        suffixIcon: GestureDetector(
                          child: Icon(
                            isvisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.black,
                          ),
                          onTap: () {
                            setState(() {
                              isvisible = !isvisible;
                            });
                          },
                        )),
                    obscureText: isvisible,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Enter the password';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      pass = val!;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: submit,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 20),
                              )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        launchUrl(Uri.https(DOMAIN_NAME, FORGETPASSWORD));
                      },
                      child: const Text('Forget Password'),
                    ),
                  )
                ],
              )),
        ));
  }
}
