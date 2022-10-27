import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/eventdetails.dart';

/*
This is Info of the Event 
This page uses Hero transition for image 
Here one Widgtes used
    => EventDetail

*/

class EventsInfoScreen extends StatelessWidget {
  var event;
  EventsInfoScreen({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // To get Dark or Bright theme used
    var brightness=MediaQuery.of(context).platformBrightness;

    var coordinatorNameList = event['coordinatorName'].toString().split(',');
    var coordinatorNumberList =
        event['coordinatorNumber'].toString().split(',');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event['eventName'] as String,
                //To change text color based on theme used
                style: TextStyle(color:brightness==Brightness.dark?Colors.white:Colors.black)
              ),
              background: Hero(
                tag: event['eventName'] as String,
                child: SizedBox(
                  height: 200,
                  child: Image.memory(
                    base64Decode(
                      event['eventImage'] as String,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          EventDetail(
              event: event,
              coordinatorNameList: coordinatorNameList,
              coordinatorNumberList: coordinatorNumberList)
        ],
      ),
    );
  }
}

