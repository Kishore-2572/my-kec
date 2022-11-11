import 'package:flutter/material.dart';
import 'package:my_kec/widgets/textspanwidget.dart';
import 'package:url_launcher/url_launcher.dart';

/*
This is the widget of EventInfo page
It shows the details of event (i.e) Organizer, Coordinators, Date, etc,.
Here one widget is used :
    =>textspanwidget - To align text in heading and description formats
Addtional Packages :
    => url_launcher   - To redirect to dialpad for calling coordinator while touching mobile number
*/
class EventDetail extends StatelessWidget {
  const EventDetail({
    Key? key,
    required this.event,
    required this.coordinatorNameList,
    required this.coordinatorNumberList,
  }) : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final event;
  final List<String> coordinatorNameList;
  final List<String> coordinatorNumberList;

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextSpanWidget(
              heading: 'Organizer : ',
              description: event['eventOrganizer'],
            ),
            const SizedBox(height: 10),
            TextSpanWidget(
              heading: 'Date : ',
              description: event['dateOfEvent'],
            ),
            const SizedBox(height: 10),
            TextSpanWidget(
              heading: 'Registration DeadLine : ',
              description: event['registrationDeadLine'],
            ),
            const SizedBox(height: 10),
            TextSpanWidget(
              heading: 'Entry Fee : ',
              description: event['entryFee'],
            ),
            const SizedBox(height: 10),
            const Text('Description : ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(event['eventDescription']),
            const SizedBox(height: 10),
            const Text('Coordinators : ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(
              height: coordinatorNameList.length * 30,
              child: ListView.builder(
                  reverse: true,
                  itemCount: coordinatorNameList.length,
                  itemBuilder: (ctx, i) {
                    String key = coordinatorNameList[i];
                    return SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          Text('    $key'),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(':'),
                          const SizedBox(
                            width: 5,
                          ),
                          TextButton(
                              onPressed: () {
                                try {
                                  launchUrl(Uri.parse(
                                      'tel://${coordinatorNumberList[i]}'));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Something went Wrong')));
                                }
                              },
                              child: Text(coordinatorNumberList[i]))
                        ],
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  try {
                    launchUrl(Uri.parse(event['eventLink']));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something gone wrong')));
                  }
                },
                child: const Text("View"))
          ],
        ),
      )
    ]));
  }
}
