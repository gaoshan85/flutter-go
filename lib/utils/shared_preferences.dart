import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

export 'package:flutter_go/resources/shared_preferences_keys.dart';

///用来做shared_preferences的存储
class SpUtil {

  static SharedPreferences _spf;

  SpUtil._();

  static SpUtil _instance;

  static Future<SpUtil> get instance {
    return  getInstance();
  }

  Future _init() async {
    _spf = await SharedPreferences.getInstance();
  }

  ///获取SpUtile实例
  static Future<SpUtil> getInstance() async {
    if (_instance == null) {
      _instance =  SpUtil._();
    }
    if (_spf == null) {
      await _instance._init();
    }
    return _instance;
  }

  static bool _beforeCheck() {
    if (_spf == null) {
      return true;
    }
    return false;
  }

  /// 判断是否存在数据
  bool hasKey(String key) {
    Set keys = getKeys();
    return keys.contains(key);
  }
  ///
  Set<String> getKeys() {
    if (_beforeCheck()) return null;
    return _spf.getKeys();
  }
  ///
  get(String key) {
    if (_beforeCheck()) return null;
    return _spf.get(key);
  }
  ///
  getString(String key) {
    if (_beforeCheck()) return null;
    return _spf.getString(key);
  }
  ///
  Future<bool> putString(String key, String value) {
    if (_beforeCheck()) return null;
    return _spf.setString(key, value);
  }

  bool getBool(String key) {
    if (_beforeCheck()) return null;
    return _spf.getBool(key);
  }

  Future<bool> putBool(String key, bool value) {
    if (_beforeCheck()) return null;
    return _spf.setBool(key, value);
  }

  int getInt(String key) {
    if (_beforeCheck()) return null;
    return _spf.getInt(key);
  }

  Future<bool> putInt(String key, int value) {
    if (_beforeCheck()) return null;
    return _spf.setInt(key, value);
  }
  ///
  double getDouble(String key) {
    if (_beforeCheck()) return null;
    return _spf.getDouble(key);
  }
  ///保存double数据
  Future<bool> putDouble(String key, double value) {
    if (_beforeCheck()) return null;
    return _spf.setDouble(key, value);
  }
  ///获取List<String>列表数据
  List<String> getStringList(String key) {
    return _spf.getStringList(key);
  }
  ///保存List<String>列表数据
  Future<bool> putStringList(String key, List<String> value) {
    if (_beforeCheck()) return null;
    return _spf.setStringList(key, value);
  }
  ///
  dynamic getDynamic(String key) {
    if (_beforeCheck()) return null;
    return _spf.get(key);
  }
  ///
  Future<bool> remove(String key) {
    if (_beforeCheck()) return null;
    return _spf.remove(key);
  }
  ///
  Future<bool> clear() {
    if (_beforeCheck()) return null;
    return _spf.clear();
  }
}
