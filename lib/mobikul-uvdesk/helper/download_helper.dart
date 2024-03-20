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
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class DownloadHelper {
  var tag = "DownloadFile";
  String savePath = "";

  // This method is called before the download starts and handles permissions.
  Future<bool> requestPermissions(BuildContext context) async {
    var storageStatus = await Permission.storage.request();

    if (storageStatus.isGranted) {
      return true;
    } else {
      if (storageStatus.isPermanentlyDenied) {
        await showPermissionDialog(context, "Storage permission is required to download or upload files.");
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
    try {
      // Request storage permission before downloading
      var status = await Permission.storage.request();
      if (status.isGranted) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File saved to downloads folder.'),
              ),
            );
          } on DioException catch (e) {
            debugPrint(e.message);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to download file.'),
              ),
            );
          }
        }
      } else {
        // Handle the case where permission is denied or permanently denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied to access storage.'),
          ),
        );
      }
    } catch (e) {
      debugPrint("Exception while downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong.'),
        ),
      );
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