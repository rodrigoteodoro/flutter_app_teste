import 'dart:io';
import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/*
 * https://petercoding.com/flutter/2021/03/21/using-sqlite-in-flutter/
 * https://stackoverflow.com/questions/54223929/how-to-do-a-database-query-with-sqflite-in-flutter
 * https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/using_ffi_instead_of_sqflite.md
 * https://pub.dev/packages/sqflite_common_ffi
 *
 * flutter run -d windows --no-sound-null-safety
 *
 * Path padrão no RUN: C:\Users\rodri\OneDrive\Documentos
 * */
class DatabaseHelper {

  String _path = "";
  static final _databaseName = "produtos.db";

  Future<String> getPath() async{
    return _path;
  }

  Future<Database> initializeDB() async {

    sqfliteFfiInit();
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    _path = join(documentsDirectory.path, _databaseName);
    return openDatabase(
      _path,
      onCreate: _onCreate,
      version: 1,
    );
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    ''');
  }

  /**
   * https://www.bezkoder.com/dart-convert-list-map/
   */
  //Future<List<Map>> guiConsulta(String query) async {
  Future<List<Map>> guiConsulta(String query) async {
    log("guiConsulta");
    //List<Map> queryResult = [{}];
    final Database db = await initializeDB();
    List<Map> queryResult = await db.rawQuery(query);
    return queryResult;
  }

}