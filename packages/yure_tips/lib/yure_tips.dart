import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/yure_payment_core.dart';
import 'package:yure_tips/core/models/tip.dart';
import 'package:yure_tips/src/service.dart';
import 'package:yure_tips/src/views/tip_form.dart';
import 'package:yure_tips/src/views/tips_list.dart';

import 'package:yure_tips/src/repository.dart';

const String _kBoxName = 'tipsBox';

/// Singleton pour gérer les tips et/ou leur UI
class YureTips implements IYureTipsUi {
  static YureTips? _instance;
  late final Box<TipHiveModel> _box;
  late final LocalTipsRepo _repo;

  /// Interface UI des tips (widgets, affichage, animations, etc.)

  // Constructeur privé pour empêcher l'instanciation directe
  YureTips._();

  /// Initialisation asynchrone obligatoire avant toute utilisation
  ///
  /// Configure Hive, ouvre la box locale et initialise les services et UI.
  static Future<IYureTipsUi> init() async {
    if (_instance != null) return _instance!;

    final instance = YureTips._();

    final dir = await getApplicationCacheDirectory();
    Hive.init(dir.path);

    Hive.registerAdapter(TipHiveModelAdapter());

    instance._box = await Hive.openBox<TipHiveModel>(_kBoxName);

    final localStorage = HiveTipsStorageService(instance._box);
    final yureSdk = YurePayment.instance;

    instance._repo = LocalTipsRepo(localStorage, yureSdk);
    instance._repo.setPaymentConfig(yureSdk.config); // ← Configuration correcte

    _instance = instance;
    return instance;
  }

  /// Accès synchronisé à l'instance singleton après initialisation
  ///
  /// Appeler [init] avant d'utiliser ce getter, sinon exception.
  static IYureTipsUi get instance {
    if (_instance == null) {
      throw Exception("YureTips not initialized. Call YureTips.init() first.");
    }
    return _instance!;
  }

  @override
  void showTips(BuildContext context) async {
    final tips = await _repo.listTips();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return TipsListBottomSheet(tips: tips);
      },
    );
  }

  @override
  Future<int> suggestTip({
    required BuildContext context,
    required PaymentResult result,
  }) async {
    if (!context.mounted) return 0;

    final Completer<int> completer = Completer<int>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);

            if (!completer.isCompleted) {
              completer.complete(0);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: TipForm(
            totalAmount: result.request!.amount,
            merchantId: _repo.config!.merchantId,
            merchantName: _repo.config!.merchantName,
            onTipAdded: (tipAmount) {
              _repo.addTip(
                TipRequest(
                  providerName: result.request!.providerName,
                  amount: tipAmount,
                ),
              );
              Navigator.pop(context);

              if (!completer.isCompleted) {
                completer.complete(tipAmount);
              }
            },
            onCancelled: () {
              Navigator.pop(context);

              if (!completer.isCompleted) {
                completer.complete(0);
              }
            },
          ),
        );
      },
    );

    return completer.future;
  }
}
