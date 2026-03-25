
import 'package:flutter/material.dart';

OutlineInputBorder borderDesgin(BuildContext context) {
    return OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1.5, color: Theme.of(context).shadowColor),
          );
  }

OutlineInputBorder errorBorderDesgin(BuildContext context) {
    return OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1.5, color: Colors.red),
          );
  }


  OutlineInputBorder borderDesginQty(BuildContext context) {
    return OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(width: 1.5, color: Theme.of(context).shadowColor),
          );
  }


  BoxBorder borderContainers(BuildContext context) {
    return Border.all(
            width: 1.5,
            color: Theme.of(context).shadowColor,
          );
  }