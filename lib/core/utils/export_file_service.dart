import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ExportFileService {
  Future<File> saveCollectionJson({
    required int idColeta,
    required String jsonContent,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory(
      path.join(directory.path, 'controle', 'coletas_exportadas'),
    );

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final fileName = 'coleta_${idColeta}_${_buildTimestamp()}.json';
    final file = File(path.join(exportDir.path, fileName));
    await file.writeAsString(jsonContent);
    return file;
  }

  String _buildTimestamp() {
    final now = DateTime.now();
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${now.year}${twoDigits(now.month)}${twoDigits(now.day)}_${twoDigits(now.hour)}${twoDigits(now.minute)}${twoDigits(now.second)}';
  }
}
