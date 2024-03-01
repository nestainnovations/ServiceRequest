/*
 *  Webkul Software.
 *  @package  Mobikul Application Code.
 *  @Category Mobikul
 *  @author Webkul <support@webkul.com>
 *  @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 *  @license https://store.webkul.com/license.html 
 *  @link https://store.webkul.com/license.html
 *
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/configuration/mobikul_theme.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/app_constants.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/app_routes.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/app_storage_pref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    navigateToNextScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("SplashScaffoldKey"),
      backgroundColor: Colors.white,
      body: Stack(
        key: const Key("SplashStackKey"),
        children: [
          Container(
            key: const Key("SplashContainerKey"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                AppImages.splashScreen,
                fit: BoxFit.contain, // Adjust the fit to contain the image within its container
                width: MediaQuery.of(context).size.width * 0.8, // Set the width to 80% of the screen width
                height: MediaQuery.of(context).size.height * 0.8, // Set the height to 80% of the screen height
                key: const Key("SplashImageKey"),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: MobikulTheme.primaryColor,
                    key: const Key("SplashIndicatorKey"),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Developed by ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const TextSpan(
                          text: "N",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: "esta ",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: "I",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "nnovations",
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {                                     
                                    launchUrlString("https://nestainnovations.blogspot.com");                                      
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  navigateToNextScreen() {
    Timer(const Duration(seconds: AppConstant.defaultSplashDelaySeconds), () async {
      var isLoggedIn = appStoragePref.isLoggedIn();
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }
}
