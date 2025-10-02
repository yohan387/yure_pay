import 'dart:developer';

import 'package:yure_payment_core/core/exceptions.dart';

/// Mixin pour la gestion centralisée des exceptions
///
/// Fournit une méthode standardisée pour exécuter des opérations
/// avec capture et transformation des exceptions métier.
mixin ErrorHandlerMixin {
  /// Exécute une opération asynchrone avec gestion d'erreurs standardisée
  ///
  /// [operation] : Opération asynchrone à exécuter
  /// [errorMapper] : Fonction optionnelle pour mapper des exceptions spécifiques
  ///
  /// **Retour :** Le résultat de l'opération ou lance une [YurePaymentException]
  Future<T> executeWithErrorHandler<T>(
    Future<T> Function() operation, {
    YurePaymentException Function(Exception)? errorMapper,
  }) async {
    return _executeErrorHandler(
      () async => await operation(),
      errorMapper: errorMapper,
      isAsync: true,
    );
  }

  Stream<T> executeStreamWithErrorHandler<T>(
    Stream<T> Function() operation, {
    YurePaymentException Function(Exception)? errorMapper,
  }) async* {
    try {
      yield* operation();
    } on YurePaymentException {
      rethrow;
    } on Exception catch (e, stackTrace) {
      log('[ERROR_HANDLER] Exception originale (stream): $e');
      log('[ERROR_HANDLER] Stack trace: $stackTrace');

      final paymentException = errorMapper?.call(e) ?? _mapGenericException(e);
      log('[ERROR_HANDLER] Exception transformée: $paymentException');

      throw paymentException;
    } catch (e, stackTrace) {
      log('[ERROR_HANDLER] Erreur non-Exception (stream): $e');
      log('[ERROR_HANDLER] Stack trace: $stackTrace');

      throw UnknownException(
        'Erreur inattendue dans le stream: ${e.toString()}',
      );
    }
  }

  T executeSyncWithErrorHandler<T>(
    T Function() operation, {
    YurePaymentException Function(Exception)? errorMapper,
  }) {
    return _executeErrorHandler(
      () => operation(),
      errorMapper: errorMapper,
      isAsync: false,
    );
  }

  T _executeErrorHandler<T>(
    T Function() operation, {
    required YurePaymentException Function(Exception)? errorMapper,
    required bool isAsync,
  }) {
    try {
      return operation();
    } on YurePaymentException {
      rethrow;
    } on Exception catch (e, stackTrace) {
      final asyncLabel = isAsync ? '' : ' (sync)';
      log('[ERROR_HANDLER] Exception originale$asyncLabel: $e');
      log('[ERROR_HANDLER] Stack trace: $stackTrace');

      final paymentException = errorMapper?.call(e) ?? _mapGenericException(e);
      log('[ERROR_HANDLER] Exception transformée: $paymentException');

      throw paymentException;
    } catch (e, stackTrace) {
      final asyncLabel = isAsync ? '' : ' (sync)';
      log('[ERROR_HANDLER] Erreur non-Exception$asyncLabel: $e');
      log('[ERROR_HANDLER] Stack trace: $stackTrace');

      throw UnknownException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Mappe les exceptions génériques vers des exceptions métier
  YurePaymentException _mapGenericException(Exception e) {
    final errorMessage = e.toString().toLowerCase();

    if (errorMessage.contains('timeout') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('network')) {
      return const NetworkException();
    } else if (errorMessage.contains('not found') ||
        errorMessage.contains('introuvable')) {
      return const TransactionNotFoundException(
        0,
      ); // ID sera mis à jour par l'appelant
    } else if (errorMessage.contains('invalid') ||
        errorMessage.contains('montant')) {
      return const InvalidAmountException(
        0,
      ); // Montant sera mis à jour par l'appelant
    } else {
      return UnknownException('Erreur de traitement: ${e.toString()}');
    }
  }

  /// Méthode utilitaire pour logger les erreurs de manière consistante
  void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    log(
      '[${runtimeType.toString().toUpperCase()}] Erreur dans $context: $error',
    );
    if (stackTrace != null) {
      log('Stack trace: $stackTrace');
    }
  }
}
