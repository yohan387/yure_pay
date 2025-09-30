import 'package:yure_tips/core/models/tip.dart';

abstract interface class IYureTipsController {
  Future<void> addTip();
  Future<List<Tip>> listTips();
}

class YureTipsController implements IYureTipsController {
  Future<void> addTip() async {}
  Future<List<Tip>> listTips() async {
    return [];
  }
}
