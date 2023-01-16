// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/mainscreen/home_screen/home_screen.dart';
import 'package:car24repair/widget/addcar_text.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectImgCarScreen extends StatefulWidget {
  String? engine_type;
  String? car_brand;
  String? car_model;
  String? car_sub_model;
  String? gear;
  String? color;
  String? car_regis;
  String? province;
  SelectImgCarScreen(
      {required this.car_brand,
      required this.car_model,
      required this.car_regis,
      required this.car_sub_model,
      required this.color,
      required this.engine_type,
      required this.gear,
      required this.province});

  @override
  State<SelectImgCarScreen> createState() => _SelectImgCarScreenState();
}

class _SelectImgCarScreenState extends State<SelectImgCarScreen> {
  String? user_id;
  File? image;
  bool statusLoading = false;

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

  insert_car() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final uri = Uri.parse("$ipcon/car/insert_car.php");
    var request = http.MultipartRequest('POST', uri);
    if (image != null) {
      var img = await http.MultipartFile.fromPath("img", image!.path);
      request.files.add(img);
    }
    request.fields['user_id'] = user_id.toString();
    request.fields['engine_type'] = widget.engine_type.toString();
    request.fields['gear_type'] = widget.gear.toString();
    request.fields['car_brand'] = widget.car_brand.toString();
    request.fields['car_model'] = widget.car_model.toString();
    request.fields['car_sub_model'] = widget.car_sub_model.toString();
    request.fields['color_car'] = widget.color.toString();
    request.fields['car_regis'] = widget.car_regis.toString();
    request.fields['province'] = widget.province.toString();

    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Toast_Custom("เพิ่มรถเสร็จสิ้น", Colors.green);
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple,
      body: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            Column(
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
                buildInfoCar(),
                buildAddMoreCar(),
                buildButtonNext("เสร็จสิ้น")
              ],
            ),
            LoadingScreen(statusLoading: statusLoading)
          ],
        ),
      ),
    );
  }

  Widget buildInfoCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.01),
      margin: EdgeInsets.symmetric(
          vertical: height * 0.02, horizontal: width * 0.05),
      width: double.infinity,
      height: height * 0.13,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    width: width * 0.3,
                    height: height * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: image == null
                        ? Center(
                            child: AutoText(
                              color: purple,
                              fontSize: 12,
                              fontWeight: null,
                              text_align: TextAlign.center,
                              width: width * 0.14,
                              text: 'ไม่มีรูปภาพ',
                            ),
                          )
                        : Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                )
              ],
            ),
            SizedBox(
              width: width * 0.02,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoText(
                    width: width * 0.3,
                    text: "${widget.car_brand}",
                    fontSize: 24,
                    color: purple,
                    text_align: TextAlign.left,
                    fontWeight: null,
                  ),
                  AutoText(
                    width: width * 0.3,
                    text: "${widget.car_model}",
                    fontSize: 16,
                    color: purple,
                    text_align: TextAlign.left,
                    fontWeight: null,
                  ),
                  SizedBox(
                    width: width * 0.52,
                    child: AutoSizeText(
                      "${widget.car_sub_model}",
                      maxLines: 2,
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(color: purple, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAddMoreCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.05),
      child: GestureDetector(
        onTap: () {
          pickImage();
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          dashPattern: [10, 10],
          color: Colors.white,
          strokeWidth: 2,
          child: Container(
              width: double.infinity,
              height: height * 0.12,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    image != null
                        ? Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: width * 0.08,
                          )
                        : Image.asset(
                            "assets/images/Vector.png",
                            width: width * 0.1,
                            color: Colors.white,
                          ),
                    image != null
                        ? Text(
                            "แก้ไขรูปภาพ",
                            style: GoogleFonts.mitr(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                          )
                        : Text(
                            "เพิ่มรูปภาพ",
                            style: GoogleFonts.mitr(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300),
                            ),
                          )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget buildButtonNext(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: height * 0.07, horizontal: width * 0.05),
      width: double.infinity,
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
          if (image == null) {
            Toast_Custom("กรุณาเพิ่มรูปภาพ", Colors.red);
          } else {
            setState(() {
              statusLoading = true;
            });
            insert_car();
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
