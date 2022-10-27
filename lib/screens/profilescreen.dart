import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_kec/api/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../widgets/staffdetails.dart';
import '../widgets/studentlistgridview.dart';

/*
This is profileScreen of app
It displays Staff details & Students list
Here there are two Widgets 
    => StaffDetail
    => StudentListGridview
Addtional Packages :
    => shared_preferences - Used to store and retrieve data from local storage
    => http   - Used for getting data from PHP backend
*/

class ProfileScreen extends StatelessWidget {
  final style = const TextStyle(fontSize: 18);

  const ProfileScreen({Key? key}) : super(key: key);

  // Funtion for getting staff details from SharedPreferences
  Future<Map<String, dynamic>> getStaffDetails() async {
    final pref = await SharedPreferences.getInstance();
    String staffId = pref.getString('staffId') as String;
    final response1 = await http
        .post(Uri.https(DOMAIN_NAME, GETSTAFFDATA), body: {'staffId': staffId});

    // Semester need to check everytime, Because Admin changes Semester after completion
    String semester = jsonDecode(response1.body)[0]['currentSemester'];
    return {
      'staffId': pref.getString('staffId') as String,
      'name': pref.getString('name') as String,
      'email': pref.getString('email') as String,
      'department': pref.getString('department') as String,
      'currentYear': (int.parse(semester) / 2)
          .ceil(), // Used ceil function to get CurrentYear
      'studentBatch': pref.getString('studentBatch') as String,
      'semester': semester,
      'section': pref.getString('section') as String,
      'students': pref.getStringList('students') as List
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getStaffDetails(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data as Map<String, dynamic>;
            return Column(
              children: [
                const SizedBox(
                  height: 20,
                  child: Text(
                    'Your Details',
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),

                //  Staff details container
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: MediaQuery.of(context).size.height * 0.23,
                  child: StaffDetails(style: style, data: data),
                ),
                const SizedBox(
                  height: 20,
                  child: Text(
                    'Student List',
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                ),

                // Students list GridView
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: StudentListGridview(data: data),
                )),
              ],
            );
          }

          //Error Handling
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something gone wrong'),
            );
          }

          // On waiting
          return const Center(
            child: CircularProgressIndicator(),
          );
        }));
  }
}
