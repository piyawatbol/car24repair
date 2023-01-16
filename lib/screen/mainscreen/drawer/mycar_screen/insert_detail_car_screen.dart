// ignore_for_file: must_be_immutable

import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/confirm_info_car_screen.dart';
import 'package:car24repair/widget/addcar_text.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InsertDetailCarScreen extends StatefulWidget {
  String? engine_type;
  String? car_brand;
  String? car_model;
  String? car_sub_model;
  InsertDetailCarScreen(
      {required this.car_brand,
      required this.car_model,
      required this.car_sub_model,
      required this.engine_type});

  @override
  State<InsertDetailCarScreen> createState() => _InsertDetailCarScreenState();
}

class _InsertDetailCarScreenState extends State<InsertDetailCarScreen> {
  TextEditingController color = TextEditingController();
  TextEditingController car_regis = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController gear = TextEditingController();

  @override
  void initState() {
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
        backgroundColor: purple,
        body: Container(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppbarCustom(),
                AddCarText(),
                SizedBox(height: height * 0.07),
                buildBox("ประเภทเกียร์", gear, 0.3),
                buildBox("สีรถ", color, 0.1),
                buildBox("ทะเบียน", car_regis, 0.18),
                buildBox("จังหวัด", province, 0.18),
                buildButtonNext("ไปต่อ")
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBox(
      String? text, TextEditingController? controller, double? width2) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        AutoText(
            width: width * width2!,
            text: text,
            fontSize: 24,
            color: Colors.white,
            text_align: TextAlign.center,
            fontWeight: null),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.12, vertical: height * 0.01),
          child: TextField(
            controller: controller,
            decoration: buildInputStyle2(context, ""),
          ),
        ),
      ],
    );
  }

  Widget buildButtonNext(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.03),
      width: width * 0.75,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          if (gear.text == "") {
            Toast_Custom("กรุณากรอกประเภทเกียร์", Colors.red);
          } else if (color.text == "") {
            Toast_Custom("กรุณากรอกสีรถ", Colors.red);
          } else if (car_regis.text == "") {
            Toast_Custom("กรุณากรอกทะเบียนรถ", Colors.red);
          } else if (province.text == "") {
            Toast_Custom("กรุณากรอกจังหวัดทะเบียนรถ", Colors.red);
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return ConfirmInfoCarScreen(
                car_regis: car_regis.text,
                color: color.text,
                province: province.text,
                gear: gear.text,
                car_brand: widget.car_brand,
                car_model: widget.car_model,
                engine_type: widget.engine_type,
                car_sub_model: widget.car_sub_model,
              );
            }));
          }
        },
        child: Center(
          child: Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
