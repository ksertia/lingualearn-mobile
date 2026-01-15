import 'package:flutter/material.dart';

Widget MyPill(String content, {String type='success'}){
  Color? color;
  switch(type){
    case 'success': color = Colors.green; break;
    case 'warning': color = Colors.orange; break;
    case 'info': color = Colors.blue; break;
    default: color = Colors.grey[120]; break;
  }
  return Container(
    padding: EdgeInsets.only(left: 8, right: 8),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
      color: color
    ),
    child: Text(content, style: TextStyle(fontSize: 10))
  );
}
