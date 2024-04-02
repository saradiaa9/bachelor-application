// ignore_for_file: library_private_types_in_public_api, use_super_parameters, prefer_const_constructors, non_constant_identifier_names, file_names

//import 'package:bachelor_application/controller/old2.dart';
import 'package:bachelor_application/controller/scan_controller.dart';
import 'package:flutter/material.dart';

import 'constants/color.dart';
import 'constants/text_style.dart';
import 'data/model.dart';

//import 'screens/camera/camera_view.dart';
import 'screens/home/ui/home_sceren.dart';
import 'widgets/custom_paint.dart';

class Nav2 extends StatefulWidget {
  const Nav2({Key? key}) : super(key: key);

  @override
  _Nav2 createState() => _Nav2();
}

class _Nav2 extends State<Nav2> {
  int selectBtn = 1;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: NavigationBar(),
    );
  }

  AnimatedContainer NavigationBar() {
    return AnimatedContainer(
      height: 70.0,
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < navBtn.length; i++)
            GestureDetector(
              onTap: () => setState(() {
                selectBtn = i;
                switch (selectBtn) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanController()),
                    );
                    break;
                }
              }),
              child: iconBtn(i),
            ),
        ],
      ),
    );
  }

  SizedBox iconBtn(int i) {
    bool isActive = selectBtn == i ? true : false;
    var height = isActive ? 60.0 : 0.0;
    var width = isActive ? 50.0 : 0.0;
    return SizedBox(
      width: 75.0,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              height: height,
              width: width,
              duration: const Duration(milliseconds: 600),
              child: isActive
                  ? CustomPaint(
                      painter: ButtonNotch(),
                    )
                  : const SizedBox(),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              navBtn[i].imagePath,
              color: isActive ? selectColor : black,
              scale: 2,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              navBtn[i].name,
              style: isActive ? bntText.copyWith(color: selectColor) : bntText,
            ),
          )
        ],
      ),
    );
  }
}
