import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_kec/screens/pdfviewscreen.dart';
import 'package:my_kec/widgets/similarsapdetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/apis.dart';

/*
This is Student Activity Information  Screen
It displays the list of submitted files that are in waiting queue of a particular student
Addtional Packages :
    => shared_preferences - Used to store and retrieve data from local storage
    => http   - Used for getting data from PHP backend
    =>url_launcher  - To view the Pdf file
*/
// ignore: must_be_immutable
class ActivityInfoScreen extends StatefulWidget {
  String rollNumber;
  ActivityInfoScreen({Key? key, required this.rollNumber}) : super(key: key);

  @override
  State<ActivityInfoScreen> createState() => _ActivityInfoScreenState();
}

class _ActivityInfoScreenState extends State<ActivityInfoScreen> {
  List<String> activityList = [
    '',
    'Paper Presentation',
    'Project Presentation',
    'Techno Managerial Event',
    'Sports & Games',
    'Membership',
    'Leadership/Organizing Event',
    'VAC/Online Courses',
    'Project to Paper/Patent/Copyright',
    'GATE/CAT/Govt Examns',
    'Placement and Internship',
    'Entrepreneurship',
    'Social Activities'
  ];
  List<bool> showsimilar = [];

  // Function for get SAP details of waiting queue
  Future<List<dynamic>> getSAPDetail() async {
    final pref = await SharedPreferences.getInstance();
    String staffId = pref.getString('staffId') as String;

    // Semester need to check everytime, Because Admin changes Semester after completion of each semester
    final response1 = await http
        .post(Uri.https(DOMAIN_NAME, GETSTAFFDATA), body: {'staffId': staffId});
    String semester = jsonDecode(response1.body)[0]['currentSemester'];
    // TO get the year of Student batch
    String batch = "20${widget.rollNumber.substring(0, 2)}";
    final response = await http.post(Uri.https(DOMAIN_NAME, GETSAPDETAIL),
        body: {
          'rollNumber': widget.rollNumber,
          'studentBatch': batch,
          'semester': semester
        });
    return jsonDecode(response.body);
  }

  // To show alert dialouge when user press accept or reject
  showAlert(
      BuildContext context, String theme, String point, String sapid) async {
    final pref = await SharedPreferences.getInstance();
    String studentBatch = pref.getString('studentBatch') as String;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text("Are You Sure Want To $theme ?"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("YES"),
              onPressed: () async {
                final response = await http
                    .post(Uri.https(DOMAIN_NAME, ALLOCATEMARK), body: {
                  'point': theme == 'Approve'
                      ? point
                      : '0', // If approved Mark will be allocated else '0' point will be added
                  'studentBatch': studentBatch,
                  'sapid': sapid,
                  'stateOfProcess': theme == 'Approve'
                      ? '1'
                      : '2' // 1 - Accepted,  2 - rejected
                });
                if (response.body.contains('Success')) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Point Allocation successfull')));
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Something Gone wrong')));
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
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

  //Function for Converting 24hrs format to 12hrs
  String twelveHourVal(String inputString) {
    var splitTime = inputString.split(":");
    int hour = int.parse(splitTime[0]);
    String suffix = "am";
    if (hour >= 12) {
      hour -= 12;
      suffix = "pm";
    }
    String twelveHourVal = '$hour:${splitTime[1]} $suffix';
    return twelveHourVal;
  }

  // To unfocus the keypad in the app
  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rollNumber,
            style: const TextStyle(color: Colors.black)),
      ),
      body: GestureDetector(
        onTap: (() => FocusScope.of(context).requestFocus(FocusNode())),
        child: FutureBuilder(
            future: getSAPDetail(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data as List<dynamic>;
                List<dynamic> list = data;
                data = data.where((element) {
                  showsimilar.add(false);
                  return element['stateOfProcess'] == "0";
                }).toList();
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (ctx, index) {
                      String time = twelveHourVal(DateFormat('hh:mm').format(
                          DateTime.parse(
                              data[index]['TimeOfUpload'].toString())));
                      // To initialize the expected mark of Student in the
                      final tc = TextEditingController(
                          text: data[index]['expectedMark']);

                      return Card(
                        elevation: 20,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                                child: Text(
                                  activityList[
                                      int.parse(data[index]['sapCategory'])],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              data[index]['sapCategory'] == '1' ||
                                      data[index]['sapCategory'] == '2' ||
                                      data[index]['sapCategory'] == '3'
                                  ? SizedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //To display the organizer of the Event
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Organizer :',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    '\t\t\t\t${data[index]['organiser']}',
                                                    overflow:
                                                        TextOverflow.clip),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          // To display Prize won or not
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text('PrizeWon :',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    '\t\t\t\t${data[index]['prizeWon'].toString() == '0' ? 'Participated' : 'Yes'}'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    // Display Expected mark
                                    const Text('Expected Mark : '),
                                    SizedBox(
                                      width: 80,
                                      height: 30,
                                      // To reallocate the given mark
                                      child: TextField(
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                borderSide: const BorderSide(
                                                    width: 3,
                                                    color: Colors.cyan))),
                                        keyboardType: TextInputType.number,
                                        controller: tc,
                                      ),
                                    ),
                                    const Spacer(),

                                    // Display time of upload
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(data[index]
                                                      ['TimeOfUpload']
                                                  .toString()))),
                                          Text(time)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  data[index]['description'],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                color: Colors.grey,
                                height: 1,
                              ),
                              SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.green),
                                        onPressed: () {
                                          if (tc.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text('Enter Marks')));
                                          } else if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(tc.text)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'It Should contain only numbers')));
                                          } else {
                                            showAlert(context, 'Approve',
                                                tc.text, data[index]['sapId']);
                                          }
                                        },
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.done,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Accept',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                        ),
                                        onPressed: () {
                                          showAlert(context, 'Reject', '',
                                              data[index]['sapId']);
                                        },
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Reject',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )
                                          ],
                                        )),
                                    SizedBox(
                                      width: 110,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PDFViewScreen(
                                                            sapid: data[index]
                                                                ['sapId'])));
                                          },
                                          child: const Text(
                                            'View PDF',
                                            style: TextStyle(fontSize: 15),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showsimilar[index] = !showsimilar[index];
                                    });
                                  },
                                  child: const Text('show similar',
                                      style: TextStyle(fontSize: 20))),
                              if (showsimilar[index])
                                SimilarSapDetail(
                                  sapid: data[index]['sapId'],
                                  sapCategory: data[index]['sapCategory'],
                                  organiser: data[index]['organiser'],
                                  saplist: list,
                                ),
                            ],
                          ),
                        ),
                      );
                    });
              }

              //Error Handling
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }

              //On waiting
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}
