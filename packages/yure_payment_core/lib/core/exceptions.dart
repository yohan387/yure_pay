/// Exception de base pour toutes les erreurs du SDK
abstract class YurePaymentException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const YurePaymentException(this.message, {this.code, this.originalException});

  @override
  String toString() =>
      'YurePaymentException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception pour les providers non disponibles
class ProviderNotAvailableException extends YurePaymentException {
  const ProviderNotAvailableException(String providerName)
    : super('Le provider $providerName n\'est pas disponible');
}

/// Exception pour les montants invalides
class InvalidAmountException extends YurePaymentException {
  const InvalidAmountException(int amount, {String? reason})
    : super('Montant invalide: $amount', code: 'INVALID_AMOUNT');
}

/// Exception pour les annulations impossibles
class CancelPaymentException extends YurePaymentException {
  const CancelPaymentException(int transactionId, String reason)
    : super('Impossible d\'annuler la transaction $transactionId: $reason');
}

/// Exception pour les erreurs réseau
class NetworkException extends YurePaymentException {
  const NetworkException([String? message])
    : super(message ?? 'Erreur de réseau', code: 'NETWORK_ERROR');
}

/// Exception pour les erreurs de traitement du provider
class PaymentProcessingException extends YurePaymentException {
  const PaymentProcessingException(String providerName, String reason)
    : super('Erreur lors du traitement par $providerName: $reason');
}

/// Exception pour les erreurs de configuration
class ConfigurationException extends YurePaymentException {
  const ConfigurationException(super.message)
    : super(code: 'CONFIGURATION_ERROR');
}

class UnknownException extends YurePaymentException {
  const UnknownException(super.message) : super(code: 'CONFIGURATION_ERROR');
}

/// Exceptions spécifiques au backend
class TransactionCreationException extends YurePaymentException {
  const TransactionCreationException(super.reason)
    : super(code: 'TRANSACTION_CREATION_FAILED');
}

class TransactionUpdateException extends YurePaymentException {
  const TransactionUpdateException(int transactionId, String reason)
    : super(
        'Échec de mise à jour transaction $transactionId: $reason',
        code: 'TRANSACTION_UPDATE_FAILED',
      );
}

class TransactionNotFoundException extends YurePaymentException {
  const TransactionNotFoundException(int transactionId)
    : super(
        'Transaction $transactionId non trouvée',
        code: 'TRANSACTION_NOT_FOUND',
      );
}
