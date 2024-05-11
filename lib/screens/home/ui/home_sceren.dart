// ignore_for_file: unused_import, prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../../core/widgets/no_internet.dart';
import '../../../theming/colors.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../theming/styles.dart';
import '/helpers/extensions.dart';
import '/routing/routes.dart';
import '/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          OfflineBuilder(
            connectivityBuilder: (
              BuildContext context,
              ConnectivityResult connectivity,
              Widget child,
            ) {
              final bool connected = connectivity != ConnectivityResult.none;
              return connected ? _homePage(context) : const BuildNoInternet();
            },
            child: const Center(
              child: CircularProgressIndicator(
                color: ColorsManager.mainBlue,
              ),
            ),
          ),
          Nav(),
        ],
      ),
    );
  }

  SafeArea _homePage(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: FirebaseAuth.instance.currentUser!.photoURL == null
                      ? Image.asset('assets/images/placeholder.jpg')
                      : FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading.gif',
                          image: FirebaseAuth.instance.currentUser!.photoURL!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.center,
                child:
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "NAME:",
                  style: TextStyle(
                    color: Colors.grey.shade800, // Set text color to black
                    fontWeight: FontWeight.bold,
                    fontSize: 20 // Set text weight to bold
                  ),
                ),
              ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  FirebaseAuth.instance.currentUser!.displayName!,
                  style: TextStyle(
                    color: Colors.grey.shade700, // Set text color to black
                    fontSize: 17 // Set text weight to bold
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child:
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  "EMAIL:",
                  style: TextStyle(
                    color: Colors.grey.shade800, // Set text color to black
                    fontWeight: FontWeight.bold,
                    fontSize: 20 // Set text weight to bold
                  ),
                ),
              ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Text(
                  FirebaseAuth.instance.currentUser!.email!,
                  style: TextStyle(
                    color: Colors.grey.shade700, // Set text color to black
                    fontSize: 17 // Set text weight to bold
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
                child:
                AppTextButton(
                  buttonText: 'Change Password',
                  textStyle: TextStyles.font16White600Weight,
                  backgroundColor: ColorsManager.mainBlue,
                  onPressed: () async {
                    try {
                      context.pushNamed(Routes.forgetScreen);
                    } catch (e) {
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Forget Password error',
                        desc: e.toString(),
                      ).show();
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
                child:
              AppTextButton(
                  buttonText: 'Sign Out',
                  textStyle: TextStyles.font16White600Weight,
                  backgroundColor: ColorsManager.mainBlue,
                  onPressed: () async {
                    try {
                      FirebaseAuth.instance.signOut();
                      context.pushNamedAndRemoveUntil(
                        Routes.loginScreen,
                        predicate: (route) => false,
                      );
                    } catch (e) {
                      await AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Sign out error',
                        desc: e.toString(),
                      ).show();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
