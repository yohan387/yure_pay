import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/interfaces.dart';
import 'package:yure_payment_core/src/service.dart';

class YurePaymentRepo {
  final List<IPaymentProvider> _providers;
  final IYurePayBackendService _backend;

  YurePaymentRepo(this._providers, this._backend);

  IPaymentProvider _getProvider(PaymentRequest request) {
    return _providers.firstWhere(
      (p) => p.canHandle(request),
      orElse: () => throw Exception("Provider non trouvé"),
    );
  }

  Future<List<ProviderInfo>> getAvailableProviders() async {
    return _providers
        .map((p) => ProviderInfo(id: p.name, name: p.name))
        .toList();
  }

  Future<PaymentResult> processPayment(PaymentRequest request) async {
    final transactionID = await _backend.createTransaction(request);
    final provider = _getProvider(request);

    provider
        .processPayment(request, transactionID)
        .then((result) => _backend.updateTransaction(result));

    return PaymentResult(
      id: transactionID,
      message: "Transaction créée.",
      status: PaymentStatus.inProgress,
    );
  }

  Future<bool> cancelPayment(int transactionId) async {
    final request = await _backend.getPaymentInfos(transactionId);
    final provider = _getProvider(request);
    return provider.cancelPayment(transactionId);
  }

  Stream<PaymentStatus> getPaymentStatus(int transactionId) async* {
    while (true) {
      final status = await _backend.getPaymentStatus(transactionId);
      yield status;
      if (status == PaymentStatus.succeeded ||
          status == PaymentStatus.failed ||
          status == PaymentStatus.canceled) {
        break; // on arrête le stream quand la transaction est terminée ou annulée
      }
      await Future.delayed(const Duration(seconds: 2)); // polling backend
    }
  }
}
