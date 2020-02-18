import 'elements/index.dart' as elements;
import 'components/index.dart' as components;
import 'themes/index.dart' as themes;

///组件Demo列表
class WidgetDemoList {
  ///
  WidgetDemoList();

  List getDemos() {
    List result = [];
    result.addAll(elements.getWidgets());
    result.addAll(components.getWidgets());
    result.addAll(themes.getWidgets());
    return result;
  }
}
