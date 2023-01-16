import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/drawer/menudrawer.dart';
import 'package:flutter/material.dart';

import 'package:top_modal_sheet/top_modal_sheet.dart';

class AppbarCustom extends StatelessWidget {
  const AppbarCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: height * 0.125,
      color: purple,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.042),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, vertical: height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: AutoText(
                      width: width * 0.32,
                      text: "Car24Repair",
                      fontSize: 20,
                      color: Colors.white,
                      text_align: TextAlign.left,
                      fontWeight: null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showTopModalSheet(context, MenuDrawer());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
