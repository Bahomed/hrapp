import 'package:flutter/cupertino.dart';

BorderRadius borderRadius(){
  return const BorderRadius.only( topLeft: Radius.circular(10),
topRight: Radius.circular(0),
bottomLeft: Radius.circular(0),
bottomRight: Radius.circular(10));
}