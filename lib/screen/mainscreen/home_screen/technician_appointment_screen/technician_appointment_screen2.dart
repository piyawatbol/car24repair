import 'dart:convert';
import 'dart:io';
import 'package:car24repair/screen/mainscreen/home_screen/home_screen.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechnicianAppoinmentScreen2 extends StatefulWidget {
  TechnicianAppoinmentScreen2({Key? key}) : super(key: key);

  @override
  State<TechnicianAppoinmentScreen2> createState() =>
      _TechnicianAppoinmentScreen2State();
}

class _TechnicianAppoinmentScreen2State
    extends State<TechnicianAppoinmentScreen2> {
  File? image;
  List item = [];
  String? selectItem;
  List garageList = [];
  String? _date;
  String? time;
  String? user_id;
  bool statusLoading = false;

  TextEditingController detail = TextEditingController();

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

  add_apm() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final uri = Uri.parse("$ipcon//appointment/add_apm.php");
    var request = http.MultipartRequest('POST', uri);
    if (image != null) {
      var img = await http.MultipartFile.fromPath("img", image!.path);
      request.files.add(img);
    }
    request.fields['user_id'] = user_id!;
    request.fields['detail'] = detail.text;
    request.fields['time'] = time!;
    request.fields['date'] = _date!;
    request.fields['garage_name'] = selectItem!;

    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }), (route) => route.isFirst);
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
        body: Container(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    AppbarCustom(),
                    Row(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: AutoText(
                            width: width * 0.44,
                            text: "นัดช่าง",
                            fontSize: 64,
                            color: purple,
                            text_align: TextAlign.left,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    buildText("เลือกอู่ซ่อมรถ", 0.35),
                    buildDropDown1(),
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildText("วันที่", 0.1),
                          buildDate(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.02),
                      child: Row(
                        children: [
                          buildText("เวลา", 0.1),
                          buildTime(),
                        ],
                      ),
                    ),
                    buildText("สิ่งที่ต้องการ", 0.26),
                    buildDetail(),
                    image == null
                        ? buildAddMoreCar()
                        : GestureDetector(
                            onTap: () {
                              pickImage();
                            },
                            child: Container(
                              width: width * 0.9,
                              height: height * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: grey,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(image!),
                                ),
                              ),
                            ),
                          ),
                    buildButton("ยืนยัน")
                  ],
                ),
                LoadingScreen(statusLoading: statusLoading)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildText(String text, double width2) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Row(
        children: [
          AutoText(
            width: width * width2,
            text: "$text",
            fontSize: 18,
            color: purple,
            text_align: TextAlign.left,
            fontWeight: null,
          ),
        ],
      ),
    );
  }

  Widget buildDate() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(2018, 1, 1),
            maxTime: DateTime(2030, 12, 31),
            theme: DatePickerTheme(
                headerColor: Colors.white,
                backgroundColor: Colors.white,
                itemStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                doneStyle: TextStyle(color: Colors.black, fontSize: 16)),
            onConfirm: (date) {
          setState(() {
            String formattedDate = DateFormat('yyyy-MM-dd').format(date);
            _date = formattedDate;
          });
          print('confirm $date');
        }, currentTime: DateTime.now(), locale: LocaleType.en);
      },
      child: Container(
        width: _date == null ? width * 0.28 : width * 0.37,
        height: height * 0.035,
        // color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _date == null
                ? AutoText(
                    width: width * 0.2,
                    text: "เลือกวันที่",
                    fontSize: 18,
                    color: Colors.blue,
                    text_align: TextAlign.left,
                    fontWeight: FontWeight.w400,
                  )
                : AutoText(
                    width: width * 0.3,
                    text: "$_date",
                    fontSize: 18,
                    color: purple,
                    text_align: TextAlign.left,
                    fontWeight: FontWeight.w400,
                  ),
            Icon(Icons.arrow_drop_down_outlined)
          ],
        ),
      ),
    );
  }

  Widget buildTime() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        DatePicker.showTimePicker(context, showTitleActions: true,
            onConfirm: (date) {
          setState(() {
            String formattedDate = DateFormat('kk:mm').format(date);
            time = formattedDate;
          });
        }, currentTime: DateTime.now());
      },
      child: Container(
        width: time == null ? width * 0.28 : width * 0.28,
        height: height * 0.035,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            time == null
                ? AutoText(
                    width: width * 0.2,
                    text: "เลือกเวลา",
                    fontSize: 18,
                    color: Colors.blue,
                    text_align: TextAlign.left,
                    fontWeight: FontWeight.w400,
                  )
                : AutoText(
                    width: width * 0.19,
                    text: "$time",
                    fontSize: 18,
                    color: purple,
                    text_align: TextAlign.left,
                    fontWeight: FontWeight.w400,
                  ),
            Icon(Icons.arrow_drop_down_outlined)
          ],
        ),
      ),
    );
  }

  Widget buildDetail() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      width: width * 0.9,
      height: height * 0.14,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: detail,
        maxLines: 5,
        decoration: buildInputStyle(context, ""),
      ),
    );
  }

  Widget buildDropDown1() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.015),
      width: width * 0.88,
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

  Widget buildAddMoreCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.06, vertical: height * 0.02),
      child: GestureDetector(
        onTap: () {
          pickImage();
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(15),
          dashPattern: [10, 10],
          color: purple,
          strokeWidth: 2,
          child: Container(
              width: double.infinity,
              height: height * 0.15,
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
                      "แนบรูปภาพ",
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

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.03),
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
          setState(() {
            statusLoading = true;
          });
          add_apm();
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
