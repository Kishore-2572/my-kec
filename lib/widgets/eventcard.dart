import 'dart:convert';

import 'package:flutter/material.dart';
import '../screens/eventinfoscreen.dart';


/*

This is the card for event 
Image is received in the form of base64 format
Image encoding is done to render the image in app

*/

class EventCard extends StatelessWidget {
  var event;
  EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => EventsInfoScreen(event: event)));
      },
      child: Hero(
        tag: event,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: MemoryImage(base64Decode(event['eventImage'])),
                  fit: BoxFit.fill)),
        ),
      ),
    );
  }
}
