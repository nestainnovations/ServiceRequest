import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:meserve/service/configuration/meserve_theme.dart';
import 'package:meserve/service/constants/app_constants.dart';
import 'package:meserve/service/constants/app_routes.dart';
import 'package:meserve/service/helper/app_storage_pref.dart';
import 'package:new_version_plus/new_version_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  void _checkVersion() async {
    final newVersion = NewVersionPlus(androidId: "com.sunsenz.service");
    final status = await newVersion.getVersionStatus();

    if (status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dialogText: 'A new version of the app is available! Please update to continue.',
        updateButtonText: 'Update Now',
        dismissButtonText: 'Later',
        dismissAction: () {
          _navigateToHome();
        },
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Timer(const Duration(seconds: AppConstant.defaultSplashDelaySeconds), () {
      var isLoggedIn = appStoragePref.isLoggedIn();
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              AppImages.splashScreen,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
            ),
          ),
          Positioned(
            bottom: 20,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: MobikulTheme.primaryColor),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(text: "Developed by ", style: TextStyle(color: Colors.grey)),
                      const TextSpan(text: "N", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const TextSpan(text: "esta ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      const TextSpan(text: "I", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}
