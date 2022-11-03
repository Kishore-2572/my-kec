import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/alleventsscreen.dart';
import 'package:http/http.dart' as http;

import '../widgets/circularview.dart';
import '../widgets/eventview.dart';

/*
This is the Home page of the app
Here there are two Widgets 
    => EventsView
    => CircularView
Addtional Packages :
    => http   - Used for getting data data from PHP backend

*/

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String search = '';

  // Function for Getting Events

  Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.https(DOMAIN_NAME, GETEVENTS));
    return jsonDecode(response.body);
  }

  // Function for Getting Circulars

  Future<List<Map<String, String>>> getCirculars() async {
    final response2 = await http.get(Uri.https(DOMAIN_NAME, GETCIRCULAR));
    var data = jsonDecode(response2.body);
    List<Map<String, String>> circular = [];
    for (var i in data) {
      circular.add({
        'circularNumber': i['circularNumber'],
        'circularTitle': i['circularTitle'],
        'circularDescription': i['circularDescription'],
        'documentLink': i['documentLink'],
        'timeStamp': i['timeStamp'],
        'userCategory': i['userCategory'],
      });
    }
    return circular;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Events ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                  onPressed: () {
                    // Navigator for going to Events page
                    Navigator.push(context,
                        MaterialPageRoute(builder: (ctx) => AllEventsScreen()));
                  },
                  child: const Text('View All'))
            ],
          ),
        ),

        //Events slider
        search.isEmpty
            ? EventsView(
                getEvents: getEvents,
              )
            : const SizedBox(),

        Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TextField(
              decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.search,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white
                        : null,
                  ),
                  hintText: 'Search circular',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(width: 3, color: Colors.cyan)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(width: 3, color: Colors.cyan))),
              onChanged: (val) {
                setState(() {
                  search = val;
                });
              },
            )),
        //Circulars list
        Expanded(
            child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: CircularView(
            getCirculars: getCirculars,
            search: search,
          ),
        ))
      ],
    );
  }
}
