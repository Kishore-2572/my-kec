import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({Key? key}) : super(key: key);
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            'Reset Password',
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Email')),
              controller: controller,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                String mail = controller.text.toString();
                if (mail.isNotEmpty) {
                  if (RegExp(r'^[a-z0-9.]+@kongu.ac.in$')
                      .hasMatch(mail.toLowerCase())) {
                    // Api calling
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                        msg: "Enter valid mail address",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Enter your mail address",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: const Text('Reset'))
        ],
      ),
    );
  }
}
