// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/select_img_car_screen.dart';
import 'package:car24repair/widget/addcar_text.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmInfoCarScreen extends StatefulWidget {
  String? engine_type;
  String? car_brand;
  String? car_model;
  String? car_sub_model;
  String? gear;
  String? color;
  String? car_regis;
  String? province;
  ConfirmInfoCarScreen(
      {required this.car_regis,
      required this.color,
      required this.gear,
      required this.province,
      required this.car_brand,
      required this.engine_type,
      required this.car_model,
      required this.car_sub_model});

  @override
  State<ConfirmInfoCarScreen> createState() => _ConfirmInfoCarScreenState();
}

class _ConfirmInfoCarScreenState extends State<ConfirmInfoCarScreen> {
  void initState() {
    super.initState();
  }

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
              AddCarText(),
              SizedBox(height: height * 0.04),
              Text(
                "ยืนยันข้อมูลของคุณ",
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              buildBoxInfo(),
              buildButtonNext("ไปต่อ")
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBoxInfo() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      width: width * 0.8,
      height: height * 0.48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoText(
                    width: width * 0.4,
                    text: widget.car_brand.toString(),
                    fontSize: 35,
                    color: purple,
                    text_align: TextAlign.left,
                    fontWeight: null,
                  ),
                  AutoText(
                    width: width * 0.4,
                    text: widget.car_model.toString(),
                    fontSize: 20,
                    color: purple,
                    text_align: TextAlign.left,
                    fontWeight: null,
                  ),
                  SizedBox(
                    width: width * 0.8,
                    child: AutoSizeText(
                      widget.car_sub_model.toString(),
                      maxLines: 2,
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(color: purple, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              AutoText(
                width: width * 0.18,
                text: "ทะเบียน :",
                fontSize: 19,
                color: purple,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              AutoText(
                width: width * 0.4,
                text: "${widget.car_regis} ${widget.province}",
                fontSize: 16,
                color: Colors.grey,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              AutoText(
                width: width * 0.07,
                text: "สี :",
                fontSize: 19,
                color: purple,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              AutoText(
                width: width * 0.2,
                text: widget.color,
                fontSize: 16,
                color: Colors.grey,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.01),
                child: Divider(
                  color: purple,
                  height: 2,
                ),
              ),
              AutoText(
                width: width * 0.24,
                text: "เครื่องยนต์ :",
                fontSize: 19,
                color: purple,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              AutoText(
                width: width * 0.18,
                text: widget.engine_type,
                fontSize: 16,
                color: Colors.grey,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              AutoText(
                width: width * 0.28,
                text: "ประเภทเกียร์ :",
                fontSize: 19,
                color: purple,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
              AutoText(
                width: width * 0.2,
                text: widget.gear,
                fontSize: 16,
                color: Colors.grey,
                text_align: TextAlign.left,
                fontWeight: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtonNext(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.007),
      width: width * 0.8,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return SelectImgCarScreen(
              car_brand: widget.car_brand,
              car_model: widget.car_model,
              car_regis: widget.car_regis,
              car_sub_model: widget.car_sub_model,
              color: widget.color,
              engine_type: widget.engine_type,
              gear: widget.gear,
              province: widget.province,
            );
          }));
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
