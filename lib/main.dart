import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/uv_desk_app.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper_widgets/restart_widget.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/app_storage_pref.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/pref_keys.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  String selectedLanguage = "en";

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await appStoragePref.init();
  appStoragePref.agentStorage = await Hive.openBox(PreferenceKeys.agentStorageName);

  // Check for app update
  await checkForUpdate();

  runApp(
    RestartWidget(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: MEServe(selectedLanguage),
      ),
    ),
  );
}

Future<void> checkForUpdate() async {
  // Get the current app version
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  // Set your package name here
  String packageName = "com.sunsenz.service"; // Replace with your app's package name

  // Fetch the Play Store page to get the latest version
  final response = await http.get(Uri.parse('https://play.google.com/store/apps/details?id=$packageName'));

  if (response.statusCode == 200) {
    // Use a regex or HTML parser to extract the version from the Play Store page (basic example)
    final regex = RegExp(r'Current Version.*?(\d+\.\d+\.\d+)');
    final match = regex.firstMatch(response.body);

    if (match != null) {
      String latestVersion = match.group(1)!;

      // Compare current version with the latest version
      if (currentVersion != latestVersion) {
        // Show the message or dialog for update
        showUpdateDialog(latestVersion);
      }
    }
  } else {
    // Handle the error if fetching the Play Store page fails
    print("Failed to fetch Play Store page.");
  }
}

void showUpdateDialog(String latestVersion) {
  // Show the dialog if an update is available
  showDialog(
    context: navigatorKey.currentContext!,  // Use navigatorKey to get the current context
    builder: (context) => AlertDialog(
      title: const Text("Update Available"),
      content: Text("A new version ($latestVersion) is available. Please update."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Later"),
        ),
        ElevatedButton(
          onPressed: () {
            // Logic to redirect to Play Store for update
            _launchURL('https://play.google.com/store/apps/details?id=com.sunsenz.service');
            Navigator.of(context).pop();
          },
          child: const Text("Update Now"),
        ),
      ],
    ),
  );
}

Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}