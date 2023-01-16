import 'dart:convert';
import 'package:car24repair/screen/loginscreen/login_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/regis_tech_screen.dart/regis_garage_screen.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisTech extends StatefulWidget {
  RegisTech({Key? key}) : super(key: key);
  @override
  State<RegisTech> createState() => _RegisTechState();
}

class _RegisTechState extends State<RegisTech> {
  bool statusLoading = false;
  String? user_id;
  TextEditingController garage_name = TextEditingController();
  TextEditingController id_card_number = TextEditingController();
  TextEditingController bank_name = TextEditingController();
  TextEditingController back_accout_number = TextEditingController();

  String? brightness;
  bool value1 = false;
  bool value2 = false;
  String? selectItem;
  List item = [];
  List garageList = [];

  get_garage() async {
    var url = Uri.parse('$ipcon/garage/get_garage.php');
    var response = await http.get(url);
    var data = json.decode(response.body);
    setState(() {
      garageList = data;
    });
    for (var i = 0; i < garageList.length; i++) {
      item.add(garageList[i]['garage_name']);
    }
  }

  regis_tech() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/login_system/regis_tech.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
      "garage_name": selectItem.toString(),
      "id_card_number": id_card_number.text,
      "bank_name": bank_name.text,
      "bank_accout_number": back_accout_number.text,
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "regis succes") {
        buildAlert(context, "กรุณาล็อกอินใหม่");
      }
    }
  }

  @override
  void initState() {
    get_garage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: width,
          height: height,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    AppbarCustom(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.08, vertical: height * 0.02),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.05),
                            child: AutoText(
                              width: width * 0.43,
                              text: "สมัครเป็นช่างซ่อม",
                              fontSize: 24,
                              color: purple,
                              text_align: TextAlign.center,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              AutoText(
                                  width: width * 0.2,
                                  text: "ชื่ออู่",
                                  fontSize: 16,
                                  color: Colors.black,
                                  text_align: TextAlign.left,
                                  fontWeight: null),
                            ],
                          ),
                          buildDropDown1(),
                          buildBox("เลขบัตรประชาชน", 0.5, id_card_number),
                          buildBox("ธนาคาร", 0.12, bank_name),
                          buildBox("เลชบัญชีธนาคาร", 0.26, back_accout_number),
                          SizedBox(height: height * 0.03),
                          buildCheckBox1(),
                          buildCheckBox2(),
                          SizedBox(height: height * 0.04),
                          buildSaveButton(),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: height * 0.025),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return RegisGarageScreen();
                                }));
                              },
                              child: Text(
                                "เพิ่มอู่ซ่อมรถ",
                                style: GoogleFonts.mitr(
                                    textStyle: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 16,
                                        color: purple)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LoadingScreen(statusLoading: statusLoading)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropDown1() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.015),
      width: width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0.4,
            blurRadius: 0.5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
            iconSize: width * 0.11,
            borderRadius: BorderRadius.circular(20),
            value: selectItem,
            items: item.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    SizedBox(width: width * 0.08),
                    AutoText(
                      width: width * 0.35,
                      text: item.toString(),
                      fontSize: 20,
                      color: Colors.black,
                      text_align: TextAlign.left,
                      fontWeight: null,
                    )
                  ],
                ),
              );
            }).toList(),
            onChanged: (v) async {
              setState(() {
                selectItem = v.toString();
              });
            }),
      ),
    );
  }

  buildBox(String? text, double? width2, TextEditingController? controller) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
              width: width * width2!,
              text: text,
              fontSize: 16,
              color: Colors.black,
              text_align: TextAlign.left,
              fontWeight: null),
          SizedBox(height: 2),
          TextField(
            cursorColor: Colors.black,
            controller: controller,
            decoration: buildInputStyle3(context, ""),
          ),
        ],
      ),
    );
  }

  buildCheckBox1() {
    return Row(
      children: [
        Theme(
          data: Theme.of(context).copyWith(unselectedWidgetColor: purple),
          child: Checkbox(
              activeColor: purple,
              hoverColor: purple,
              value: value1,
              onChanged: (value) {
                setState(() {
                  this.value1 = value!;
                });
              }),
        ),
        Text(
          "ยืนยันข้อมูลว่าถูกต้อง",
          style: GoogleFonts.mitr(
            textStyle: TextStyle(
                color: purple, fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ),
      ],
    );
  }

  buildCheckBox2() {
    // double height = MediaQuery.of(context).size.height;
    return Row(
      children: [
        Theme(
          data: Theme.of(context).copyWith(unselectedWidgetColor: purple),
          child: Checkbox(
              activeColor: purple,
              hoverColor: purple,
              value: value2,
              onChanged: (value) {
                setState(() {
                  this.value2 = value!;
                });
              }),
        ),
        Text(
          "ฉันยอมรับข้อตกลงการใช้งาน",
          style: GoogleFonts.mitr(
            textStyle: TextStyle(
                color: purple, fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ),
      ],
    );
  }

  buildSaveButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.8,
      height: height * 0.055,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
        ),
        onPressed: () {
          if (!value1) {
            buildAlert(context, "คุณยังไม่ได้ยืนยันข้อมูล");
          } else if (!value2) {
            buildAlert(context, "คุณยังไม่ได้ยอมรับข้อตกลง");
          } else {
            setState(() {
              statusLoading = true;
            });
            regis_tech();
          }
        },
        child: Text(
          "สมัคร",
          style: GoogleFonts.mitr(
            textStyle: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }

  buildAlert(context, String? text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: purple,
          title: Text(
            "แจ้งเตือน",
            style: GoogleFonts.mitr(color: Colors.white),
          ),
          content: Text(
            "$text",
            style: GoogleFonts.mitr(color: Colors.white),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                if (text == "กรุณาล็อกอินใหม่") {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return LoginScreen();
                  }), (route) => false);
                } else {
                  setState(() {
                    statusLoading = false;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                "ตกลง",
                style: GoogleFonts.mitr(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }
}
