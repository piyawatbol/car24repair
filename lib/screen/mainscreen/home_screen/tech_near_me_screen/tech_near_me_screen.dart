import 'dart:convert';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class TechNearMeScreen extends StatefulWidget {
  TechNearMeScreen({Key? key}) : super(key: key);

  @override
  State<TechNearMeScreen> createState() => _TechNearMeScreenState();
}

class _TechNearMeScreenState extends State<TechNearMeScreen> {
  Position? userLocation;
  List garageList = [];
  List<Marker> listMap = [];
  bool show = false;
  String? user_img;
  String? name;
  String? lastname;
  String? phone;
  String? email;
  GoogleMapController? mapController;
  late BitmapDescriptor mapMaker;
  double? distance;
  String? time;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

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

  get_garage() async {
    var url = Uri.parse('$ipcon/garage/get_garage_user.php');
    var response = await http.get(url);
    var data = json.decode(response.body);
    setState(() {
      garageList = data;
    });
    for (var i = 0; i < garageList.length; i++) {
      var lat = double.parse("${garageList[i]['lati']}");
      var long = double.parse("${garageList[i]['longti']}");
      var title = garageList[i]['garage_name'].toString();
      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/location_marker.png', 120);
      listMap.add(
        Marker(
          onTap: () {
            calculateDistance(
              userLocation!.latitude,
              userLocation!.longitude,
              double.parse(garageList[i]['lati']),
              double.parse(
                garageList[i]['longti'],
              ),
            );
            setState(() {
              user_img = garageList[i]['user_img'];
              name = garageList[i]['name'];
              lastname = garageList[i]['lastname'];
              phone = garageList[i]['phone'];
              email = garageList[i]['email'];
              show = true;
            });
          },
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: MarkerId(i.toString()),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: title.toString(),
          ),
        ),
      );
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  calculateDistance(double lat1, double long1, double lat2, double long2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat1 - lat2) * p) / 2 +
        c(lat2 * p) * c(lat1 * p) * (1 - c((long2 - long1) * p)) / 2;
    setState(() {
      distance = double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2));
      print("distance: ${distance}");
      if (((distance! / 30) * 60) < 1) {
        time = "${(((distance! / 30) * 60) * 60).toStringAsFixed(2)} วินาที";
      } else {
        time = "${((distance! / 30) * 60).toStringAsFixed(2)} นาที";
      }
      print(time);
    });
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
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppbarCustom(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AutoText(
                        width: width * 0.9,
                        text: "ช่างซ่อมใกล้ฉัน",
                        fontSize: 60,
                        color: purple,
                        text_align: TextAlign.left,
                        fontWeight: null,
                      ),
                    ),
                  ],
                ),
                buildMap()
              ],
            ),
            buildPopup()
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.7,
      child: FutureBuilder(
        future: _getLocation(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              markers: listMap.toSet(),
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                zoom: 14,
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

  buildPopup() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: show,
      child: GestureDetector(
        onTap: () {
          setState(() {
            show = false;
          });
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: Colors.black12),
            child: Center(
              child: Container(
                width: width,
                height: height * 0.65,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      width: width,
                      height: height * 0.13,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            user_img == null || user_img == ""
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/profile.jpg"),
                                    backgroundColor: Colors.grey,
                                    radius: width * 0.11,
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: width * 0.11,
                                    backgroundImage: NetworkImage(
                                        "$ipcon/images_user/$user_img"),
                                  ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: height * 0.02),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AutoText(
                                    width: width * 0.6,
                                    text: "ชื่อ : $name $lastname",
                                    fontSize: 20,
                                    color: purple,
                                    text_align: TextAlign.justify,
                                    fontWeight: null,
                                  ),
                                ],
                              ),
                            )
                          ]),
                    ),
                    Container(
                      width: double.infinity,
                      height: height * 0.22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 0.2,
                            blurRadius: 3,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.07,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.015),
                            garageList.isEmpty
                                ? buildRowPhone("เบอร์โทร", "...")
                                : buildRowPhone("เบอร์โทร", "${phone}"),
                            garageList.isEmpty
                                ? buildRowEmail("อีเมล", "...")
                                : buildRowEmail(
                                    "อีเมล",
                                    "${email}",
                                  )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.02, horizontal: width * 0.07),
                      width: width,
                      height: height * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoText(
                            width: width * 0.5,
                            text: "อยู่ห่างจากคุณ",
                            fontSize: 24,
                            color: purple,
                            text_align: TextAlign.left,
                            fontWeight: null,
                          ),
                          AutoText(
                            width: width * 0.5,
                            text: "$distance KM",
                            fontSize: 24,
                            color: Colors.grey,
                            text_align: TextAlign.left,
                            fontWeight: null,
                          ),
                          AutoText(
                            width: width * 0.5,
                            text: "จะถึงคุณภายใน",
                            fontSize: 24,
                            color: purple,
                            text_align: TextAlign.left,
                            fontWeight: null,
                          ),
                          AutoText(
                            width: width * 0.5,
                            text: "$time",
                            fontSize: 24,
                            color: Colors.grey,
                            text_align: TextAlign.left,
                            fontWeight: null,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [buildButton("กดเรียกช่าง")],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget buildRowPhone(String? text1, String? text2) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.25,
              child: AutoSizeText(
                "$text1 :",
                maxLines: 1,
                minFontSize: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: purple, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.6,
              child: Text(
                "$text2",
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ),
            ),
            Image.asset(
              "assets/images/View_fill.png",
              height: height * 0.035,
            )
          ],
        ),
      ],
    );
  }

  Widget buildRowEmail(String? text1, String? text2) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            Text(
              "$text1 :",
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: purple, fontSize: 24),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$text2",
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Colors.grey, fontSize: 24),
              ),
            ),
            Image.asset(
              "assets/images/View_fill.png",
              height: height * 0.035,
            )
          ],
        ),
      ],
    );
  }

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.007),
      width: width * 0.3,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {},
        child: Center(
          child: Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
