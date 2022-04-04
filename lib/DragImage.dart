import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class DragImage extends StatefulWidget {
  const DragImage({Key? key}) : super(key: key);

  @override
  State<DragImage> createState() => _DragImageState();
}

class _DragImageState extends State<DragImage>
    with SingleTickerProviderStateMixin {
  //for zoom animations
  late AnimationController animationController;
  late Animation animation;

  //for image file
  late FilePicker filePicker;
  late String? imageData;
  bool imageLoaded = false;

  //for zoom
  Offset offset = Offset(0,0);

  @override
  void initState() {
    super.initState();

    setUpAnimation();
  }

  setUpAnimation() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween(begin: 1.0, end: 2.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));

    animation.addListener(() {
      setState(() {});
    });
  }

  Future<void> pickFiles() async {
    filePicker = FilePicker.platform;
    FilePickerResult? result = await filePicker.pickFiles(
        type: FileType.image, dialogTitle: 'Pick files', allowMultiple: false);
    if (result != null) {
      imageData = result.files[0].path;
    }

    if (imageData != null) {
      setState(() {
        imageLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Drag Image'),
      ),
      body: Center(
        child: Container(
          child: imageLoaded
              ? GestureDetector(
                  onDoubleTapDown: zoomInorOut,
                  onDoubleTap: (){},
                  onPanUpdate: panUpdate,
                  // onHorizontalDragUpdate: horizontalMotion,
                  // onVerticalDragUpdate: verticalMotion,
                  child: Transform(
                    origin: offset,
                      transform: Matrix4.diagonal3(v.Vector3(
                          animation.value, animation.value, animation.value)),
                      child: ClipRect(
                        child: Image.file(File(imageData!)),
                      )))
              : ElevatedButton(
                  onPressed: pickFiles, child: Text('Pick Images')),
        ),
      ),
    );
  }

  panUpdate(DragUpdateDetails details){
    setState(() {
      double dx = offset.dx, dy = offset.dy;
      var temp = dx - details.delta.dx;
      if(temp < MediaQuery.of(context).size.width && temp > 0){
        dx -= details.delta.dx;
      }
      temp = dy - details.delta.dy;
      if((temp < MediaQuery.of(context).size.height && temp > 0)){
        dy -= details.delta.dy;
      }
      offset = Offset(dx, dy);
    });
  }

  void horizontalMotion(DragUpdateDetails details){
    setState(() {
      final temp = offset.dx - details.delta.dx;
      if(temp < MediaQuery.of(context).size.width && temp > 0){
        offset -= details.delta;
      }
    });
  }

  void verticalMotion(DragUpdateDetails details){
    setState(() {
      final temp = offset.dy - details.delta.dy;
      if(temp < MediaQuery.of(context).size.height && temp > 0){
        offset -= details.delta;
      }
    });
  }

  void scaleUpdate(ScaleUpdateDetails details){
    print(details);
    setState(() {
      offset = details.localFocalPoint;
    });
  }

  void zoomInorOut(TapDownDetails details) {
    if (animationController.isCompleted) {
      animationController.reverse();
    } else {
      offset = details.localPosition;
      animationController.forward();
    }
  }
}
