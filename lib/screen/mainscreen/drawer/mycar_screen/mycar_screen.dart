import 'dart:convert';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/edit_car_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/add_new_car_screen.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCarScreen extends StatefulWidget {
  MyCarScreen({Key? key}) : super(key: key);

  @override
  State<MyCarScreen> createState() => _MyCarScreenState();
}

class _MyCarScreenState extends State<MyCarScreen> {
  List carList = [];
  String? user_id;

  get_car() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/car/get_car.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      carList = data;
    });
  }

  delete_car(car_id) async {
    var url = Uri.parse('$ipcon/car/delete_car.php');
    var response = await http.post(url, body: {
      "car_id": car_id.toString(),
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      if (data == "delete success") {
        Toast_Custom("ลบเสร็จสิ้น", Colors.green);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return MyCarScreen();
        }));
      } else {
        Toast_Custom("ลบไม่สำเร็จ", Colors.red);
      }
    }
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
      backgroundColor: purple,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppbarCustom(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.033),
                child: Column(
                  children: [
                    Text(
                      "MyCar",
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(color: Colors.white, fontSize: 64),
                      ),
                    ),
                    Text(
                      "Manage Your Car",
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.025),
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
    return Container(
      width: double.infinity,
      height: height * 0.515,
      child: ListView.builder(
        padding: EdgeInsets.all(3),
        itemCount: carList.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SizedBox(width: 2),
                buildButton(Icons.edit, carList[index]['car_id']),
                SizedBox(width: 2),
                buildButton(Icons.delete, carList[index]['car_id'])
              ],
            ),
            child:
                LayoutBuilder(builder: (contextFromLayoutBuilder, constraints) {
              return GestureDetector(
                onTap: () {
                  final slidable = Slidable.of(contextFromLayoutBuilder);
                  slidable?.openEndActionPane(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.decelerate,
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: height * 0.005),
                  width: double.infinity,
                  height: height * 0.16,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: width * 0.4,
                        height: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                "$ipcon/images_car/${carList[index]['car_img']}",
                                fit: BoxFit.cover,
                              )),
                        ),
                      ),
                      Container(
                        width: width * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${carList[index]['car_model']}",
                                style: GoogleFonts.mitr(
                                    textStyle: TextStyle(color: Colors.black),
                                    fontSize: 16),
                              ),
                              buildRowText(
                                  "ทะเบียน", "${carList[index]['car_regis']}"),
                              buildRowText(
                                  "สีรถ", "${carList[index]['color_car']}"),
                              buildRowText("เครื่องยนต์",
                                  "${carList[index]['engine_type']}"),
                              buildRowText("ประเภทเกียร์",
                                  "${carList[index]['gear_type']}")
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: width * 0.07,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Image.asset(
                            "assets/images/Expand_right_double.png"),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget buildRowText(String? text1, String? text2) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Text(
          "$text1",
          style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.black), fontSize: 14),
        ),
        SizedBox(
          width: width * 0.02,
        ),
        Text(
          "$text2",
          style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.grey), fontSize: 14),
        ),
      ],
    );
  }

  Widget buildAddMoreCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.02),
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
          color: Colors.white,
          strokeWidth: 2,
          child: Container(
              width: double.infinity,
              height: height * 0.13,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Vector.png",
                      width: width * 0.1,
                      color: Colors.white,
                    ),
                    Text(
                      "Add More Car",
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

  Widget buildButton(IconData? icon, String? car_id) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.007),
      width: width * 0.235,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: icon == Icons.delete ? Colors.red : Colors.grey,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          if (icon == Icons.delete) {
            buildAlert(context, "คุณต้องการที่จะลบรถไหม?", car_id);
          } else {
            buildAlert(context, "คุณต้องการที่จะแก้ไขรถไหม?", car_id);
          }
        },
        child: Center(
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  buildAlert(context, String? text, String? car_id) {
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
                Navigator.pop(context);
                if (text == "คุณต้องการที่จะลบรถไหม?") {
                  delete_car(car_id);
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return EditCarScreen(
                      car_id: car_id,
                    );
                  }));
                }
              },
              child: Text(
                "ตกลง",
                style: GoogleFonts.mitr(color: Colors.white),
              ),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "ยกเลิก",
                style: GoogleFonts.mitr(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }
}
