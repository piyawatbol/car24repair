import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/drawer/setting/settingdrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class SettingPrivacyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          Appbar(context),
          buildListContainer(context, "Book_fill.png", "การแสดข้อมูลส่วนตัว"),
          buildListContainer(
              context, "File_dock_fill.png", "การแสดงข้อมูลการติดต่อ "),
          buildListContainer(context, "File.png", "การแสดข้อมูลอื่นๆ"),
        ],
      ),
    );
  }

  Widget buildListContainer(BuildContext context, String? img, String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      width: width,
      height: height * 0.075,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: width * 0.1,
              child: Image.asset(
                "assets/images/$img",
                fit: BoxFit.scaleDown,
              )),
          SizedBox(
            width: width * 0.04,
          ),
          Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: purple, fontSize: 22),
            ),
          )
        ],
      ),
    );
  }

  Widget Appbar(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.06, vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showTopModalSheet(context, SettingDrawer());
            },
            child: Text(
              "Car24Repair",
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showTopModalSheet(context, SettingDrawer());
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
