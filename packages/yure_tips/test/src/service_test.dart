import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:yure_tips/core/models/tip.dart';
import 'package:yure_tips/src/service.dart';

import 'service_test.mocks.dart';

// Générer les mocks
@GenerateMocks([Box<TipHiveModel>])
void main() {
  group('HiveTipsStorageService', () {
    late HiveTipsStorageService storageService;
    late MockBox<TipHiveModel> mockBox;
    late List<TipHiveModel> mockTips;

    setUp(() {
      mockBox = MockBox<TipHiveModel>();
      storageService = HiveTipsStorageService(mockBox);

      mockTips = [
        TipHiveModel(merchantId: 'merchant_1', amount: 1000),
        TipHiveModel(merchantId: 'merchant_2', amount: 2000),
        TipHiveModel(merchantId: 'merchant_3', amount: 1500),
      ];
    });

    group('addTip', () {
      test('should add tip to Hive box', () async {
        // Arrange
        final tip = Tip(merchantId: 'test_merchant', amount: 5000);

        when(mockBox.add(any)).thenAnswer((_) async => 1);

        // Act
        await storageService.addTip(tip);

        // Assert
        verify(
          mockBox.add(
            argThat(
              predicate<TipHiveModel>(
                (model) =>
                    model.merchantId == 'test_merchant' && model.amount == 5000,
              ),
            ),
          ),
        ).called(1);
      });

      test('should convert Tip to TipHiveModel correctly', () async {
        // Arrange
        final tip = Tip(merchantId: 'test_merchant', amount: 7500);
        TipHiveModel? capturedModel;

        when(mockBox.add(any)).thenAnswer((invocation) {
          capturedModel = invocation.positionalArguments[0] as TipHiveModel;
          return Future.value(1);
        });

        // Act
        await storageService.addTip(tip);

        // Assert
        expect(capturedModel, isNotNull);
        expect(capturedModel!.merchantId, 'test_merchant');
        expect(capturedModel!.amount, 7500);
      });

      test('should handle Hive errors gracefully', () async {
        // Arrange
        final tip = Tip(merchantId: 'test_merchant', amount: 5000);
        when(mockBox.add(any)).thenThrow(HiveError('Box is closed'));

        // Act & Assert
        expect(
          () async => await storageService.addTip(tip),
          throwsA(isA<HiveError>()),
        );
      });
    });

    group('getTips', () {
      test('should return empty list when box is empty', () async {
        // Arrange
        when(mockBox.values).thenReturn([]);

        // Act
        final result = await storageService.getTips();

        // Assert
        expect(result, isEmpty);
        verify(mockBox.values).called(1);
      });

      test('should return all tips from Hive box', () async {
        // Arrange
        when(mockBox.values).thenReturn(mockTips);

        // Act
        final result = await storageService.getTips();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].merchantId, 'merchant_1');
        expect(result[0].amount, 1000);
        expect(result[1].merchantId, 'merchant_2');
        expect(result[1].amount, 2000);
        expect(result[2].merchantId, 'merchant_3');
        expect(result[2].amount, 1500);
        verify(mockBox.values).called(1);
      });

      test('should convert TipHiveModel to Tip correctly', () async {
        // Arrange
        when(mockBox.values).thenReturn(mockTips);

        // Act
        final result = await storageService.getTips();

        // Assert
        expect(result[0], isA<Tip>());
        expect(result[1], isA<Tip>());
        expect(result[2], isA<Tip>());

        // Vérifier que la conversion préserve les données
        expect(result[0].merchantId, mockTips[0].merchantId);
        expect(result[0].amount, mockTips[0].amount);
      });

      test('should handle Hive errors gracefully', () async {
        // Arrange
        when(mockBox.values).thenThrow(HiveError('Box is closed'));

        // Act & Assert
        expect(
          () async => await storageService.getTips(),
          throwsA(isA<HiveError>()),
        );
      });
    });

    group('TipHiveModel', () {
      test('fromTip should create correct TipHiveModel', () {
        // Arrange
        final tip = Tip(merchantId: 'test_merchant', amount: 3000);

        // Act
        final hiveModel = TipHiveModel.fromTip(tip);

        // Assert
        expect(hiveModel.merchantId, 'test_merchant');
        expect(hiveModel.amount, 3000);
      });

      test('toTip should create correct Tip', () {
        // Arrange
        final hiveModel = TipHiveModel(
          merchantId: 'test_merchant',
          amount: 4000,
        );

        // Act
        final tip = hiveModel.toTip();

        // Assert
        expect(tip.merchantId, 'test_merchant');
        expect(tip.amount, 4000);
      });

      test('conversion should be reversible', () {
        // Arrange
        final originalTip = Tip(merchantId: 'original_merchant', amount: 5000);

        // Act
        final hiveModel = TipHiveModel.fromTip(originalTip);
        final convertedTip = hiveModel.toTip();

        // Assert
        expect(convertedTip.merchantId, originalTip.merchantId);
        expect(convertedTip.amount, originalTip.amount);
      });
    });

    group('Integration tests', () {
      test(
        'should maintain data integrity through add and get operations',
        () async {
          // Arrange
          final tipsToAdd = [
            Tip(merchantId: 'merchant_a', amount: 1000),
            Tip(merchantId: 'merchant_b', amount: 2000),
            Tip(merchantId: 'merchant_c', amount: 3000),
          ];

          final hiveModels = tipsToAdd
              .map((tip) => TipHiveModel.fromTip(tip))
              .toList();

          when(mockBox.values).thenReturn(hiveModels);
          when(mockBox.add(any)).thenAnswer((_) async => 1);

          // Act - Simuler l'ajout
          for (final tip in tipsToAdd) {
            await storageService.addTip(tip);
          }

          // Act - Récupérer
          final retrievedTips = await storageService.getTips();

          // Assert
          expect(retrievedTips, hasLength(3));
          expect(retrievedTips[0].merchantId, 'merchant_a');
          expect(retrievedTips[0].amount, 1000);
          expect(retrievedTips[1].merchantId, 'merchant_b');
          expect(retrievedTips[1].amount, 2000);
          expect(retrievedTips[2].merchantId, 'merchant_c');
          expect(retrievedTips[2].amount, 3000);
        },
      );

      test('should handle multiple operations correctly', () async {
        // Arrange
        final List<TipHiveModel> storedModels = [];

        when(mockBox.add(any)).thenAnswer((invocation) {
          final model = invocation.positionalArguments[0] as TipHiveModel;
          storedModels.add(model);
          return Future.value(storedModels.length);
        });

        when(mockBox.values).thenAnswer((_) => storedModels);

        // Act
        await storageService.addTip(Tip(merchantId: 'first', amount: 100));
        await storageService.addTip(Tip(merchantId: 'second', amount: 200));

        final tipsAfterAdd = await storageService.getTips();

        await storageService.addTip(Tip(merchantId: 'third', amount: 300));
        final tipsAfterThirdAdd = await storageService.getTips();

        // Assert
        expect(tipsAfterAdd, hasLength(2));
        expect(tipsAfterThirdAdd, hasLength(3));
        expect(tipsAfterThirdAdd[2].merchantId, 'third');
        expect(tipsAfterThirdAdd[2].amount, 300);
      });
    });
  });
}
