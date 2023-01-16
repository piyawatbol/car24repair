// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  bool? statusLoading;
  LoadingScreen({required this.statusLoading});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: statusLoading == true ? true : false,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white30),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}
