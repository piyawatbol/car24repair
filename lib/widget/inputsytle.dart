import 'package:flutter/material.dart';

buildInputStyle(context, String? img) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return InputDecoration(
    suffixIcon: img != ""
        ? Image.asset(
            "assets/images/$img",
            color: Colors.black,
          )
        : null,
    filled: true,
    fillColor: Color(0xffD9D9D9),
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
  );
}

buildInputStyle2(context, String? img) {
  double width = MediaQuery.of(context).size.width;
  return InputDecoration(
    suffixIcon: img != ""
        ? Image.asset(
            "assets/images/$img",
            color: Colors.black,
          )
        : null,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: width * 0.07),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(30),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(30),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(30),
    ),
  );
}

buildInputStyle3(context, String? img) {
  double width = MediaQuery.of(context).size.width;
  return InputDecoration(
    suffixIcon: img != ""
        ? Image.asset(
            "assets/images/$img",
            color: Colors.black,
          )
        : null,
    filled: true,
    fillColor: Colors.grey.shade300,
    contentPadding: EdgeInsets.symmetric(horizontal: width * 0.07),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(30),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(30),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(30),
    ),
  );
}
