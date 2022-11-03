import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/activityinfoscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
This is SAPScreen of app
It displays the Students list as roll number who are submitted files and are in waiting queue
Addtional Packages :
    => shared_preferences - Used to store and retrieve data from local storage
    => http   - Used for getting data from PHP backend
*/

class SapScreen extends StatefulWidget {
  const SapScreen({Key? key}) : super(key: key);

  @override
  State<SapScreen> createState() => _SapScreenState();
}

class _SapScreenState extends State<SapScreen> {
  String search = '';

  // Funtion for getting staff details from SharedPreferences
  Future<List<dynamic>> getstaffData() async {
    final pref = await SharedPreferences.getInstance();
    String studentYear = pref.getString('studentBatch') as String;
    String staffId = pref.getString('staffId') as String;

    // Semester need to check everytime, Because Admin changes Semester after completion of each semester
    final response1 = await http
        .post(Uri.https(DOMAIN_NAME, GETSTAFFDATA), body: {'staffId': staffId});
    String semester = jsonDecode(response1.body)[0]['currentSemester'];
    List<String> students = pref.getStringList('students') as List<String>;
    String studentList = students.join(',');

    // To get SAP details of submitted roll number in waiting queue
    final response2 = await http.post(Uri.https(DOMAIN_NAME, GETWAITINGSAP),
        body: {
          'studentBatch': studentYear,
          'semester': semester,
          'studentList': studentList
        });
    return jsonDecode(response2.body);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => FocusScope.of(context).requestFocus(FocusNode())),
      child: Column(
        children: [
          // For search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.98,
              child: TextField(
                  decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.search,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.white
                            : null,
                      ),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(width: 3, color: Colors.cyan)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(width: 3, color: Colors.cyan))),
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  }),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FutureBuilder(
                  future: getstaffData(),
                  builder: (context, ss) {
                    //On data received
                    if (ss.hasData) {
                      final list = ss.data as List<dynamic>;
                      Map<String, int> data = {};
                      // To get the count of number files submitted by the roll number
                      //store in above map data
                      for (var i in list) {
                        if (data.containsKey(i['studentRollNumber'])) {
                          data[i['studentRollNumber']] =
                              (data[i['studentRollNumber']])! + 1;
                        } else {
                          data[i['studentRollNumber']] = 1;
                        }
                      }

                      //Map contains key as roll number
                      //count of files as values
                      List<String> rollNumberList = data.keys.toList();
                      List<int> countList = data.values.toList();

                      return ListView.builder(
                          itemCount: rollNumberList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () {
                                  // Navigator to view particular Student submitted files
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              ActivityInfoScreen(
                                                  rollNumber:
                                                      rollNumberList[index]))));
                                },

                                // Renders conditionally based on search text to filter searches
                                child: (rollNumberList[index]
                                        .toString()
                                        .toLowerCase()
                                        .contains(search
                                            .toLowerCase())) // Returns true if search string matches with any roll number
                                    ? Card(
                                        elevation: 5,
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.black,
                                                child: Text(countList[index]
                                                    .toString()),
                                              ),
                                              title:
                                                  Text(rollNumberList[index]),
                                            )),
                                      )

                                    //on Search string not found returns empty container
                                    : Container()); //
                          });
                    }

                    //Error Handling
                    if (ss.hasError) {
                      return const Center(
                        child: Text('Something Went Wrong'),
                      );
                    }

                    //On Waiting
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
