import 'dart:convert';
import 'dart:io';
import 'package:car24repair/screen/mainscreen/home_screen/select_car/call_car_slide_screen/input_location_call_screen.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/add_new_car_screen.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallCarSlideScreen extends StatefulWidget {
  CallCarSlideScreen({Key? key}) : super(key: key);

  @override
  State<CallCarSlideScreen> createState() => _CallCarSlideScreenState();
}

class _CallCarSlideScreenState extends State<CallCarSlideScreen> {
  String? user_id;
  List carList = [];
  File? image;

  get_car() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    print("user_id : $user_id");
    var url = Uri.parse('$ipcon/car/get_car.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      carList = data;
    });
  }

  @override
  void initState() {
    get_car();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppbarCustom(),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Text(
                      "เรียกรถสไลด์",
                      style: GoogleFonts.mitr(
                        textStyle:
                            TextStyle(color: Color(0xff5755B7), fontSize: 64),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.02),
                width: double.infinity,
                child: Text(
                  "เลือกรถของคุณ",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mitr(
                    textStyle:
                        TextStyle(color: Color(0xff5755B7), fontSize: 24),
                  ),
                ),
              ),
              buildListCar(),
              buildAddMoreCar()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: carList.length <= 2 ? height * 0.38 : height * 0.46,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: carList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            height: height * 0.19,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return InputLocationScreen(
                        car_id: carList[0]['car_id'].toString(),
                        want_slide_car: '1');
                  }),
                );
                ;
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                child: Row(
                  children: [
                    Container(
                      width: width * 0.35,
                      height: height * 0.18,
                      child: Image.network(
                        "$ipcon/images_car/${carList[index]['car_img']}",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.01, horizontal: width * 0.04),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.01),
                          AutoText(
                              width: width * 0.37,
                              text: carList[index]['car_model'],
                              fontSize: 16,
                              color: Colors.black,
                              text_align: TextAlign.left,
                              fontWeight: null),
                          buildRowText(
                              "ทะเบียนรถ", "${carList[index]['car_regis']}"),
                          buildRowText("เครื่องยนต์",
                              "${carList[index]['engine_type']}"),
                          buildRowText(
                              "ประเภทเกียร์", "${carList[index]['gear_type']}")
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRowText(String? text1, String? text2) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        AutoText(
            width: width * 0.16,
            text: text1,
            fontSize: 14,
            color: Colors.black,
            text_align: TextAlign.left,
            fontWeight: null),
        SizedBox(
          width: width * 0.02,
        ),
        AutoText(
            width: width * 0.16,
            text: text2,
            fontSize: 14,
            color: Colors.grey,
            text_align: TextAlign.left,
            fontWeight: null),
      ],
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
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return AddNewCarScreen();
          }));
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          dashPattern: [10, 10],
          color: purple,
          strokeWidth: 2,
          child: Container(
              width: double.infinity,
              height: height * 0.12,
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
                      "Add More Car",
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(
                            color: purple,
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
}
