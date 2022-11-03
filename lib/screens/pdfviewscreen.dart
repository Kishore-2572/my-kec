import 'dart:convert';
import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:my_kec/api/apis.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


/*
This is the PDF viewer Screen page of the app
Here there is only one Widgets 
    => PDFViewer which displays the pdf file
Addtional Packages :
    => http   - Used for getting data data from PHP backend
    =>shared_preferences  -  To get data from local storage
    =>easy_pdf_viewer -  To view the pdf file of students sap PDF
    =>path_provider - To provide path to the PDF file retrieving from DB

*/

class PDFViewScreen extends StatefulWidget {
  const PDFViewScreen({Key? key, required this.sapid}) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final sapid;

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {


  /*
    This function retrieves file from the DB and stores it in the 
    local cache memory and give path to that storage.
    Since PDFviewer accepts the pdf file from the storage
   */
  Future<PDFDocument> loadDocument() async {
    PDFDocument document;
    final pref = await SharedPreferences.getInstance();
    String studentBatch = pref.getString('studentBatch') as String;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/sample.pdf');
    final response = await http.post(Uri.https(DOMAIN_NAME, GETSAPPDF),
        body: {'studentBatch': studentBatch, 'sapId': widget.sapid});
    await file.writeAsBytes(
        base64Decode(jsonDecode(response.body)[0]['sapDocument']));
    String path = file.path;
    File x = File(path);
    document = await PDFDocument.fromFile(x);
    return document;
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PDFViewer'),
        ),
        body: FutureBuilder(
            future: loadDocument(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.hasData) {
                return PDFViewer(
                  document: snapshot.data! as PDFDocument,
                  lazyLoad: false,
                  zoomSteps: 1,
                );
              }
              return const Center(child: CircularProgressIndicator());
            }),
    );
  }
}
