///
class CollectionEvent {
  final String widgetName;
  final String router;
  final bool isRemove;
  // token uid...
  CollectionEvent(this.widgetName, this.router, this.isRemove);
}

///Git OAuth认证事件
class UserGithubOAuthEvent {
  final String loginName;
  final String token;
  final bool isSuccess;
  UserGithubOAuthEvent(this.loginName, this.token, this.isSuccess);
}

///用户主体颜色设置事件
class UserSettingThemeColorEvent {
  ///主题颜色
  final int settingThemeColor;
  UserSettingThemeColorEvent(this.settingThemeColor);
}
