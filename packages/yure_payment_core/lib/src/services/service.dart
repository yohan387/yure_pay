import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/core/exceptions.dart';
import 'package:yure_payment_core/src/common/errors/error_handler.dart';
import 'package:yure_payment_core/src/common/models.dart';
import 'package:yure_payment_core/src/services/interface.dart';

/// Implémentation mock du service backend pour les tests et développement
///
/// Simule un backend réel avec stockage en mémoire et délais artificiels
/// pour tester les flux de paiement sans dépendance externe.
class YurePayBackendService
    with ErrorHandlerMixin
    implements IYurePayBackendService {
  static final List<Transaction> _transactions = [];
  static int _nextTransactionId = 1;

  @override
  Future<int> createTransaction(PaymentRequest request) async {
    return executeWithErrorHandler(
      () async => _createTransactionInternal(request),
      errorMapper: (e) => TransactionCreationException(e.toString()),
    );
  }

  Future<int> _createTransactionInternal(PaymentRequest request) async {
    _validatePaymentRequest(request);

    await Future.delayed(const Duration(milliseconds: 100));

    final int newTransactionId = _nextTransactionId++;

    final bool isPairAmount = request.amount.isEven;
    final PaymentStatus initialStatus = isPairAmount
        ? PaymentStatus.inProgress
        : PaymentStatus.failed;

    final transaction = Transaction(
      id: newTransactionId,
      paymentRequest: request,
      status: initialStatus,
    );

    _transactions.add(transaction);

    return newTransactionId;
  }

  @override
  Future<void> updateTransaction(PaymentResult paymentResult) async {
    return executeWithErrorHandler(
      () async => _updateTransactionInternal(paymentResult),
      errorMapper: (e) => TransactionUpdateException(
        paymentResult.transactionId ?? 0,
        e.toString(),
      ),
    );
  }

  Future<void> _updateTransactionInternal(PaymentResult paymentResult) async {
    final transactionId = paymentResult.transactionId;

    if (transactionId == null) {
      throw const TransactionUpdateException(0, 'Transaction ID manquant');
    }

    await Future.delayed(const Duration(milliseconds: 50));

    final index = _transactions.indexWhere((trs) => trs.id == transactionId);

    if (index == -1) {
      throw TransactionNotFoundException(transactionId);
    }

    _transactions[index].status;
    _transactions[index] = _transactions[index].copyWith(
      status: paymentResult.status,
    );
  }

  @override
  Future<PaymentRequest> getPaymentInfos(int transactionId) async {
    return executeWithErrorHandler(
      () async => _getPaymentInfosInternal(transactionId),
      errorMapper: (e) => TransactionNotFoundException(transactionId),
    );
  }

  Future<PaymentRequest> _getPaymentInfosInternal(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final transaction = _transactions.firstWhere(
      (trs) => trs.id == transactionId,
      orElse: () => throw TransactionNotFoundException(transactionId),
    );

    return transaction.paymentRequest;
  }

  @override
  Future<PaymentStatus> getPaymentStatus(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final transaction = _transactions.firstWhere(
      (trs) => trs.id == transactionId,
      orElse: () => throw TransactionNotFoundException(transactionId),
    );

    final status = transaction.status;

    return status;
  }

  @override
  Future<List<Payment>> getPayments() async {
    return executeWithErrorHandler(
      () async => _getPaymentsInternal(),
      errorMapper: (e) =>
          UnknownException('Erreur récupération historique: ${e.toString()}'),
    );
  }

  Future<List<Payment>> _getPaymentsInternal() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final payments = _transactions
        .map(
          (trs) => Payment(
            id: trs.id,
            status: trs.status,
            amount: trs.paymentRequest.amount,
            providerName: trs.paymentRequest.providerName,
          ),
        )
        .toList();

    return payments;
  }

  void _validatePaymentRequest(PaymentRequest request) {
    if (request.providerName.isEmpty) {
      throw const TransactionCreationException('Nom du provider requis');
    }

    if (request.amount <= 0) {
      throw const TransactionCreationException('Le montant doit être positif');
    }

    if (request.amount > 1000000) {
      throw const TransactionCreationException('Montant trop élevé');
    }
  }

  static void reset() {
    _transactions.clear();
    _nextTransactionId = 1;
  }
}
