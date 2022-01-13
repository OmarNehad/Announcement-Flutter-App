import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:ext_storage/ext_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (_) {
      return null;
    }
  }

  static Future downloadFile(Reference ref) async {
    var dir = await getExternalStorageDirectory();

    final file = File('${dir!.path}/${ref.name}');

    await ref.writeToFile(file);
  }
}
