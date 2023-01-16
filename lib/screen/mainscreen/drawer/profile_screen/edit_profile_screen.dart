// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'dart:io';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';

import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  String? user_id;
  EditProfileScreen({required this.user_id});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController? name;
  TextEditingController? lastname;
  TextEditingController? phone;
  TextEditingController? email;

  bool statusLoading = false;
  List dataList = [];
  String? image_user;
  File? image;

  get_data_user() async {
    var url = Uri.parse('$ipcon/user/get_user.php');
    var response = await http.post(url, body: {
      "user_id": widget.user_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      dataList = data;
      image_user = dataList[0]['user_img'];
    });

    name = TextEditingController(text: '${dataList[0]['name']}');
    lastname = TextEditingController(text: '${dataList[0]['lastname']}');
    email = TextEditingController(text: '${dataList[0]['email']}');
    phone = TextEditingController(text: '${dataList[0]['phone']}');
  }

  edit_user() async {
    final uri = Uri.parse("$ipcon/user/edit_user.php");
    var request = http.MultipartRequest('POST', uri);
    print(image);
    if (image != null) {
      var img = await http.MultipartFile.fromPath("img", image!.path);
      request.files.add(img);
    }
    request.fields['user_id'] = widget.user_id.toString();
    request.fields['name'] = name!.text;
    request.fields['lastname'] = lastname!.text;
    request.fields['phone'] = phone!.text;
    request.fields['email'] = email!.text;
    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.pop(context);
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (BuildContext context) {
      //   return ProfileScreen();
      // }));
      Toast_Custom("บันทึกข้อมูลเสร็จสิ้น", Colors.green);
    } else {
      setState(() {
        statusLoading = false;
      });
      Toast_Custom("ไม่สามารถบันทึกข้อมูลได้", Colors.red);
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

  @override
  void initState() {
    get_data_user();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return dataList.isEmpty
        ? Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          )
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Container(
                            width: width,
                            height: height * 0.22,
                            color: purple,
                            child: AppbarCustom(),
                          ),
                          Column(
                            children: [
                              SizedBox(height: height * 0.15),
                              Row(
                                children: [
                                  SizedBox(width: width * 0.08),
                                  buildProfile(),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: height * 0.03),
                                width: width,
                                height: height * 0.72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 0.1,
                                      blurRadius: 3,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.08,
                                      vertical: height * 0.03),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      buildBox("ชื่อ :", name),
                                      buildBox("นามสกุล :", lastname),
                                      buildBox("อีเมล :", email),
                                      buildBox("เบอร์โทร :", phone),
                                      SizedBox(
                                        height: height * 0.03,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [buildSaveButton()],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  LoadingScreen(statusLoading: statusLoading)
                ],
              ),
            ),
          );
  }

  Widget buildProfile() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        pickImage();
      },
      child: Container(
          width: width < 380 ? 85 : 100,
          height: height < 680 ? 85 : 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0.2,
                blurRadius: 3,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: image != null
              ? CircleAvatar(backgroundImage: FileImage(image!))
              : image_user == ""
                  ? CircleAvatar(
                      backgroundImage: AssetImage("assets/images/profile.jpg"),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                        ),
                        CircleAvatar(
                          radius: width * 0.11,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              NetworkImage("$ipcon/images_user/$image_user"),
                        ),
                      ],
                    )),
    );
  }

  Widget buildBox(String? text, TextEditingController? controller) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: purple, fontSize: 24),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
            controller: controller,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xff848484),
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
            ),
          ),
        ],
      ),
    );
  }

  buildSaveButton() {
    double width = MediaQuery.of(context).size.width;
    return Container(
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
          setState(() {
            setState(() {
              setState(() {
                statusLoading = true;
              });
              edit_user();
            });
          });
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
