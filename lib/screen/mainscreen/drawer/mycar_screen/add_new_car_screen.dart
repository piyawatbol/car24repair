import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/select_brand_car_screen.dart';
import 'package:car24repair/widget/addcar_text.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewCarScreen extends StatefulWidget {
  AddNewCarScreen({Key? key}) : super(key: key);

  @override
  State<AddNewCarScreen> createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple,
      body: Container(
          child: Column(
        children: [
          AppbarCustom(),
          AddCarText(),
          SizedBox(height: height * 0.15),
          Text(
            "เลือกประเภทรถยนต์",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          SizedBox(height: height * 0.03),
          buildButton("ไฟฟ้า"),
          buildButton("เบนซิน"),
          buildButton("ดีเซล"),
          buildButton("ไฮบริด")
        ],
      )),
    );
  }

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.007),
      width: width * 0.7,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return SelectBrandCarScreen(
              engine_type: text.toString(),
            );
          }));
        },
        child: Center(
          child: Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: purple, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
