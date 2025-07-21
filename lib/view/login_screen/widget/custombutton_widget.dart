import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
final  String text;
  final VoidCallback callback;

  const CustomButtonWidget({required this.text,  required this.callback, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: callback,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomRight: Radius.circular(10))),
      ),
      child:  SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15,color: Colors.black),
          ),
        ),
      ),
    );
  }
}
