import 'package:car24repair/widget/auto_size_text.dart';
import 'package:flutter/material.dart';
class AddCarText extends StatelessWidget {
  const AddCarText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.135,
      width: width * 0.9,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              child: AutoText(
                  width: null,
                  text: "Add Car",
                  fontSize: 64,
                  color: Colors.white,
                  text_align: TextAlign.left,
                  fontWeight: null)),
          Positioned(
            bottom: 0,
            child: AutoText(
              width: width * 0.68,
              text: "Tell us about your car",
              fontSize: 24,
              color: Colors.white,
              text_align: TextAlign.left,
              fontWeight: null,
            ),
          ),
        ],
      ),
    );
  }
}
