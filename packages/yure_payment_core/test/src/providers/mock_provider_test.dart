import 'package:flutter_test/flutter_test.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/core/exceptions.dart';

import 'package:yure_payment_core/src/providers/mock_provider.dart';

void main() {
  group('MockProvider', () {
    late MockProvider provider;

    setUp(() {
      provider = MockProvider();
      MockProvider.reset(); // Réinitialiser avant chaque test
    });

    test('should return correct name and logo', () {
      expect(provider.name, 'MOCK');
      expect(provider.logo, '🧪');
    });

    test('canHandle should return true for MOCK provider', () {
      final request = PaymentRequest(providerName: 'MOCK', amount: 1000);

      expect(provider.canHandle(request), true);
    });

    test('canHandle should return false for other providers', () {
      final request = PaymentRequest(providerName: 'VISA', amount: 1000);

      expect(provider.canHandle(request), false);
    });

    test('processPayment should succeed for valid amount', () async {
      final result = await provider.processPayment(
        merchantId: 'test_merchant',
        transactionId: 1,
        amount: 5000,
      );

      expect(result.status, PaymentStatus.succeeded);
      expect(result.transactionId, 1);
      expect(result.message, contains('validé'));
    });

    test('processPayment should fail for amount exceeding limit', () async {
      final result = await provider.processPayment(
        merchantId: 'test_merchant',
        transactionId: 2,
        amount: 2000000, // Supérieur à _kMaxPaymentAmount
      );

      expect(result.status, PaymentStatus.failed);
      expect(result.message, contains('montant trop élevé'));
    });

    test('processPayment should fail for zero amount', () async {
      expect(
        () async => await provider.processPayment(
          merchantId: 'test_merchant',
          transactionId: 3,
          amount: 0,
        ),
        throwsA(isA<InvalidAmountException>()),
      );
    });

    test('cancelPayment should succeed for in-progress transaction', () async {
      // Utiliser un provider avec délai court pour les tests
      final testProvider = MockProvider();

      // Démarrer le traitement
      testProvider.processPayment(
        merchantId: 'test_merchant',
        transactionId: 4,
        amount: 1000,
      );

      // Annuler rapidement
      await Future.delayed(const Duration(milliseconds: 10));
      final canCancel = await testProvider.cancelPayment(4);

      expect(canCancel, true);
    });

    test('cancelPayment should fail for completed transaction', () async {
      // Créer et attendre la fin du traitement
      await provider.processPayment(
        merchantId: 'test_merchant',
        transactionId: 5,
        amount: 1000,
      );

      // Attendre que le traitement soit terminé
      await Future.delayed(const Duration(seconds: 3));

      final canCancel = await provider.cancelPayment(5);

      expect(canCancel, false);
    });

    test('should maintain transaction history', () async {
      expect(MockProvider.requestHistory.length, 0);

      await provider.processPayment(
        merchantId: 'test_merchant',
        transactionId: 6,
        amount: 1000,
      );

      expect(MockProvider.requestHistory.length, 1);
      expect(MockProvider.requestHistory.first.transactionId, 6);
    });

    test('reset should clear transaction history', () async {
      await provider.processPayment(
        merchantId: 'test_merchant',
        transactionId: 7,
        amount: 1000,
      );

      expect(MockProvider.requestHistory.length, 1);

      MockProvider.reset();

      expect(MockProvider.requestHistory.length, 0);
    });
  });
}
