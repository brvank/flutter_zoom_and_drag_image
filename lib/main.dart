import 'package:drag_image/DragImage.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(DragApp());
}

class DragApp extends StatefulWidget {
  const DragApp({Key? key}) : super(key: key);

  @override
  State<DragApp> createState() => _DragAppState();
}

class _DragAppState extends State<DragApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: DragImage(),
      title: 'Drag App',
    );
  }
}
