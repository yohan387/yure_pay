import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

// Modèle manipulé par le backend commun entre les providers
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
