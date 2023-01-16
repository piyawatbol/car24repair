import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';

class NotiScreen extends StatefulWidget {
  NotiScreen({Key? key}) : super(key: key);
  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple,
      body: Container(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppbarCustom(),
              Container(
                width: width,
                height: height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.06, vertical: height * 0.02),
                        child: Row(
                          children: [
                            AutoText(
                              width: width * 0.45,
                              text: "การแจ้งเตือน",
                              fontSize: 35,
                              color: purple,
                              text_align: TextAlign.left,
                              fontWeight: FontWeight.w300,
                            )
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: width,
                            height: height * 0.14,
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? Color.fromARGB(255, 137, 136, 200)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 0.4,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
