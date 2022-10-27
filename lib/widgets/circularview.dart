import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/*
This file displays the circulars in home page
It is diplayed in form of listview
Addition packages: 
    => url_launcher - Used for viewing circular pdf 
*/

typedef callback = Future<List<Map<String, String>>> Function();

class CircularView extends StatelessWidget {
  callback getCirculars;
  String search;
  CircularView({Key? key, required this.getCirculars, required this.search})
      : super(key: key);
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCirculars(),
        builder: (ctx, ss) {
          //On data received
          if (ss.hasData) {
            List<Map<String, String>> circular =
                ss.data as List<Map<String, String>>;
            if (search.isNotEmpty) {
              circular = circular
                  .where((element) => element['circularTitle']
                      .toString()
                      .toLowerCase()
                      .contains(search.toLowerCase()))
                  .toList();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: circular.length,
                itemBuilder: ((context, index) => Card(
                      elevation: 7,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    circular[index]['circularTitle'] as String),
                                Text(dateFormat.format(DateTime.parse(
                                    circular[index]['timeStamp'] as String)))
                              ],
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  try {
                                    launchUrl(Uri.parse(circular[index]
                                        ['documentLink'] as String));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Something went wrong')));
                                  }
                                },
                                child: const Text('View'))
                          ],
                        ),
                      ),
                    )),
              ),
            );
          }

          // Error Handling
          if (ss.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          //On Waiting
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
