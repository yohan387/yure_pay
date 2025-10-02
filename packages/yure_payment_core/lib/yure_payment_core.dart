import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/interfaces.dart';
import 'package:yure_payment_core/src/providers/mock_provider.dart';
import 'package:yure_payment_core/src/repository.dart';
import 'package:yure_payment_core/src/providers/visa_provider.dart';
import 'package:yure_payment_core/src/service.dart';

class YurePayment implements IYurePaymentSdk {
  late final YurePaymentRepo _repo;

  @override
  Future<void> init(PaymentConfig config) async {
    // Initialisation des providers et du backend
    final providers = [MockProvider(), VisaProvider()];
    final backend = YurePayBackendService(); // implémentation concrète

    _repo = YurePaymentRepo(providers, backend);
  }

  @override
  Future<List<ProviderInfo>> getAvailableProviders() {
    return _repo.getAvailableProviders();
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) {
    return _repo.processPayment(request);
  }

  @override
  Future<bool> cancelPayment(int transactionId) {
    return _repo.cancelPayment(transactionId);
  }

  @override
  Stream<PaymentStatus> getPaymentStatus(int transactionId) {
    return _repo.getPaymentStatus(transactionId);
  }
}
