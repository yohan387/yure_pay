import 'package:flutter/material.dart';
import 'package:yure_payment_core/core/models.dart';

class Tip {
  final String merchantId;
  final int amount;

  Tip({required this.merchantId, required this.amount});
}

class TipRequest {
  final String providerName;
  final int amount;

  TipRequest({required this.providerName, required this.amount});
}

abstract class IYureTipsUi {
  void suggestTip({
    required BuildContext context,
    required PaymentResult result,
  });

  void showTips(BuildContext context);
}
