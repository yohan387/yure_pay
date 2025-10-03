import 'dart:developer';

import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/core/exceptions.dart';
import 'package:yure_payment_core/src/common/interfaces.dart';
import 'package:yure_payment_core/src/common/errors/error_handler.dart';

/// Provider de test pour les développements et les tests
///
/// Simule le comportement d'un vrai provider avec délais
/// et scénarios de succès/échec configurables.
class MockProvider with ErrorHandlerMixin implements IPaymentProvider {
  static final List<MockPaymentRequest> _requests = [];
  static const int _kMaxPaymentAmount = 1000000;

  @override
  String get name => 'MOCK';

  @override
  String get logo => '🧪';

  @override
  bool canHandle(PaymentRequest request) {
    return executeSyncWithErrorHandler(
      () => request.providerName == name,
      errorMapper: (e) => ConfigurationException(
        'Erreur de configuration lors de la vérification du provider: ${e.toString()}',
      ),
    );
  }

  @override
  Future<PaymentResult> processPayment({
    required String merchantId,
    required int transactionId,
    required int amount,
  }) async {
    return executeWithErrorHandler(
      () async => _processPaymentInternal(
        merchantId: merchantId,
        transactionId: transactionId,
        amount: amount,
      ),
      errorMapper: (e) => PaymentProcessingException(
        name,
        'Erreur lors du traitement mock: ${e.toString()}',
      ),
    );
  }

  @override
  Future<bool> cancelPayment(int transactionId) async {
    return executeWithErrorHandler(
      () async => _cancelPaymentInternal(transactionId),
      errorMapper: (e) => CancelPaymentException(
        transactionId,
        'Erreur lors de l\'annulation mock: ${e.toString()}',
      ),
    );
  }

  Future<PaymentResult> _processPaymentInternal({
    required String merchantId,
    required int transactionId,
    required int amount,
  }) async {
    _validatePaymentParameters(merchantId, transactionId, amount);

    final int newPaymentId = _requests.length + 1;

    final bool isValidPaymentAmount = amount <= _kMaxPaymentAmount;

    final PaymentStatus initialStatus = isValidPaymentAmount
        ? PaymentStatus.inProgress
        : PaymentStatus.failed;

    final newRequest = MockPaymentRequest(
      id: newPaymentId,
      merchantId: merchantId,
      transactionId: transactionId,
      amount: amount,
      status: initialStatus,
    );

    _requests.add(newRequest);

    if (!isValidPaymentAmount) {
      final messageResult = "Paiement MOCK refusé (montant trop élevé).";

      return PaymentResult(
        transactionId: transactionId,
        message: messageResult,
        status: PaymentStatus.failed,
      );
    }

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(seconds: 1));

      final currentRequest = _requests.firstWhere(
        (r) => r.transactionId == transactionId,
        orElse: () => newRequest,
      );

      if (currentRequest.status == PaymentStatus.canceled) {
        log('🟡 [MOCK] Transaction annulée pendant le traitement');
        return PaymentResult(
          transactionId: transactionId,
          message: "Paiement annulé par l'utilisateur",
          status: PaymentStatus.canceled,
        );
      }

      log('⏰ [MOCK] Traitement en cours... ${i + 1}/8 secondes');
    }

    final finalRequest = _requests.firstWhere(
      (r) => r.transactionId == transactionId,
      orElse: () => newRequest,
    );

    PaymentStatus finalStatus;
    String messageResult;

    if (finalRequest.status == PaymentStatus.canceled) {
      finalStatus = PaymentStatus.canceled;
      messageResult = "Paiement annulé par l'utilisateur";
    } else {
      finalStatus = PaymentStatus.succeeded;
      messageResult = "Paiement MOCK validé";

      final index = _requests.indexWhere(
        (rq) => rq.transactionId == transactionId,
      );
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(status: finalStatus);
      }
    }

    return PaymentResult(
      transactionId: transactionId,
      message: messageResult,
      status: finalStatus,
    );
  }

  void _validatePaymentParameters(
    String merchantId,
    int transactionId,
    int amount,
  ) {
    if (merchantId.isEmpty) {
      throw const PaymentProcessingException('MOCK', 'Merchant ID est requis');
    }

    if (transactionId <= 0) {
      throw const PaymentProcessingException('MOCK', 'Transaction ID invalide');
    }

    if (amount <= 0) {
      throw InvalidAmountException(
        amount,
        reason: 'Le montant doit être positif',
      );
    }
  }

  Future<bool> _cancelPaymentInternal(int transactionId) async {
    final requestIndex = _requests.indexWhere(
      (r) => r.transactionId == transactionId,
    );

    if (requestIndex == -1) {
      throw TransactionNotFoundException(transactionId);
    }

    final request = _requests[requestIndex];

    if (request.status == PaymentStatus.inProgress) {
      _requests[requestIndex] = request.copyWith(
        status: PaymentStatus.canceled,
      );

      return true;
    }

    return false;
  }

  static void reset() {
    _requests.clear();
  }

  static List<MockPaymentRequest> get requestHistory =>
      List.unmodifiable(_requests);
}

/// Représentation interne d'une requête MOCK
class MockPaymentRequest {
  final int id;
  final String merchantId;
  final int transactionId;
  final int amount;
  final PaymentStatus status;

  const MockPaymentRequest({
    required this.id,
    required this.merchantId,
    required this.transactionId,
    required this.amount,
    required this.status,
  });

  MockPaymentRequest copyWith({PaymentStatus? status}) {
    return MockPaymentRequest(
      id: id,
      merchantId: merchantId,
      transactionId: transactionId,
      amount: amount,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'MockPaymentRequest{id: $id, transactionId: $transactionId, amount: $amount, status: $status}';
  }
}

class MocPaymentRequest extends PaymentRequest {
  final String merchantId;
  final int transactionId;

  MocPaymentRequest({
    required super.providerName,
    required super.amount,
    required this.merchantId,
    required this.transactionId,
  });
}
