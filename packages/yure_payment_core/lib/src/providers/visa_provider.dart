import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/common/interfaces.dart';

class VisaProvider implements IPaymentProvider {
  @override
  bool canHandle(PaymentRequest request) {
    return false;
  }

  @override
  Future<bool> cancelPayment(int transactionId) async {
    return false;
  }

  @override
  String get name => "Visa";

  @override
  String get logo => '💳';

  @override
  Future<PaymentResult> processPayment({
    required String merchantId,
    required int transactionId,
    required int amount,
  }) {
    //implement processPayment
    throw UnimplementedError();
  }
}
