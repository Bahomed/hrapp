import 'package:flutter/cupertino.dart';

import 'appconstants.dart';
import 'package:flutter/material.dart';

BoxDecoration backgroundDecoration(BuildContext context){
 return BoxDecoration(
     color: Theme.of(context).scaffoldBackgroundColor,

      //image: const DecorationImage(image: AssetImage(backgroundImage),fit: BoxFit.cover)
  );

}