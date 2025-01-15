import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meserve/service/meserve.dart';
import 'package:meserve/service/helper_widgets/restart_widget.dart';
import 'package:meserve/service/helper/app_storage_pref.dart';
import 'package:meserve/service/constants/pref_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await appStoragePref.init();
  appStoragePref.agentStorage = await Hive.openBox(PreferenceKeys.agentStorageName);

  runApp(
    RestartWidget(
      child: MEServe("en"),
    ),
  );
}
