// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:yure_payment_core/core/enums.dart';

class PaymentResult {
  final int id;
  final int? transactionId;
  final String message;
  final PaymentStatus status;

  PaymentResult({
    required this.id,
    this.transactionId,
    required this.message,
    required this.status,
  });
}

class PaymentRequest {
  final String selectedProviderName;
  final String merchantId;
  final String article;
  final int amount;
  final int number;

  const PaymentRequest({
    required this.selectedProviderName,
    required this.merchantId,
    required this.article,
    required this.amount,
    required this.number,
  });
}

class Transaction {
  final int id;
  final PaymentRequest paymentRequest;
  final PaymentStatus status;

  Transaction({
    required this.id,
    required this.paymentRequest,
    required this.status,
  });

  Transaction copyWith({
    int? id,
    PaymentRequest? paymentRequest,
    PaymentStatus? status,
  }) {
    return Transaction(
      id: id ?? this.id,
      paymentRequest: paymentRequest ?? this.paymentRequest,
      status: status ?? this.status,
    );
  }
}

class PaymentConfig {}

class ProviderInfo {
  final String id; // ex: "visa", "momo", "mock"
  final String name; // ex: "Visa", "Mobile Money", "Provider de test"
  // éventuellement un logo, une description, etc.

  ProviderInfo({required this.id, required this.name});
}
