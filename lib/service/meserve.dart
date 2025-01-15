import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meserve/service/configuration/meserve_theme.dart';
import 'package:meserve/service/constants/app_routes.dart';
import 'package:meserve/service/helper/application_localization.dart';
import 'package:meserve/service/navigation/app_navigation.dart' as app_navigation;

class MEServe extends StatefulWidget {
  final String? selectedLanguage;
  const MEServe(this.selectedLanguage, {Key? key}) : super(key: key);

  @override
  State<MEServe> createState() => _MEServeState();
}

class _MEServeState extends State<MEServe> {
  Locale? _locale;

  @override
  void initState() {
    _locale = const Locale("en");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MobikulTheme.mobikulTheme,
      localizationsDelegates: const [
        ApplicationLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: app_navigation.generateRoute,
      locale: _locale,
      title: "MEServe",
    );
  }
}
