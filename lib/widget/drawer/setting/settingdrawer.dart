import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/drawer/menudrawer.dart';
import 'package:car24repair/widget/drawer/setting/setting_accout_drawer.dart';
import 'package:car24repair/widget/drawer/setting/setting_display.dart';
import 'package:car24repair/widget/drawer/setting/setting_pin.dart';
import 'package:car24repair/widget/drawer/setting/setting_privacy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class SettingDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  //  double width = MediaQuery.of(context).size.width;
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
          buildListContainer(context, "Book_fill.png", "ตั้งค่าบัญชี"),
          buildListContainer(
              context, "profile_icon.png", "ตั้งค่าความเป็นส่วนตัว"),
          buildListContainer(context, "phone_fill.png", "การแสดงผล"),
          buildListContainer(context, "location.png", "จัดการตำแหน่ง"),
          buildListContainer(context, "Bag_fill.png", "ความสนใจโฆษณา"),
          buildListContainer(
              context, "Unlock_fill.png", "อัพเดท pin / ลายนิ้วมือ"),
        ],
      ),
    );
  }

  Widget buildListContainer(BuildContext context, String? img, String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        if (text == "ตั้งค่าบัญชี") {
          Navigator.pop(context);
          showTopModalSheet(context, SettingAccoutDrawer());
        } else if (text == "ตั้งค่าความเป็นส่วนตัว") {
          Navigator.pop(context);
          showTopModalSheet(context, SettingPrivacyDrawer());
        } else if (text == "การแสดงผล") {
          Navigator.pop(context);
          showTopModalSheet(context, SettingDisplay());
        } else if (text == "อัพเดท pin / ลายนิ้วมือ") {
          Navigator.pop(context);
          showTopModalSheet(context, SettingPin());
        }
      },
      child: Container(
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
              showTopModalSheet(context, MenuDrawer());
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
              showTopModalSheet(context, MenuDrawer());
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
