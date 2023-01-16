// ignore_for_file: unnecessary_null_comparison, must_be_immutable
import 'package:car24repair/widget/addcar_text.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/insert_detail_car_screen.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectBrandCarScreen extends StatefulWidget {
  String engine_type;
  SelectBrandCarScreen({required this.engine_type});

  @override
  State<SelectBrandCarScreen> createState() => _SelectBrandCarScreenState();
}

class _SelectBrandCarScreenState extends State<SelectBrandCarScreen> {
  TextEditingController car_brand = TextEditingController();
  TextEditingController car_model = TextEditingController();
  TextEditingController car_sub_model = TextEditingController();
  List item1 = [];
  List item2 = [];
  List item3 = [];
  List dataList1 = [];
  List dataList2 = [];
  List dataList3 = [];
  String? selectItem1;
  String? selectItem2;
  String? selectItem3;

  @override
  void initState() {
    print(widget.engine_type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppbarCustom(),
              AddCarText(),
              SizedBox(height: height * 0.08),
              buildBox("ยี่ห้อรถ", car_brand),
              buildBox("รุ่นรถ", car_model),
              buildBox("รุ่นย่อย", car_sub_model),
              buildButton("ไปต่อ")
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBox(String? text, TextEditingController? controller) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.12, vertical: height * 0.01),
      child: Column(
        children: [
          Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
            controller: controller,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, vertical: height * 0.015),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.05),
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
          if (car_brand.text == "") {
            Toast_Custom("กรุณารอกยี่ห้อรถ", Colors.red);
          } else if (car_model.text == null) {
            Toast_Custom("กรุณากรอกรุ่นรถ", Colors.red);
          } else if (car_sub_model.text == null) {
            Toast_Custom("กรุณากรอกรุ่นย่อย", Colors.red);
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return InsertDetailCarScreen(
                car_brand: car_brand.text,
                car_model: car_model.text,
                car_sub_model: car_sub_model.text,
                engine_type: widget.engine_type.toString(),
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
