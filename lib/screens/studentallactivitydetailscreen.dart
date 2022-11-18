import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/pdfviewscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/progress.dart';

/*
It displays the all file submitted in the current semester of a studentapp
Staff can reallocate mark to the student for a file
Here one widget is used :
    => circularprogress - To show the Circular progress of the point allocated
Addtional Packages :
    => shared_preferences - Used to store and retrieve data from local storage
    => http   - Used for getting data from PHP backend
    => url_launcher - Used to view pdf file
    => fluttertoast - To display the toast message
*/

// ignore: must_be_immutable
class StudentAllActivityDetailsScreeen extends StatefulWidget {
  String rollNumber, semester, pageKey;
  StudentAllActivityDetailsScreeen(
      {Key? key,
      required this.rollNumber,
      required this.semester,
      required this.pageKey})
      : super(key: key);

  @override
  State<StudentAllActivityDetailsScreeen> createState() =>
      _StudentAllActivityDetailsScreeenState();
}

class _StudentAllActivityDetailsScreeenState
    extends State<StudentAllActivityDetailsScreeen> {
  final controller = TextEditingController();
  String category = 'All';
  List<String> categoryList = [
    'All',
    'Paper',
    'Project',
    'Techno Managerial',
    'Sports & Games',
    'Membership',
    'Leadership/Organizing',
    'VAC/Online Courses',
    'Project to Paper/Patent/Copyright',
    'GATE/CAT/Govt Examns',
    'Placement and Internship',
    'Entrepreneurship',
    'Social Activities'
  ];

  // To get all the SAP detail of current Semestser
  Future<List<dynamic>> getDetailOfSAP() async {
    String studentBatch = "20${widget.rollNumber.substring(0, 2)}";
    final response =
        await http.post(Uri.https(DOMAIN_NAME, GETALLSTUDENTSAPDETAIL), body: {
      'rollNumber': widget.rollNumber,
      'studentBatch': studentBatch,
      'semester': widget.semester
    });
    return jsonDecode(response.body);
  }

  //To display bottomsheet for entering new mark
  void bottomsheet(String id) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Point field should not be empty',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                        return;
                      }
                      showAlert(id);
                    },
                    child: const Text('Update')),
              ],
            ),
          );
        });
  }

  //To reallocate points to the particular file with its id
  void showAlert(String id) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const Text("Are You Sure Want To Update Score?"),
          actions: <Widget>[
            ElevatedButton(
                child: const Text("YES"),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).pop();
                  final pref = await SharedPreferences.getInstance();
                  String studentBatch =
                      pref.getString('studentBatch') as String;
                  final response = await http
                      .post(Uri.https(DOMAIN_NAME, ALLOCATEMARK), body: {
                    'point': controller.text,
                    'studentBatch': studentBatch,
                    'sapid': id,
                    'stateOfProcess': '1'
                  });
                  if (response.body.contains('Success')) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Point Allocation successfull')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something Gone wrong')));
                  }
                  setState(() {});
                }),
            ElevatedButton(
              child: const Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // To calculate total score in the current semester
  int calTotalScore(list) {
    int totalScore = 0;
    for (var element in list) {
      totalScore += int.parse(element['allocatedMark']);
    }
    return totalScore;
  }

  @override
  Widget build(BuildContext context) {
    // To get Dark or Bright theme used
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rollNumber,
            style: const TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder(
        future: getDetailOfSAP(),
        builder: (context, snapshot) {
          //On Data Received
          if (snapshot.hasData) {
            final data = snapshot.data as List<dynamic>;
            List<dynamic> list = data;
            //Filter based on category
            if (category == 'Paper') {
              list = data
                  .where((element) => element['sapCategory'] == '1')
                  .toList();
            } else if (category == 'Project') {
              list = data
                  .where((element) => element['sapCategory'] == '2')
                  .toList();
            } else if (category == 'Techno Managerial') {
              list = data
                  .where((element) => element['sapCategory'] == '3')
                  .toList();
            } else if (category == 'Sports & Games') {
              list = data
                  .where((element) => element['sapCategory'] == '4')
                  .toList();
            } else if (category == 'Membership') {
              list = data
                  .where((element) => element['sapCategory'] == '5')
                  .toList();
            } else if (category == 'Leadership/Organizing') {
              list = data
                  .where((element) => element['sapCategory'] == '6')
                  .toList();
            } else if (category == 'VAC/Online Courses') {
              list = data
                  .where((element) => element['sapCategory'] == '7')
                  .toList();
            } else if (category == 'Project to Paper/Patent/Copyright') {
              list = data
                  .where((element) => element['sapCategory'] == '8')
                  .toList();
            } else if (category == 'GATE/CAT/Govt Examns') {
              list = data
                  .where((element) => element['sapCategory'] == '9')
                  .toList();
            } else if (category == 'Placement and Internship') {
              list = data
                  .where((element) => element['sapCategory'] == '10')
                  .toList();
            } else if (category == 'Entrepreneurship') {
              list = data
                  .where((element) => element['sapCategory'] == '11')
                  .toList();
            } else if (category == 'Social Activities') {
              list = data
                  .where((element) => element['sapCategory'] == '12')
                  .toList();
            }
            int totalScore = calTotalScore(list);
            int divisor = 80;
            // To set Max point for Selected category
            if (category == 'Techno Managerial' || category == 'Paper') {
              divisor = 75;
            } else if (category == 'Entrepreneurship' ||
                category == 'Social Activities') {
              divisor = 50;
            } else {
              divisor = 80;
            }
            return Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Progress(totalScore: totalScore, divisor: divisor)),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    const SizedBox(child: Text('Filter  :')),
                    const Spacer(),
                    DropdownButton(
                        //To change background color based on theme used
                        dropdownColor: brightness == Brightness.dark
                            ? const Color.fromARGB(255, 59, 59, 59)
                            : Colors.white,
                        value: category,
                        icon: const Icon(Icons.filter_alt_sharp),
                        items: categoryList
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, softWrap: true),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            category = value.toString();
                          });
                        })
                  ]),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (ctx, index) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Text(
                                list[index]['allocatedMark'],
                                softWrap: true,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(list[index]['documentTitle']),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  widget.pageKey == '1'
                                      ? IconButton(
                                          onPressed: () {
                                            bottomsheet(list[index]['sapId']);
                                          },
                                          icon: const Icon(Icons.edit))
                                      : const Spacer(),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PDFViewScreen(
                                                        sapid: list[index]
                                                            ['sapId'])));
                                      },
                                      child: const Text('PDF')),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ))
              ],
            );
          }

          // Error Handling
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to Fetch Records'),
            );
          }

          //On waiting
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
