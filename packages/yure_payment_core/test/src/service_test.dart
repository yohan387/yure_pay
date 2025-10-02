import 'package:flutter_test/flutter_test.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/core/exceptions.dart';
import 'package:yure_payment_core/src/services/service.dart';

void main() {
  group('YurePayBackendService', () {
    late YurePayBackendService backend;

    setUp(() {
      backend = YurePayBackendService();
      YurePayBackendService.reset(); // Réinitialiser avant chaque test
    });

    test('createTransaction should return unique transaction ID', () async {
      final request1 = PaymentRequest(providerName: 'MOCK', amount: 1000);

      final request2 = PaymentRequest(providerName: 'VISA', amount: 2000);

      final id1 = await backend.createTransaction(request1);
      final id2 = await backend.createTransaction(request2);

      expect(id1, 1);
      expect(id2, 2);
      expect(id1, isNot(equals(id2)));
    });

    test(
      'createTransaction should set correct initial status for even amounts',
      () async {
        final request = PaymentRequest(
          providerName: 'MOCK',
          amount: 1000, // Montant pair
        );

        final transactionId = await backend.createTransaction(request);
        final status = await backend.getPaymentStatus(transactionId);

        expect(status, PaymentStatus.inProgress);
      },
    );

    test(
      'createTransaction should set failed status for odd amounts',
      () async {
        final request = PaymentRequest(
          providerName: 'MOCK',
          amount: 1001, // Montant impair
        );

        final transactionId = await backend.createTransaction(request);
        final status = await backend.getPaymentStatus(transactionId);

        expect(status, PaymentStatus.failed);
      },
    );

    test('updateTransaction should update transaction status', () async {
      final request = PaymentRequest(providerName: 'MOCK', amount: 1000);

      final transactionId = await backend.createTransaction(request);

      // Vérifier statut initial
      var status = await backend.getPaymentStatus(transactionId);
      expect(status, PaymentStatus.inProgress);

      // Mettre à jour le statut
      await backend.updateTransaction(
        PaymentResult(
          transactionId: transactionId,
          status: PaymentStatus.succeeded,
          message: 'Paiement réussi',
        ),
      );

      // Vérifier statut mis à jour
      status = await backend.getPaymentStatus(transactionId);
      expect(status, PaymentStatus.succeeded);
    });

    test(
      'updateTransaction should throw for non-existent transaction',
      () async {
        final result = PaymentResult(
          transactionId: 999, // ID inexistant
          status: PaymentStatus.succeeded,
          message: 'Test',
        );

        expect(
          () async => await backend.updateTransaction(result),
          throwsA(isA<TransactionNotFoundException>()),
        );
      },
    );

    test('getPaymentInfos should return original payment request', () async {
      final originalRequest = PaymentRequest(
        providerName: 'VISA',
        amount: 5000,
      );

      final transactionId = await backend.createTransaction(originalRequest);
      final retrievedRequest = await backend.getPaymentInfos(transactionId);

      expect(retrievedRequest.providerName, originalRequest.providerName);
      expect(retrievedRequest.amount, originalRequest.amount);
    });

    test('getPaymentInfos should throw for non-existent transaction', () async {
      expect(
        () async => await backend.getPaymentInfos(999),
        throwsA(isA<TransactionNotFoundException>()),
      );
    });

    test('getPayments should return all transactions', () async {
      // Créer plusieurs transactions
      await backend.createTransaction(
        PaymentRequest(providerName: 'MOCK', amount: 1000),
      );

      await backend.createTransaction(
        PaymentRequest(providerName: 'VISA', amount: 2000),
      );

      final payments = await backend.getPayments();

      expect(payments.length, 2);
      // La dernière transaction créée (VISA) devrait être en première position
      expect(payments[0].providerName, 'MOCK');
      expect(payments[1].providerName, 'VISA');
    });
    test('getPayments should return empty list when no transactions', () async {
      final payments = await backend.getPayments();

      expect(payments, isEmpty);
    });

    test('reset should clear all transactions', () async {
      await backend.createTransaction(
        PaymentRequest(providerName: 'MOCK', amount: 1000),
      );

      expect(await backend.getPayments(), isNotEmpty);

      YurePayBackendService.reset();

      expect(await backend.getPayments(), isEmpty);
    });
  });
}
