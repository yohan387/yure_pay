// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/interfaces.dart';

class MockProvider implements IPaymentProvider {
  static final List<_MockPaymentRequest> _requests = [];
  static const int _kMaxPaymentAmount = 100000;

  @override
  String get name => 'MOCK';

  @override
  bool canHandle(PaymentRequest request) {
    return request.selectedProviderName == name;
  }

  @override
  Future<PaymentResult> processPayment(
    PaymentRequest request,
    int transactionId,
  ) async {
    // Simulation délai de traitement
    await Future.delayed(const Duration(seconds: 14));

    final int newPaymentId = _requests.length + 1; // index comme ID
    final bool isValidPaymentAmount = request.amount <= _kMaxPaymentAmount;

    final PaymentStatus paymentStatus = isValidPaymentAmount
        ? PaymentStatus.inProgress
        : PaymentStatus.failed;

    final newRequest = _MockPaymentRequest(
      id: newPaymentId,
      transactionId: transactionId,
      amount: request.amount,
      status: paymentStatus,
    );

    _requests.add(newRequest);

    final messageResult = isValidPaymentAmount
        ? "Paiement MOCK accepté et en cours."
        : "Paiement MOCK refusé (montant trop élevé).";

    return PaymentResult(
      id: transactionId, // ⚠️ utiliser l’ID global de la transaction
      message: messageResult,
      status: paymentStatus,
    );
  }

  @override
  Future<bool> cancelPayment(int transactionId) async {
    final request = _requests.firstWhere(
      (r) => r.transactionId == transactionId,
      orElse: () => throw Exception("Transaction MOCK introuvable"),
    );

    if (request.status == PaymentStatus.inProgress) {
      final canceledRequest = request.copyWith(status: PaymentStatus.canceled);
      final int requestIndex = _requests.indexOf(request);
      _requests[requestIndex] = canceledRequest;
      return true;
    }

    return false;
  }
}

/// Représentation interne d'une requête MOCK
class _MockPaymentRequest {
  final int id;
  final int transactionId;
  final int amount;
  final PaymentStatus status;

  _MockPaymentRequest({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.status,
  });

  _MockPaymentRequest copyWith({PaymentStatus? status}) {
    return _MockPaymentRequest(
      id: id,
      transactionId: transactionId,
      amount: amount,
      status: status ?? this.status,
    );
  }
}
