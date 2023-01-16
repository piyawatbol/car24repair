import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        color: purple,
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      child: Row(
                        children: [
                          Text(
                            "แชท",
                            style: GoogleFonts.mitr(
                              textStyle: TextStyle(
                                  color: Color(0xff5755B7), fontSize: 64),
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildSearchBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.8,
      height: height * 0.045,
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ค้นหา",
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Image.asset("assets/images/Search_fill.png")
          ],
        ),
      ),
    );
  }
}
