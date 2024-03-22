import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/constants/string_keys.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/app_alert_message.dart';
import 'package:uv_desk_flutter_open_source/mobikul-uvdesk/helper/application_localization.dart';

class DownloadHelper {
  var tag = "DownloadFile";

  // This method is called before the download starts and handles permissions.
  Future<bool> requestPermissions(BuildContext context) async {
  // Request storage permission
  var storageStatus = await Permission.storage.request();

  if (storageStatus.isGranted) {
    // If storage permission is granted, return true
    return true;
  } else {
    // If storage permission is denied
    if (storageStatus.isPermanentlyDenied) {
      // If the permission is permanently denied, show a dialog
      await showPermissionDialog(context, "Storage permission is required to download or upload files.");
    } else if (!storageStatus.isGranted && !storageStatus.isPermanentlyDenied) {
      // If the permission is not granted but not permanently denied, request the MANAGE_EXTERNAL_STORAGE permission
      var manageStorageStatus = await Permission.manageExternalStorage.request();

      if (manageStorageStatus.isGranted) {
        // If the MANAGE_EXTERNAL_STORAGE permission is granted, return true
        return true;
      } else {
        // If the MANAGE_EXTERNAL_STORAGE permission is denied
        if (manageStorageStatus.isPermanentlyDenied) {
          // If it's permanently denied, show a dialog
          await showPermissionDialog(context, "MANAGE_EXTERNAL_STORAGE permission is required to access the Downloads folder.");
        }
        // Since the permission is not granted, return false
        return false;
      }
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
          content: const Text("Please grant storage permission to download or upload files."),
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
    BuildContext? currentContext = context;
    try {
      debugPrint("DOWNLOAD_URL==> $url");
      // Request storage permission before downloading
      var status = await requestPermissions(context);
      if (status) {
        var dir = await getExternalStorageDirectory();
        if (dir != null) {
          String saveName = "${fileName.toString()}.$fileType";
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
            if (currentContext.mounted) {
              AlertMessage.showSuccess(
                ApplicationLocalizations.instance!
                    .translate(StringKeys.fileSavedOnDownloadFolder),
                currentContext,
              );
            }
            debugPrint("File is saved to the app-specific directory.");
          } on DioException catch (e) {
            debugPrint(e.message);
            if (currentContext.mounted) {
              AlertMessage.showError(
                ApplicationLocalizations.instance!
                    .translate(StringKeys.noPermissionToReadWriteStorage),
                currentContext,
              );
            }
          } catch (e) {
            if (currentContext.mounted) {
              AlertMessage.showError(
                ApplicationLocalizations.instance!
                    .translate(StringKeys.somethingWentWrong),
                currentContext,
              );
            }
            debugPrint("${tag}exception while downloading invoice $e");
          }
        } else {
          if (currentContext.mounted) {
            AlertMessage.showError(
              ApplicationLocalizations.instance!
                  .translate(StringKeys.noPermissionToReadWriteStorage),
              currentContext,
            );
          }
        }
      }
    } catch (e) {
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

  Future<String> getFilePath(String fileName) async {
    String path = '';
    Directory? dir = await getExternalStorageDirectory();
    if (dir != null) {
      path = "${dir.path}/$fileName";
    }
    return path;
  }
}