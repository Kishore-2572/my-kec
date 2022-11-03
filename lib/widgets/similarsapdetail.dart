import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_kec/api/apis.dart';
import 'package:my_kec/screens/pdfviewscreen.dart';

class SimilarSapDetail extends StatelessWidget {
  SimilarSapDetail(
      {Key? key,
      required this.sapid,
      required this.sapCategory,
      required this.organiser,
      required this.saplist})
      : super(key: key);
  final sapCategory, organiser, sapid;
  List<dynamic> saplist;

  Future<void> getsimilarsap() async {
    saplist = saplist.where((element) {
      return (element['sapCategory'] == sapCategory &&
          element['sapId'] != sapid &&
          element['stateOfProcess'] == "1");
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getsimilarsap(),
        builder: ((context, snapshot) {
          if (saplist.isEmpty) {
            return const Text("No similarities found");
          }
          return SizedBox(
            height: 60 * double.parse(saplist.length.toString()),
            child: ListView.builder(
                itemCount: saplist.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(saplist[index]['documentTitle']),
                        const Spacer(),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,MaterialPageRoute(
                                  builder: (context) => PDFViewScreen(
                                      sapid: saplist[index]['sapId'])));
                            },
                            child: const Text("View"))
                      ],
                    ),
                  );
                }),
          );
        }));
  }
}
