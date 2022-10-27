import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_kec/widgets/eventcard.dart';

/*
This file displays the events in the home page
Events is displayed in CarouselSlider 
Additional packages  : 
    => carousel_slider  - Used for Scroll events 1 by 1
*/

typedef callback = Future<List<dynamic>> Function();

class EventsView extends StatelessWidget {
  callback getEvents;
  EventsView({Key? key, required this.getEvents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getEvents(),
        builder: (ctx, ss) {
          // On data Received
          if (ss.hasData) {
            final list = ss.data as List<dynamic>;
            if (list.isEmpty) {
              return const SizedBox(
                height: 50,
                child: Text('Temporarily there is no Events '),
              );
            }
            return SizedBox(
              child: CarouselSlider.builder(
                itemCount: list.length,
                options: CarouselOptions(
                  pauseAutoPlayOnTouch: true,
                  viewportFraction: 1,
                  autoPlay: true,
                ),
                itemBuilder: (context, index, i) {
                  return EventCard(event: list[index]);
                },
              ),
            );
          }

          // Error Handling
          if (ss.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          // On Waiting
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
