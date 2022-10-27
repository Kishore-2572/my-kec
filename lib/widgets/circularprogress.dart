
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';



class CircularProgress extends StatelessWidget {
  int totalScore,radius;
  CircularProgress({Key? key,required this.radius,required this.totalScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius:double.parse(radius.toString()),
      // If total score > 100 percent indicator will fit to 1 else factorize with 100 to fill the circle
      percent: totalScore > 100 ? 1 : totalScore / 100,
      center: Text('$totalScore'),
      progressColor: Colors.green,
      backgroundColor: const Color.fromARGB(255, 223, 212, 212),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
