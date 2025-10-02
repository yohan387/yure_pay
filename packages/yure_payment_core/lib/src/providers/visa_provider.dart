import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/interfaces.dart';

class VisaProvider implements IPaymentProvider {
  @override
  bool canHandle(PaymentRequest request) {
    // TODO: implement canHandle
    throw UnimplementedError();
  }

  @override
  Future<bool> cancelPayment(int transactionId) {
    // TODO: implement cancelPayment
    throw UnimplementedError();
  }

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  Future<PaymentResult> processPayment(
    PaymentRequest request,
    int transactionId,
  ) {
    // TODO: implement processPayment
    throw UnimplementedError();
  }
}
