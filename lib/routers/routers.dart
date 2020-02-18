
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_go/utils/analytics.dart' show analytics;
import '../widgets/index.dart';
import './router_handler.dart';

///路由表，定义功能层面的路由页面
class Routes {
  ///根目录
  static final String root = "/";
  ///Home页
  static final String home = "/home";
  static final String widgetDemo = '/widget-demo';
  static final String codeView = '/code-view';
  static final String githubCodeView = '/github-code-view';
  static final String webViewPage = '/web-view-page';
  static final String loginPage = '/loginpage';
  static final String issuesMessage = '/issuesMessage';
  static final String collectionPage = '/collection-page';
  static final String collectionFullPage = '/collection-full-page';
  static final String standardPage = '/standard-page/:id';

  ///配置路由列表
  static void configureRoutes(Router router) {
//    router.notFoundHandler = new Handler(
//      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//      }
//    );
    ///
    router.define(home, handler: homeHandler);
    router.define(collectionPage, handler: collectionHandler);
    router.define(collectionFullPage, handler: collectionFullHandler);
    router.define('/category/:ids', handler: categoryHandler);
    router.define('/category/error/404', handler: widgetNotFoundHandler);
    router.define(loginPage, handler: loginPageHandler);
    router.define(codeView, handler: fullScreenCodeDialog);
    router.define(githubCodeView, handler: githubCodeDialog);
    router.define(webViewPage, handler: webViewPageHand);
    router.define(issuesMessage, handler: issuesMessageHandler);
    router.define(standardPage, handler: standardPageHandler);
    ///建议使用forEach()直接使用for（var in ..）格式;
    List widgetDemosList = WidgetDemoList().getDemos();
    for(var demo in widgetDemosList){
      Handler handler = Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        print('组件路由params=$params widgetsItem=${demo.routerName}');
        analytics
            .logEvent(name: 'component', parameters: {'name': demo.routerName});
        return demo.buildRouter(context);
      });
      String path = demo.routerName;
      router.define('${path.toLowerCase()}', handler: handler);
    }
//    router.define(webViewPage,handler:webViewPageHand);
//    standardPages.forEach((String id, String md) => {
//
//    });
  }
}
