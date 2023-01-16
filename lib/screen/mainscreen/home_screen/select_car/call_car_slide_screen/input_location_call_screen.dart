// ignore_for_file: must_be_immutable

import 'package:car24repair/screen/mainscreen/home_screen/select_car/call_car_slide_screen/waiting_call_screen.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputLocationScreen extends StatefulWidget {
  String? car_id;
  String? want_slide_car;
  InputLocationScreen({required this.car_id, required this.want_slide_car});
  @override
  State<InputLocationScreen> createState() => _InputLocationScreenState();
}

class _InputLocationScreenState extends State<InputLocationScreen> {
  Position? userLocation;
  String? user_id;
  bool statusLoading = false;

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

  Future add_request() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    final uri = Uri.parse("$ipcon/request/add_request.php");
    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = user_id!;
    request.fields['car_id'] = widget.car_id!;
    request.fields['detail'] = 'ต้องการรถสไลด์';
    request.fields['want_slide_car'] = widget.want_slide_car!;
    request.fields['user_lati'] = userLocation!.latitude.toString();
    request.fields['user_longti'] = userLocation!.longitude.toString();
    var response = await request.send();
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return WaitingCallScreen();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            Column(
              children: [
                AppbarCustom(),
                Row(
                  children: [
                    AutoText(
                      color: purple,
                      fontSize: 60,
                      fontWeight: FontWeight.w400,
                      text: 'เรียกรถสไสด์',
                      text_align: TextAlign.center,
                      width: width,
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.04,
                ),
                Text(
                  "เลือกตำแหน่งที่อยู่ของคุณ",
                  style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: purple, fontSize: 24),
                  ),
                ),
                buildMap(),
                buildButton("ไปต่อ")
              ],
            ),
            LoadingScreen(statusLoading: statusLoading)
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      width: width,
      height: height * 0.53,
      child: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                zoom: 16,
                target: LatLng(userLocation!.latitude, userLocation!.longitude),
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
          backgroundColor: yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          if (userLocation!.latitude == "" || userLocation!.latitude == "") {
            Toast_Custom("กรุณาเช็คตำแหน่งของคุณ", Colors.red);
          } else {
            setState(() {
              statusLoading = true;
            });
            add_request();
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
