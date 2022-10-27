import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/studentallactivitydetailscreen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/*
This is Student all semester SAP deatil screen
It displays the Points allocated from 3rd to current semester 
Addtional Packages :
    => circular_percent_indicator - To display points in circular format
    => http   - Used for getting data data from PHP backend
*/


// ignore: must_be_immutable
class StudentInfoScreen extends StatelessWidget {
  String rollNumber;
  StudentInfoScreen({Key? key, required this.rollNumber}) : super(key: key);

  Future<Map<String, List>> getStudenData() async {
    final response1 = await http.post(Uri.https(DOMAIN_NAME, GETSTUDENTDATA),
        body: {'rollNumber': rollNumber});
    final response =
        await http.post(Uri.https(DOMAIN_NAME, GETALLSEMSAPDATA), body: {
      'rollNumber': rollNumber,
      'studentBatch': jsonDecode(response1.body)[0]['studentBatch']
    });
    return {
      'studentDetail': jsonDecode(response1.body),
      'sapDetail': jsonDecode(response.body),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(rollNumber, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
        body: FutureBuilder(
          future: getStudenData(),
          builder: (context, snapshot) {
            //On data received
            if (snapshot.hasData) {
              final data = snapshot.data as Map<String, dynamic>;
              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Text(
                      data['studentDetail'][0]['studentName'],
                      style: const TextStyle(
                          fontSize: 20, overflow: TextOverflow.clip),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: ListView.builder(
                        itemCount: data['sapDetail'].length,
                        itemBuilder: (ctx, index) {
                          // To get the totalscore for each semester
                          int totalScore = int.parse(
                              data['sapDetail'][index]['SUM(allocatedMark)']);
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) =>
                                          StudentAllActivityDetailsScreeen(
                                            rollNumber: rollNumber,
                                            semester: data['sapDetail'][index]
                                                ['semester'],
                                            pageKey: '0',
                                          )));
                            },
                            child: Card(
                              elevation: 10,
                              child: ListTile(
                                trailing: CircularPercentIndicator(
                                  radius: 25,
                                  // If total score > 100 percent indicator will fit to 1 else factorize with 100 to fill the circle
                                  percent:
                                      totalScore > 100 ? 1 : totalScore / 100,
                                  center: Text('$totalScore'),
                                  progressColor: Colors.green,
                                  backgroundColor:
                                      const Color.fromARGB(255, 223, 212, 212),
                                  circularStrokeCap: CircularStrokeCap.round,
                                ),
                                //To indicate the semester 
                                title: Text(
                                    'Semester  :  ${data['sapDetail'][index]['semester']}'),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              );
            }
            //Error Handling
            if (snapshot.hasError) {
              return const Center(
                child: Text('Somthing gone wrong'),
              );
            }
            //On waiting
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
