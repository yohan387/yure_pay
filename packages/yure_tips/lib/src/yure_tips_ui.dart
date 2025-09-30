import 'package:flutter/material.dart';
import 'package:yure_tips/core/models/tip.dart';
import 'package:yure_tips/src/repository.dart';

abstract class IBaseYureTips {
  Future<void> addTip(Tip tip);
  Future<List<Tip>> listTips();
}

class BaseYureTips implements IBaseYureTips {
  final ITipsRepo _tipsRepo;

  const BaseYureTips(this._tipsRepo);

  @override
  Future<void> addTip(Tip tip) async {
    return _tipsRepo.addTip(tip);
  }

  @override
  Future<List<Tip>> listTips() async {
    return _tipsRepo.listTips();
  }
}

abstract class IYureTipsUi {
  void addTipForms(BuildContext context);

  ///fdfsssssssssssss
  void showTips(BuildContext context);
}

class YureTipsUI implements IYureTipsUi {
  final IBaseYureTips _yureTips;

  YureTipsUI(this._yureTips);

  @override
  void addTipForms(BuildContext context) async {
    final tips = await _yureTips.listTips();

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...tips.map((t) => ListTile(title: Text("Tip: ${t.amount}"))),
            ElevatedButton(
              onPressed: () async {
                await _yureTips.addTip(
                  Tip(merchantId: "merchantId", amount: 1000),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Ajouter un pourboire"),
            ),
          ],
        );
      },
    );
  }

  @override
  void showTips(BuildContext context) async {
    final tips = await _yureTips.listTips();

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...tips.map((t) => ListTile(title: Text("Tip: ${t.amount}"))),
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Ajouter un pourboire"),
            ),
          ],
        );
      },
    );
  }
}
