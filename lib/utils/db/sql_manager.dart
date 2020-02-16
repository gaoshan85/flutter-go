import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///数据库管理类
class SqlManager {
  static const _VERSION = 1;

  static const _NAME = "qss.db";

  static Database _database;

  ///初始化数据库
  static initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _NAME);
    await openDatabase(path, version: _VERSION,
        onConfigure: (Database db) async {
      ///执行数据库初始化，例如启用外键或提前写日志
    }, onCreate: (Database db, int version) async {
      ///如果之前数据库不存在，将回调此方法创建数据库。
      print('db created version is $version');
    }, onUpgrade: (Database db, int oldVersion, int newVersion) {
      ///如果指定的数据库存在，但版本高于当前版本回调此函数。
    }, onDowngrade: (Database db, int oldVersion, int newVersion) async {
      ///只有当[version]低于上一个数据库时才调用[onDowngrade]
    }, onOpen: (Database db) async {
      ///数据库版本已经设置，并且在[openDatabase]返回之前
    });
  }

  ///判断表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.isNotEmpty;
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await initDb();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
