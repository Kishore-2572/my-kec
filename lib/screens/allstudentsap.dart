import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/studentallactivitydetailscreen.dart';
import 'package:my_kec/widgets/circularprogress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
/*
This is All Student Sap detail screen
It gives overview of current semester SAP details of all submitted students in a listview
Here one widdget is used  :
    => circularprogress - To show the Circular progress of the point allocated
Additional Packages :
    => shared_preferences - Used to store and retrieve data from local storage
    => http   - Used for getting data from PHP backend

*/
class AllStudentsSAP extends StatefulWidget {
  const AllStudentsSAP({Key? key}) : super(key: key);

  @override
  State<AllStudentsSAP> createState() => _AllStudentsSAPState();
}

class _AllStudentsSAPState extends State<AllStudentsSAP> {
  String search = '';
  String semester = '';
  String key = '1';

  // Function to get details of staff so that their Student can map to them
  Future<List<dynamic>> getstaffData() async {
    final pref = await SharedPreferences.getInstance();
    String staffId = pref.getString('staffId') as String;
    final response1 = await http
        .post(Uri.https(DOMAIN_NAME, GETSTAFFDATA), body: {'staffId': staffId});
    // Semester need to check everytime, Because Admin changes Semester after completion 
    semester = jsonDecode(response1.body)[0]['currentSemester'];
    // Get students of the logined Advisor
    String studentBatch = pref.getString('studentBatch') as String;
    List<String> students = pref.getStringList('students') as List<String>;

    String studentList = students.join(',');
    final response = await http
        .post(Uri.https(DOMAIN_NAME, GETALLSTUDENTSPOINTS), body: {
      'studentBatch': studentBatch,
      'semester': semester,
      'studentList': studentList
    });
    return jsonDecode(response.body);
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // For Search tab
        actions: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(5)),
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width * 0.85,
            child: TextField(
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    suffixIconColor: Colors.black,
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.black)),
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                }),
          )
        ],
      ),
      body: FutureBuilder(
          future: getstaffData(),
          builder: (context, snapshot) {
            //On Data Received
            if (snapshot.hasData) {
              List<dynamic> data = snapshot.data as List<dynamic>;
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (ctx, index) {
                        // Getting total points for Circular progress
                        int totalScore =
                            int.parse(data[index]['SUM(allocatedMark)']);
                        return InkWell(
                          //To navigate to detail screen of current semester submitted files
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) =>
                                        StudentAllActivityDetailsScreeen(
                                          rollNumber: data[index]
                                              ['studentRollNumber'],
                                          semester: semester,
                                          pageKey: key,
                                        ))),

                            // Render conditionally based on search string
                            child: data[index]['studentRollNumber']
                                    .toString()
                                    .toLowerCase()
                                    .contains(search.toLowerCase())
                                ? Card(
                                    elevation: 10,
                                    child: SizedBox(
                                      height: 60,
                                      child: ListTile(
                                        trailing: CircularProgress(
                                            radius: 25, totalScore: totalScore),
                                        title: Text(
                                            data[index]['studentRollNumber']),
                                      ),
                                    ),
                                  )
                                  //Returns empty container when Search String not found
                                : Container());
                      }),
                ),
              );
            }
            // For Error Handling
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            //On Waiting
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
