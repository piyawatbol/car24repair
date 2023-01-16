import 'dart:convert';
import 'package:car24repair/screen/mainscreen/drawer/regis_tech_screen.dart/regis_tech_screen.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisGarageScreen extends StatefulWidget {
  RegisGarageScreen({Key? key}) : super(key: key);

  @override
  State<RegisGarageScreen> createState() => _RegisGarageScreenState();
}

class _RegisGarageScreenState extends State<RegisGarageScreen> {
  bool statusLoading = false;
  TextEditingController garage_name = TextEditingController();
  Position? userLocation;
  String? user_id;

  Future<Position?> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return userLocation;
  }

  regis_garage() async {
    var url = Uri.parse('$ipcon/garage/regis_garage.php');
    var response = await http.post(url, body: {
      "garage_name": garage_name.text,
      "lati": userLocation!.latitude.toString(),
      "longti": userLocation!.longitude.toString(),
      "user_id": user_id.toString(),
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "regis success") {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return RegisTech();
        }), (route) => route.isFirst);
      }
    }
  }

  get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
  }

  @override
  void initState() {
    get_user_id();
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
            child: Container(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        AppbarCustom(),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.07),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.03),
                                child: AutoText(
                                  width: width * 0.43,
                                  text: "สร้างที่อยู่อู่ซ่อมรถ",
                                  fontSize: 24,
                                  color: purple,
                                  text_align: TextAlign.center,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              buildBox("ชื่ออู่", width * 0.2, garage_name),
                              buildMap(),
                              buildSaveButton()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  LoadingScreen(statusLoading: statusLoading)
                ],
              ),
            )),
      ),
    );
  }

  buildBox(String? text, double? width2, TextEditingController? controller) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
              width: width * width2!,
              text: text,
              fontSize: 16,
              color: Colors.black,
              text_align: TextAlign.left,
              fontWeight: null),
          SizedBox(height: 2),
          TextField(
            cursorColor: Colors.black,
            controller: controller,
            decoration: buildInputStyle3(context, ""),
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.03),
      width: width,
      height: height * 0.3,
      child: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GoogleMap(
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  zoom: 16,
                  target:
                      LatLng(userLocation!.latitude, userLocation!.longitude),
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  buildSaveButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.8,
      height: height * 0.055,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
        ),
        onPressed: () {
          setState(() {
            statusLoading = true;
          });
          regis_garage();
        },
        child: Text(
          "สมัคร",
          style: GoogleFonts.mitr(
            textStyle: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
