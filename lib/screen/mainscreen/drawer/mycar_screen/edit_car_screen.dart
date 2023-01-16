// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/mycar_screen.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditCarScreen extends StatefulWidget {
  String? car_id;
  EditCarScreen({required this.car_id});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  List carList = [];
  String? image_car;
  TextEditingController? brand_name;
  TextEditingController? model_name;
  TextEditingController? sub_model_name;
  TextEditingController? engine_type;
  TextEditingController? gear_type;
  TextEditingController? color_car;
  TextEditingController? car_regis;
  TextEditingController? province;
  File? image;
  bool statusLoading = false;

  get_car() async {
    var url = Uri.parse('$ipcon/car/get_car_one.php');
    var response = await http.post(url, body: {
      "car_id": widget.car_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      carList = data;
      image_car = carList[0]['car_img'];
    });
    brand_name = TextEditingController(text: '${carList[0]['car_brand']}');
    model_name = TextEditingController(text: '${carList[0]['car_model']}');
    sub_model_name =
        TextEditingController(text: '${carList[0]['car_sub_model']}');
    engine_type = TextEditingController(text: '${carList[0]['engine_type']}');
    gear_type = TextEditingController(text: '${carList[0]['gear_type']}');
    color_car = TextEditingController(text: '${carList[0]['color_car']}');
    car_regis = TextEditingController(text: '${carList[0]['car_regis']}');
    province = TextEditingController(text: '${carList[0]['province']}');
  }

  edit_car() async {
    final uri = Uri.parse("$ipcon/car/edit_car.php");
    var request = http.MultipartRequest('POST', uri);
    if (image != null) {
      var img = await http.MultipartFile.fromPath("img", image!.path);
      request.files.add(img);
    }
    request.fields['car_id'] = widget.car_id.toString();
    request.fields['car_brand'] = brand_name!.text;
    request.fields['car_model'] = model_name!.text;
    request.fields['car_sub_model'] = sub_model_name!.text;
    request.fields['engine_type'] = engine_type!.text;
    request.fields['gear_type'] = gear_type!.text;
    request.fields['color_car'] = color_car!.text;
    request.fields['car_regis'] = car_regis!.text;
    request.fields['province'] = province!.text;

    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.pop(context);
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return MyCarScreen();
      }));
      Toast_Custom("บันทึกข้อมูลเสร็จสิ้น", Colors.green);
    } else {
      setState(() {
        statusLoading = false;
      });
      Toast_Custom("ไม่สามารถบันทึกข้อมูลได้", Colors.red);
    }
  }

  pickImage() async {
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
      body: carList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: width,
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppbarCustom(),
                    GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: height * 0.02),
                        width: width * 0.8,
                        height: height * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  "$ipcon/images_car/$image_car",
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.05,
                              vertical: height * 0.01),
                          child: AutoText(
                            width: width * 0.3,
                            text: "แก้ไขข้อมูลรถ",
                            fontSize: 22,
                            color: Colors.white,
                            text_align: TextAlign.left,
                            fontWeight: null,
                          ),
                        ),
                      ],
                    ),
                    buildTextFeild("ชื่อยี่ห้อรถ", brand_name),
                    buildTextFeild("ชื่อรุ่นรถ", model_name),
                    buildTextFeild("ชื่อรุ่นย่อย", sub_model_name),
                    buildTextFeild("เครื่องยนต์", engine_type),
                    buildTextFeild("เกียร์", gear_type),
                    buildTextFeild("สี", color_car),
                    buildTextFeild("ทะเบียน", car_regis),
                    buildTextFeild("จังหวัด", province),
                    buildSaveButton()
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextFeild(String? text, TextEditingController? controller) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: height * 0.01, horizontal: width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
            controller: controller,
            cursorColor: Colors.purple,
            style: TextStyle(color: purple),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, vertical: height * 0.015),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(15),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildSaveButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.04),
      width: width * 0.3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
        ),
        onPressed: () {
          edit_car();
        },
        child: Text(
          "บันทึกข้อมูล",
          style: GoogleFonts.mitr(
            textStyle: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
