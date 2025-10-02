import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

// Pour simuler le service qui communique avec le backend de Yure
abstract interface class IYurePayBackendService {
  Future<int> createTransaction(PaymentRequest request);

  Future<PaymentRequest> getPaymentInfos(int transactionId);

  Future<void> updateTransaction(PaymentResult paymentResult);

  Future<PaymentStatus> getPaymentStatus(int transactionId);
}

// Pour simuler les traitement avec un backend réel.
class YurePayBackendService implements IYurePayBackendService {
  static final List<Transaction> _transactions = [];

  // TESTS PURPOSE
  static void clearTransactions() => _transactions.clear();
  static int get transactionsCount => _transactions.length;
  static Transaction getTransactionById(int id) =>
      _transactions.firstWhere((trs) => trs.id == id);

  //END TESTS PURPOSE

  @override
  Future<int> createTransaction(PaymentRequest request) async {
    final int newTransactionId = _transactions.length + 1;
    final bool isPairAmount = request.amount % 2 == 0;
    final PaymentStatus paymentStatus = isPairAmount
        ? PaymentStatus.inProgress
        : PaymentStatus.failed;

    _transactions.add(
      Transaction(
        id: newTransactionId,
        paymentRequest: request,
        status: paymentStatus,
      ),
    );

    return newTransactionId;
  }

  @override
  Future<void> updateTransaction(PaymentResult paymentResult) async {
    final index = _transactions.indexWhere(
      (trs) => trs.id == paymentResult.transactionId,
    );

    if (index == -1) {
      throw Exception("Transaction non trouvée");
    }

    _transactions[index] = _transactions[index].copyWith(
      status: paymentResult.status,
    );
  }

  @override
  Future<PaymentRequest> getPaymentInfos(int transactionId) async {
    final transaction = _transactions.firstWhere(
      (trs) => trs.id == transactionId,
      orElse: () => throw Exception("Transaction non trouvée"),
    );
    return transaction.paymentRequest;
  }

  @override
  Future<PaymentStatus> getPaymentStatus(int transactionId) async {
    final transaction = _transactions.firstWhere(
      (trs) => trs.id == transactionId,
      orElse: () => throw Exception("Transaction non trouvée"),
    );
    return transaction.status;
  }
}
