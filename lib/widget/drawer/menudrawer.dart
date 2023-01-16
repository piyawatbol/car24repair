import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/screen/loginscreen/login_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/history_screen/history_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/noti_screen/noti_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/chat_screen/chat_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/mycar_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/profile_screen/profile_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/regis_tech_screen.dart/regis_tech_screen.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/drawer/setting/settingdrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.045,
          ),
          Appbar(context),
          buildListContainer(context, "profile_icon.png", "โปรไฟล์", 0.22),
          buildListContainer(context, "key.png", "รถของฉัน", 0.25),
          buildListContainer(context, "message.png", "ข้อความ", 0.22),
          buildListContainer(context, "alert.png", "การแจ้งเตือน", 0.35),
          buildListContainer(
              context, "person_add.png", "สมัครเป็นช่างซ่อม", 0.48),
          buildListContainer(context, "time.png", "ประวัติย้อนหลัง", 0.45),
          buildListContainer(context, "setting.png", "ตั้งค่า", 0.16),
          buildListContainer(context, "logout.png", "ออกจากระบบ", 0.38),
        ],
      ),
    );
  }

  Widget buildListContainer(
      BuildContext context, String? img, String? text, double? width2) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () async {
        if (text == "โปรไฟล์") {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ProfileScreen();
          }));
        } else if (text == "รถของฉัน") {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return MyCarScreen();
          }));
        } else if (text == "ข้อความ") {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ChatScreen();
          }));
        } else if (text == "การแจ้งเตือน") {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return NotiScreen();
          }));
        } else if (text == "สมัครเป็นช่างซ่อม") {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return RegisTech();
          }));
        } else if (text == "ประวัติย้อนหลัง") {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return HistoryScreen();
          }));
        } else if (text == "ตั้งค่า") {
          Navigator.pop(context);
          showTopModalSheet(context, SettingDrawer());
        } else if (text == "ออกจากระบบ") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return LoginScreen();
          }));
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear();
          Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return LoginScreen();
          }), (route) => false);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        width: width,
        height: height * 0.073,
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
                height: height * 0.05,
                child: Image.asset(
                  "assets/images/$img",
                  fit: BoxFit.scaleDown,
                )),
            SizedBox(
              width: width * 0.04,
            ),
            Container(
              width: width * width2!,
              child: AutoSizeText(
                "$text",
                minFontSize: 1,
                maxLines: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: purple, fontSize: 20),
                ),
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
          horizontal: width * 0.06, vertical: height * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SizedBox(
              width: width * 0.31,
              child: AutoSizeText(
                "Car24Repair",
                maxLines: 1,
                minFontSize: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              "assets/images/Vector 10.png",
              width: width * 0.08,
              height: height * 0.023,
            ),
          ),
        ],
      ),
    );
  }
}
