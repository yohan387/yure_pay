import 'package:flutter_test/flutter_test.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/providers/mock_provider.dart';

void main() {
  group('MockProvider', () {
    late MockProvider mockProvider;
    late PaymentRequest validPaymentRequest;
    late PaymentRequest invalidPaymentRequest;

    // Helper method to clear mock requests
    void _clearMockRequests() {
      // Access private field using reflection or provide a public method
      // This assumes you add a static clear method to MockProvider
      // MockProvider.clearRequests();
    }

    setUp(() {
      mockProvider = MockProvider();
      validPaymentRequest = PaymentRequest(
        merchantId: "123",
        article: "Mon article",
        number: 1,
        amount: 50000,
        selectedProviderName: 'MOCK',
        // Add other required fields based on your PaymentRequest model
      );
      invalidPaymentRequest = PaymentRequest(
        amount: 200000, // Exceeds max amount
        merchantId: "123",
        article: "Mon article",
        number: 1,
        selectedProviderName: 'MOCK',
        // Add other required fields
      );

      // Clear requests before each test
      _clearMockRequests();
    });

    tearDown(() {
      _clearMockRequests();
    });

    test('should have correct name', () {
      expect(mockProvider.name, equals('MOCK'));
    });

    group('canHandle', () {
      test('should return true for MOCK provider name', () {
        final request = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: 1000,
          selectedProviderName: 'MOCK',
        );

        expect(mockProvider.canHandle(request), isTrue);
      });

      test('should return false for non-MOCK provider name', () {
        final request = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: 1000,
          selectedProviderName: 'OTHER_PROVIDER',
        );

        expect(mockProvider.canHandle(request), isFalse);
      });
    });

    group('processPayment', () {
      test('should process valid payment amount successfully', () async {
        const transactionId = 123;

        final result = await mockProvider.processPayment(
          validPaymentRequest,
          transactionId,
        );

        expect(result.id, equals(transactionId));
        expect(result.status, equals(PaymentStatus.inProgress));
        expect(result.message, contains('Paiement MOCK accepté et en cours'));
      });

      test('should fail for payment amount exceeding maximum', () async {
        const transactionId = 124;

        final result = await mockProvider.processPayment(
          invalidPaymentRequest,
          transactionId,
        );

        expect(result.id, equals(transactionId));
        expect(result.status, equals(PaymentStatus.failed));
        expect(result.message, contains('Paiement MOCK refusé'));
        expect(result.message, contains('montant trop élevé'));
      });

      test('should take approximately 14 seconds to complete', () async {
        const transactionId = 125;
        final stopwatch = Stopwatch()..start();

        await mockProvider.processPayment(validPaymentRequest, transactionId);

        stopwatch.stop();
        expect(stopwatch.elapsed.inSeconds, greaterThanOrEqualTo(14));
        expect(
          stopwatch.elapsed.inSeconds,
          lessThan(15),
        ); // Allow some tolerance
      });

      // test('should store payment request in internal list', () async {
      //   const transactionId = 126;
      //   final initialRequestCount = _getMockRequestsCount();

      //   await mockProvider.processPayment(validPaymentRequest, transactionId);

      //   expect(_getMockRequestsCount(), equals(initialRequestCount + 1));
      // });
    });

    group('cancelPayment', () {
      // test('should cancel in-progress payment successfully', () async {
      //   const transactionId = 127;

      //   // First process a payment
      //   await mockProvider.processPayment(validPaymentRequest, transactionId);

      //   // Then cancel it
      //   final cancelResult = await mockProvider.cancelPayment(transactionId);

      //   expect(cancelResult, isTrue);

      //   // Verify the status was updated to canceled
      //   final canceledRequest = _getMockRequestByTransactionId(transactionId);
      //   expect(canceledRequest.status, equals(PaymentStatus.canceled));
      // });

      test(
        'should return false when canceling non-in-progress payment',
        () async {
          const transactionId = 128;

          // Process a payment that will fail (exceeds max amount)
          await mockProvider.processPayment(
            invalidPaymentRequest,
            transactionId,
          );

          // Try to cancel the failed payment
          final cancelResult = await mockProvider.cancelPayment(transactionId);

          expect(cancelResult, isFalse);
        },
      );

      test('should throw exception for non-existent transaction', () async {
        const nonExistentTransactionId = 999;

        expect(
          () => mockProvider.cancelPayment(nonExistentTransactionId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('edge cases', () {
      test('should handle maximum allowed payment amount', () async {
        const transactionId = 129;
        final maxAmountRequest = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: 100000, // Exactly the maximum
          selectedProviderName: 'MOCK',
        );

        final result = await mockProvider.processPayment(
          maxAmountRequest,
          transactionId,
        );

        expect(result.status, equals(PaymentStatus.inProgress));
      });

      test('should handle zero amount payment', () async {
        const transactionId = 130;
        final zeroAmountRequest = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: 0,
          selectedProviderName: 'MOCK',
        );

        final result = await mockProvider.processPayment(
          zeroAmountRequest,
          transactionId,
        );

        expect(result.status, equals(PaymentStatus.inProgress));
      });
    });
  });
}

// // Helper functions (you would need to implement these in your MockProvider)
// int _getMockRequestsCount() {
//   // This would require exposing the requests list or adding a getter
//   // return MockProvider.requestsCount;
//   return 0;
// }

// _MockPaymentRequest _getMockRequestByTransactionId(int transactionId) {
//   // This would require exposing access to the requests list
//   // return MockProvider.getRequestByTransactionId(transactionId);
//   throw UnimplementedError('Implement access to mock requests in MockProvider');
// }
