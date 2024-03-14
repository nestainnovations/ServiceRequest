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

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/string_keys.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/app_alert_message.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/application_localization.dart';


class DownloadHelper {
  var tag = "DownloadFile";
  String savePath = "";

// This method is called before the download starts and handles permissions.
  Future<bool> requestPermissions(BuildContext context) async {
    var storageStatus = await Permission.storage.request();
    var mediaStatus = await Permission.mediaLibrary.request();

    if (storageStatus.isGranted || mediaStatus.isGranted) {
      return true;
    } else {
      if (storageStatus.isPermanentlyDenied || mediaStatus.isPermanentlyDenied) {
        await showPermissionDialog(context, "Storage and media permissions are required to download or upload files.");
      }
      return false;
    }
  }

  // Shows a dialog prompting the user to open app settings.
  Future<void> showPermissionDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: const Text("Please grant storage and media permissions to download or upload files."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                openAppSettings(); // Open app settings to allow the user to grant permissions
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

    Future<void> downloadPersonalData(
      String url,
      String fileName,
      String fileType,
      BuildContext context,
    ) async {
      // Capture the context before entering the asynchronous part
      BuildContext? currentContext = context;

      try {
      debugPrint("DOWNLOAD_URL==> $url");
      // Explicitly request storage permission before downloading
      var status = await Permission.storage.request();
      var mediaStatus = await Permission.mediaLibrary.request();
      if (status.isGranted || mediaStatus.isGranted) {
        var dir = await DownloadsPathProvider.downloadsDirectory;
        if (dir != null) {
          String saveName = "";
          if (fileType.isNotEmpty) {
            saveName = "${fileName.toString()}.$fileType";
          } else {
            saveName = fileName.toString();
          }
          String savePath = "${dir.path}/$saveName";
            File file = File(savePath);
              if (await file.exists()) {
                await file.delete();
              }

            try {
              await Dio().download(
                url,
                savePath,
                onReceiveProgress: (received, total) {
                  if (total != -1) {
                    debugPrint("${(received / total * 100).toStringAsFixed(0)}%");
                  }
                },
              );
              // Use the captured context synchronously
              if (currentContext.mounted) {
                AlertMessage.showSuccess(
                  ApplicationLocalizations.instance!
                      .translate(StringKeys.fileSavedOnDownloadFolder),
                  currentContext,
                );
              }
              debugPrint("File is saved to download folder.");
            } on DioException catch (e) {
              debugPrint(e.message);
            }
          }
        } else if (status.isDenied || status.isPermanentlyDenied || mediaStatus.isDenied || mediaStatus.isPermanentlyDenied) {
        // Handle the case where permission is denied or permanently denied
        // Show a dialog to prompt the user to grant permission
            if (currentContext.mounted) {
              AlertMessage.showError(
                ApplicationLocalizations.instance!
                    .translate(StringKeys.noPermissionToReadWriteStorage),
                currentContext,
              );
            }
            debugPrint("${tag}permission is denied ->requesting");
          }
    }  catch (e) {
        // Use the captured context synchronously
        if (currentContext.mounted) {
          AlertMessage.showError(
            ApplicationLocalizations.instance!
                .translate(StringKeys.somethingWentWrong),
            currentContext,
          );
        }
        debugPrint("${tag}exception while downloading invoice $e");
      }
    }
  /*
  * Will return the directory path at which invoice will save.
  * it will not return the external directory path
  * ToDo: Need to check it to save it in external directory like Download
  * */
  Future<String> getFilePath(fileName) async {
    String path = '';
    // var pat_h = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
    // Directory dir = await getApplicationDocumentsDirectory();
    Directory? dir =  Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationDocumentsDirectory();
    path = '${dir?.path}/$fileName';
    return path;
  }


}