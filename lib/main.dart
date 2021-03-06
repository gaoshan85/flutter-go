import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/rendering.dart';
import 'routers/application.dart';
import 'routers/routers.dart';
import 'routers/application.dart' show Application;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_go/utils/provider.dart';
import 'package:flutter_go/utils/shared_preferences.dart';
import 'package:flutter_go/views/home.dart';
import 'package:flutter_go/model/search_history.dart';
import 'package:flutter_go/utils/analytics.dart' as Analytics;
import 'package:flutter_go/views/login_page/login_page.dart';
import 'package:flutter_go/utils/data_utils.dart';
import 'package:flutter_go/model/user_info.dart';
import 'package:flutter_jpush/flutter_jpush.dart';
import 'package:flutter_go/event/event_bus.dart';
import 'package:flutter_go/event/event_model.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_go/model/widget.dart';
import 'package:flutter_go/standard_pages/index.dart';

//import 'views/welcome_page/index.dart';
import 'package:flutter_go/utils/net_utils.dart';

SpUtil sp;
var db;

class MyApp extends StatefulWidget {
  MyApp() {
    final router = new Router();
    Routes.configureRoutes(router);
    // 这里设置项目环境
    Application.router = router;
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasLogin = false;
  bool _isLoading = true;
  UserInformation _userInfo;
  bool isConnected = false;
  String registrationId;
  List notificationList = [];
  int themeColor = 0xFFC91B3A;

  _MyAppState() {
    final eventBus = new EventBus();
    ApplicationEvent.event = eventBus;
  }

  /// 服务端控制是否显示业界动态
  Future _reqsMainPageIsOpen() async {
    const reqs = 'https://flutter-go.pub/api/isInfoOpen';
    var response;
    try {
      response = await NetUtils.get(reqs, {});
      print('response-$response');
      if (response['status'] == 200 &&
          response['success'] == true &&
          response['data'] is Map &&
          response['data']['isOpen'] == true) {
        Application.pageIsOpen = true;
        print('是否需要展开【业界动态】${Application.pageIsOpen}');
      }
    } catch (e) {
      print('response-$e');
    }
    return response;
  }

  @override
  void initState() {
    super.initState();
    _reqsMainPageIsOpen();
    _startupJpush();

    FlutterJPush.addConnectionChangeListener((bool connected) {
      setState(() {
        /// 是否连接，连接了才可以推送
        print("连接状态改变:$connected");
        this.isConnected = connected;
        if (connected) {
          //在启动的时候会去连接自己的服务器，连接并注册成功之后会返回一个唯一的设备号
          try {
            FlutterJPush.getRegistrationID().then((String regId) {
              print("主动获取设备号:$regId");
              setState(() {
                this.registrationId = regId;
              });
            });
          } catch (error) {
            print('主动获取设备号Error:$error');
          }
        }
      });
    });

    FlutterJPush.addReceiveNotificationListener(
        (JPushNotification notification) {
      setState(() {
        /// 收到推送
        print("收到推送提醒: $notification");
        notificationList.add(notification);
      });
    });

    FlutterJPush.addReceiveOpenNotificationListener(
        (JPushNotification notification) {
      setState(() {
        print("打开了推送提醒: $notification");

        /// 打开了推送提醒
        notificationList.add(notification);
      });
    });

    FlutterJPush.addReceiveCustomMsgListener((JPushMessage msg) {
      setState(() {
        print("收到推送消息提醒: $msg");

        /// 打开了推送提醒
        notificationList.add(msg);
      });
    });

    DataUtils.checkLogin().then((hasLogin) {
      if (hasLogin.runtimeType == UserInformation) {
        setState(() {
          _hasLogin = true;
          _isLoading = false;
          _userInfo = hasLogin;
          // 设置初始化的主题色
          // if (hasLogin.themeColor != 'default') {
          //   themeColor = int.parse(hasLogin.themeColor);
          // }
        });
      } else {
        setState(() {
          _hasLogin = hasLogin;
          _isLoading = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        _hasLogin = false;
        _isLoading = false;
      });
      print('身份信息验证失败:$onError');
    });

    ApplicationEvent.event.on<UserSettingThemeColorEvent>().listen((event) {
      print('接收到的 event $event');
    });
  }

  showWelcomePage() {
    if (_isLoading) {
      return Container(
        color: Color(this.themeColor),
        child: Center(
          child: SpinKitPouringHourglass(color: Colors.white),
        ),
      );
    } else {
      // 判断是否已经登录
      if (_hasLogin) {
        return AppPage(_userInfo);
      } else {
        return LoginPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
//    WidgetTree.getCommonItemByPath([15, 17], Application.widgetTree);
    return MaterialApp(
      title: 'titles',//标题
      theme: ThemeData( //主题
        primaryColor: Color(themeColor),
        backgroundColor: Color(0xFFEFEFEF),
        accentColor: Color(0xFF888888),
        textTheme: TextTheme(
          //设置Material的默认字体样式
          body1: TextStyle(color: Color(0xFF888888), fontSize: 16.0),
        ),
        iconTheme: IconThemeData(
          color: Color(themeColor),
          size: 35.0,
        ),
      ),
      home: Scaffold(body: showWelcomePage()),//进入程序后显示的第一个页面,传入的是一个Widget，但实际上这个Widget需要包裹一个Scaffold以显示该程序使用Material Design风
//     routes: {
//        '/home':(BuildContext context) => HomePage(),
//        '/home/one':(BuildContext context) => OnePage(),
//      },
//     initialRoute:'/home/one'//初始路由，当用户进入程序时，自动打开对应的路由。
      debugShowCheckedModeBanner: false,//调试显示检查模式横幅
      onGenerateRoute: Application.router.generator,//当通过Navigation.of(context).pushNamed跳转路由时，在routes查找不到时，会调用该方法.
      //onUnknownRoute:RouteFactory //未知路由
      navigatorObservers: <NavigatorObserver>[Analytics.observer],//路由观察器，当调用Navigator的相关方法时，会回调相关的操作
    );
  }
}

void _startupJpush() async {
  print("初始化jpush");
  await FlutterJPush.startup();
  print("初始化jpush成功");
}

///入口程序
 main() async {
  //在runApp()之前如果访问二进制文件或者初始化插件，需要先调用.
  WidgetsFlutterBinding.ensureInitialized();
  final provider = Provider();
  await provider.init(true);
  db = Provider.db;
  sp = await SpUtil.getInstance();
  SearchHistoryList(sp);

  await DataUtils.getWidgetTreeList().then((List json) {
    List data =
        WidgetTree.insertDevPagesToList(json, StandardPages().getLocalList());
    Application.widgetTree = WidgetTree.buildWidgetTree(data);
    print("Application.widgetTree>>>> ${Application.widgetTree}");
  });

  runApp(MyApp());
}
