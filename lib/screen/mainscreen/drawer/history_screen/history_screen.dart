import 'dart:convert';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? user_id;
  List requestList = [];

  history_request() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/request/history_request.php');
    var response = await http.post(url, body: {
      "user_id": user_id,
    });
    var data = json.decode(response.body);
    setState(() {
      requestList = data;
    });
    print(requestList);
  }

  @override
  void initState() {
    history_request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: requestList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: width,
              height: height,
              child: Column(
                children: [AppbarCustom(), buildListHistory()],
              ),
            ),
    );
  }

  Widget buildListHistory() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: height * 0.02),
        itemCount: requestList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(
                horizontal: width * 0.04, vertical: height * 0.005),
            width: double.infinity,
            height: height * 0.13,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  spreadRadius: 3,
                  blurRadius: 8,
                  offset: Offset(1, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                requestList[0]['img_request'] == ""
                    ? Container(
                        margin: EdgeInsets.all(6),
                        width: width * 0.25,
                        height: height * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0.1,
                              blurRadius: 5,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AutoText(
                            color: purple,
                            fontSize: 16,
                            fontWeight: null,
                            text: 'ไม่มีรูปภาพ',
                            text_align: TextAlign.center,
                            width: width * 0.15,
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.all(6),
                        width: width * 0.61,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                AutoText(
                  color: purple,
                  fontSize: 16,
                  fontWeight: null,
                  text: requestList[0]['detail'],
                  text_align: TextAlign.center,
                  width: width * 0.5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
