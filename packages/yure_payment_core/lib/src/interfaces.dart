import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

abstract class IYurePaymentSdk {
  Future<void> init(PaymentConfig config);

  Future<List<ProviderInfo>> getAvailableProviders();

  Future<PaymentResult> processPayment(PaymentRequest request);

  Future<bool> cancelPayment(int transactionId);

  Stream<PaymentStatus> getPaymentStatus(int transactionId);
}

abstract class IPaymentProvider {
  String get name;

  bool canHandle(PaymentRequest request);

  Future<PaymentResult> processPayment(
    PaymentRequest request,
    int transactionId,
  );

  Future<bool> cancelPayment(int transactionId);
}
