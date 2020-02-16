import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

//const createSql = {
//  'cat': """
//      CREATE TABLE "cat" (
//      `id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
//      `name`	TEXT NOT NULL UNIQUE,
//      `depth`	INTEGER NOT NULL DEFAULT 1,
//      `parentId`	INTEGER NOT NULL,
//      `desc`	TEXT
//    );
//  """,
//  'collectio': """
//    CREATE TABLE collection (id INTEGER PRIMARY KEY NOT NULL UNIQUE, name TEXT NOT NULL, router TEXT);
//  """,
//  'widget': """
//    CREATE TABLE widget (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, name TEXT NOT NULL, cnName TEXT NOT NULL, image TEXT NOT NULL, doc TEXT, demo TEXT, catId INTEGER NOT NULL REFERENCES cat (id), owner TEXT);
//  """;
//};

///数据库支持类
class Provider {
  ///数据库实例
  static Database db;

  /// 获取数据库中所有的表
  Future<List> getTables() async {
    if (db == null) {
      return Future.value([]);
    }
    List tables = await db
        .rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    List<String> targetList = [];
    ///forEach()函数在JavaScript中得到了广泛使用，因为内置for-in循环无法实现您通常想要的功能。在Dart中，如果要遍历序列，惯用的方法是使用循环。
    ///Map.forEach()始终可以。
    for(var item in tables){
      targetList.add(item['name']);
    }
//    tables.forEach((item) {
//      targetList.add(item['name']);
//    });
    return targetList;
  }

  ///检查数据库中表是否完整, 在部份android中, 会出现表丢失的情况.
  Future<bool> checkTableIsRight() async {
    List<String> expectTables = ['cat', 'widget', 'collection'];
    List<String> tables = await getTables();
    for (int i = 0; i < expectTables.length; i++) {
      if (!tables.contains(expectTables[i])) {
        return false;
      }
    }
    return true;
  }

  ///初始化数据库，并检查数据库完整性。
  Future init(bool isCreate) async {
    //获取数据库存储位置，默认data/data/<package_name>/databases
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'flutter.db');
    print("数据库路径：$path");
    try {
      db = await openDatabase(path);
    } catch (e) {
      print("db Error $e");
    }
    ///判断当前数据库是否完整，否则重新加载。
    bool tableIsRight = await checkTableIsRight();
    if (!tableIsRight) {
      // 关闭上面打开的db，否则无法执行open
      db.close();
      // Delete the database
      await deleteDatabase(path);
      ///加载指定数据库
      ByteData data = await rootBundle.load(join("assets", "app.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      ///打开数据库
      db = await openDatabase(
          path,
          version: 1,
          onConfigure: (Database db) async {
            ///执行数据库初始化，例如启用外键或提前写日志
          },
          ///如果指定了[version]，下面方法才有效。
          onCreate: (Database db, int version) async {
            ///如果之前数据库不存在，将回调此方法创建数据库。
              print('db created version is $version');
          },
          onUpgrade:(Database db, int oldVersion, int newVersion){
            ///如果指定的数据库存在，但版本高于当前版本回调此函数。
          },
          onDowngrade: (Database db, int oldVersion, int newVersion) async {
            ///只有当[version]低于上一个数据库时才调用[onDowngrade]
          },
          onOpen: (Database db) async {
            ///数据库版本已经设置，并且在[openDatabase]返回之前
          });
    } else {
      print("Opening existing database");
    }
  }
}
