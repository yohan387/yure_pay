import 'package:flutter_test/flutter_test.dart';
import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/service.dart';

void main() {
  group('YurePayBackendService', () {
    late YurePayBackendService backendService;
    late PaymentRequest evenAmountRequest;
    late PaymentRequest oddAmountRequest;
    late PaymentRequest mockProviderRequest;
    late PaymentRequest otherProviderRequest;

    // Helper method to clear transactions
    void clearTransactions() {
      // This would require adding a static clear method to YurePayBackendService
      // YurePayBackendService.clearTransactions();
    }

    setUp(() {
      backendService = YurePayBackendService();

      evenAmountRequest = PaymentRequest(
        merchantId: "123",
        article: "Mon article",
        number: 1,
        amount: 1000, // Even amount
        selectedProviderName: 'MOCK',

        // Add other required fields
      );

      oddAmountRequest = PaymentRequest(
        merchantId: "123",
        article: "Mon article",
        number: 1,
        amount: 1500, // Odd amount
        selectedProviderName: 'MOCK',
      );

      mockProviderRequest = PaymentRequest(
        merchantId: "123",
        article: "Mon article",
        number: 1,
        amount: 2000,
        selectedProviderName: 'MOCK',
      );

      otherProviderRequest = PaymentRequest(
        merchantId: "123",
        article: "Mon article",
        number: 1,
        amount: 2000,
        selectedProviderName: 'OTHER_PROVIDER',
      );

      // Clear transactions before each test
      clearTransactions();
    });

    tearDown(() {
      clearTransactions();
    });

    group('createTransaction', () {
      test(
        'should create transaction with even amount and set status to inProgress',
        () async {
          final transactionId = await backendService.createTransaction(
            evenAmountRequest,
          );

          expect(transactionId, equals(1));

          // Verify transaction was created with correct status
          final status = await backendService.getPaymentStatus(transactionId);
          expect(status, equals(PaymentStatus.inProgress));
        },
      );

      test(
        'should create transaction with odd amount and set status to failed',
        () async {
          final transactionId = await backendService.createTransaction(
            oddAmountRequest,
          );

          expect(transactionId, equals(1));

          // Verify transaction was created with failed status
          final status = await backendService.getPaymentStatus(transactionId);
          expect(status, equals(PaymentStatus.failed));
        },
      );

      test('should increment transaction IDs sequentially', () async {
        final firstId = await backendService.createTransaction(
          evenAmountRequest,
        );
        final secondId = await backendService.createTransaction(
          evenAmountRequest,
        );
        final thirdId = await backendService.createTransaction(
          evenAmountRequest,
        );

        expect(firstId, equals(1));
        expect(secondId, equals(2));
        expect(thirdId, equals(3));
      });

      test('should store transaction with correct payment request', () async {
        final transactionId = await backendService.createTransaction(
          mockProviderRequest,
        );

        final storedRequest = await backendService.getPaymentInfos(
          transactionId,
        );

        expect(storedRequest.amount, equals(mockProviderRequest.amount));
        expect(
          storedRequest.selectedProviderName,
          equals(mockProviderRequest.selectedProviderName),
        );
      });

      test('should handle zero amount as even number', () async {
        final zeroAmountRequest = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: 0, // Even amount
          selectedProviderName: 'MOCK',
        );

        final transactionId = await backendService.createTransaction(
          zeroAmountRequest,
        );
        final status = await backendService.getPaymentStatus(transactionId);

        expect(status, equals(PaymentStatus.inProgress));
      });

      test('should handle negative even amount', () async {
        final negativeEvenRequest = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: -100, // Even amount
          selectedProviderName: 'MOCK',
        );

        final transactionId = await backendService.createTransaction(
          negativeEvenRequest,
        );
        final status = await backendService.getPaymentStatus(transactionId);

        expect(status, equals(PaymentStatus.inProgress));
      });
    });

    group('updateTransaction', () {
      test('should update transaction status successfully', () async {
        final transactionId = await backendService.createTransaction(
          evenAmountRequest,
        );

        final paymentResult = PaymentResult(
          id: 1,
          transactionId: transactionId,
          status: PaymentStatus.succeeded,
          message: 'Payment completed successfully',
        );

        await backendService.updateTransaction(paymentResult);

        final updatedStatus = await backendService.getPaymentStatus(
          transactionId,
        );
        expect(updatedStatus, equals(PaymentStatus.succeeded));
      });

      test(
        'should throw exception when updating non-existent transaction',
        () async {
          final paymentResult = PaymentResult(
            id: 1,
            transactionId: 999, // Non-existent ID
            status: PaymentStatus.succeeded,
            message: 'Payment completed',
          );

          expect(
            () => backendService.updateTransaction(paymentResult),
            throwsA(isA<Exception>()),
          );
        },
      );

      test('should update transaction multiple times', () async {
        final transactionId = await backendService.createTransaction(
          evenAmountRequest,
        );

        // First update
        await backendService.updateTransaction(
          PaymentResult(
            id: 1,
            transactionId: transactionId,
            status: PaymentStatus.inProgress,
            message: 'Still in progress',
          ),
        );

        // Second update
        await backendService.updateTransaction(
          PaymentResult(
            id: 1,
            transactionId: transactionId,
            status: PaymentStatus.succeeded,
            message: 'Completed',
          ),
        );

        final finalStatus = await backendService.getPaymentStatus(
          transactionId,
        );
        expect(finalStatus, equals(PaymentStatus.succeeded));
      });
    });

    group('getPaymentInfos', () {
      test('should return correct payment information', () async {
        final transactionId = await backendService.createTransaction(
          otherProviderRequest,
        );

        final paymentInfo = await backendService.getPaymentInfos(transactionId);

        expect(paymentInfo.amount, equals(otherProviderRequest.amount));
        expect(
          paymentInfo.selectedProviderName,
          equals(otherProviderRequest.selectedProviderName),
        );
      });

      test('should throw exception for non-existent transaction', () async {
        expect(
          () => backendService.getPaymentInfos(999),
          throwsA(isA<Exception>()),
        );
      });

      test('should return identical request object to original', () async {
        final originalRequest = PaymentRequest(
          merchantId: "123",
          article: "Mon article",
          number: 1,
          amount: 2500,
          selectedProviderName: 'SPECIAL_PROVIDER',
        );

        final transactionId = await backendService.createTransaction(
          originalRequest,
        );
        final retrievedRequest = await backendService.getPaymentInfos(
          transactionId,
        );

        expect(retrievedRequest.amount, equals(originalRequest.amount));
        expect(
          retrievedRequest.selectedProviderName,
          equals(originalRequest.selectedProviderName),
        );
      });
    });

    group('getPaymentStatus', () {
      test(
        'should return correct status for even amount transaction',
        () async {
          final transactionId = await backendService.createTransaction(
            evenAmountRequest,
          );

          final status = await backendService.getPaymentStatus(transactionId);

          expect(status, equals(PaymentStatus.inProgress));
        },
      );

      test('should return correct status for odd amount transaction', () async {
        final transactionId = await backendService.createTransaction(
          oddAmountRequest,
        );

        final status = await backendService.getPaymentStatus(transactionId);

        expect(status, equals(PaymentStatus.failed));
      });

      test('should return updated status after transaction update', () async {
        final transactionId = await backendService.createTransaction(
          evenAmountRequest,
        );

        // Update status
        await backendService.updateTransaction(
          PaymentResult(
            id: 1,
            transactionId: transactionId,
            status: PaymentStatus.failed,
            message: 'Failed after update',
          ),
        );

        final status = await backendService.getPaymentStatus(transactionId);
        expect(status, equals(PaymentStatus.failed));
      });

      test('should throw exception for non-existent transaction', () async {
        expect(
          () => backendService.getPaymentStatus(999),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('integration tests', () {
      test('should handle full payment flow', () async {
        // Create transaction
        final transactionId = await backendService.createTransaction(
          evenAmountRequest,
        );
        expect(transactionId, equals(1));

        // Verify initial status
        var status = await backendService.getPaymentStatus(transactionId);
        expect(status, equals(PaymentStatus.inProgress));

        // Verify payment info
        var paymentInfo = await backendService.getPaymentInfos(transactionId);
        expect(paymentInfo.amount, equals(evenAmountRequest.amount));

        // Update transaction
        await backendService.updateTransaction(
          PaymentResult(
            id: 1,
            transactionId: transactionId,
            status: PaymentStatus.succeeded,
            message: 'Payment successful',
          ),
        );

        // Verify updated status
        status = await backendService.getPaymentStatus(transactionId);
        expect(status, equals(PaymentStatus.succeeded));
      });

      test('should maintain separate transactions', () async {
        final firstId = await backendService.createTransaction(
          evenAmountRequest,
        );
        final secondId = await backendService.createTransaction(
          oddAmountRequest,
        );

        final firstStatus = await backendService.getPaymentStatus(firstId);
        final secondStatus = await backendService.getPaymentStatus(secondId);

        expect(firstStatus, equals(PaymentStatus.inProgress));
        expect(secondStatus, equals(PaymentStatus.failed));

        final firstInfo = await backendService.getPaymentInfos(firstId);
        final secondInfo = await backendService.getPaymentInfos(secondId);

        expect(firstInfo.amount, equals(evenAmountRequest.amount));
        expect(secondInfo.amount, equals(oddAmountRequest.amount));
      });
    });
  });
}
