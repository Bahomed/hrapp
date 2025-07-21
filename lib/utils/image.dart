import 'package:flutter/material.dart';

import 'appconstants.dart';


class CustomImage extends StatelessWidget {
  final double size;
  const CustomImage({required this.size,super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      dummyprofile,
      fit: BoxFit.cover,
      width: size,
      height: size,
    );

  }
}
