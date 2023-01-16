import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:flutter/material.dart';

class ApmScreen extends StatefulWidget {
  ApmScreen({Key? key}) : super(key: key);

  @override
  State<ApmScreen> createState() => _ApmScreenState();
}

class _ApmScreenState extends State<ApmScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [AppbarCustom()],
        ),
      ),
    );
  }
}
