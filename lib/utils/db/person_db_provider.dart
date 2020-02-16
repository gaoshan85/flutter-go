import 'package:flutter_go/model/user_info.dart';
import 'package:flutter_go/utils/db/base_db_provider.dart';
import 'package:sqflite/sqlite_api.dart';
///
class PersonDbProvider extends BaseDbProvider{
///表名
final String name = 'PresonInfo';

final String columnId="id";
final String columnMobile="username";
final String columnHeadImage="avatarPic";


PersonDbProvider();

@override
tableName() {
  return name;
}

@override
createTableString() {
  return '''
        create table $name (
        $columnId integer primary key,$columnHeadImage text not null,
        $columnMobile text not null)
      ''';
}

///查询数据库
Future _getPersonProvider(Database db, int id) async {
  List<Map<String, dynamic>> maps =
  await db.rawQuery("select * from $name where $columnId = $id");
  return maps;
}

///插入到数据库
Future insert(UserInformation model) async {
  Database db = await getDataBase();
  var userProvider = await _getPersonProvider(db, model.id);
  if (userProvider != null) {
    ///删除数据
    await db.delete(name, where: "$columnId = ?", whereArgs: [model.id]);
  }
  return await db.rawInsert("insert into $name ($columnId,$columnMobile,$columnHeadImage) values (?,?,?)",[model.id,model.username,model.avatarPic]);
}

///更新数据库
Future<void> update(UserInformation model) async {
  Database database = await getDataBase();
  await database.rawUpdate(
      "update $name set $columnMobile = ?,$columnHeadImage = ? where $columnId= ?",[model.username,model.avatarPic,model.id]);

}


///获取事件数据
Future<UserInformation> getPersonInfo(int id) async {
  Database db = await getDataBase();
  List<Map<String, dynamic>> maps  = await _getPersonProvider(db, id);
  if (maps.isNotEmpty) {
    return UserInformation.fromJson(maps[0]);
  }
  return null;
}
}