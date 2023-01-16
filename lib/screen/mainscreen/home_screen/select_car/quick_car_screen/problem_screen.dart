// ignore_for_file: deprecated_member_use, must_be_immutable
import 'dart:io';

import 'package:car24repair/screen/mainscreen/home_screen/select_car/quick_car_screen/input_location_quick_screen.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProblemScreen extends StatefulWidget {
  String car_id;
  ProblemScreen({required this.car_id});

  @override
  State<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {
  TextEditingController detail = TextEditingController();
  File? image;
  bool value = false;
  String? want_slide_car;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
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
        body: Container(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppbarCustom(),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Text(
                        "ซ่อมรถด่วน",
                        style: GoogleFonts.mitr(
                          textStyle:
                              TextStyle(color: Color(0xff5755B7), fontSize: 64),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.04,
                ),
                Text(
                  "บอกเราเกี่ยวกับปัญหาที่คุณเจอ",
                  style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: purple, fontSize: 24),
                  ),
                ),
                Container(
                    width: width * 0.9,
                    height: height * 0.3,
                    child: buildBox()),
                image == null
                    ? buildAddPicture()
                    : GestureDetector(
                        onTap: () {
                          pickImage();
                        },
                        child: Container(
                          width: width,
                          height: height * 0.2,
                          child: Image.file(image!),
                        ),
                      ),
                buildCheckBox(),
                buildButton("ไปต่อ")
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBox() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.01),
          TextField(
            controller: detail,
            maxLines: 9,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              fillColor: Colors.grey.shade300,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, vertical: height * 0.015),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddPicture() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.06,
      ),
      child: GestureDetector(
        onTap: () {
          pickImage();
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          dashPattern: [10, 10],
          color: purple,
          strokeWidth: 2,
          child: Container(
              width: double.infinity,
              height: height * 0.17,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Vector.png",
                      width: width * 0.1,
                      color: purple,
                    ),
                    Text(
                      "เพิ่มรูปภาพ",
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(
                            color: purple,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  buildCheckBox() {
    double height = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Theme(
          data: Theme.of(context).copyWith(unselectedWidgetColor: purple),
          child: Checkbox(
              activeColor: purple,
              hoverColor: purple,
              value: value,
              onChanged: (value) {
                setState(() {
                  this.value = value!;
                });
              }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          child: Text(
            "ต้องการรถสไสลด์",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(
                  color: purple, fontSize: 24, fontWeight: FontWeight.w300),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.7,
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
          if (value == true) {
            want_slide_car = '1';
          } else {
            want_slide_car = '0';
          }
          if (detail.text == "") {
            Toast_Custom("กรุณากรอกข้อมูล", Colors.red);
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return InputLocationQuickScreen(
                car_id: widget.car_id.toString(),
                image: image,
                detail: detail.text.toString(),
                want_slide_car: want_slide_car.toString(),
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
