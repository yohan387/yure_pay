import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/exceptions.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/yure_payment_core.dart';

/// Controller pour gérer la logique de paiement (sans dépendance UI)
class PaymentController {
  final YurePayment _paymentSdk = YurePayment.instance;

  ProviderInfo? _selectedProvider;
  List<ProviderInfo> _availableProviders = [];

  ProviderInfo? get selectedProvider => _selectedProvider;
  List<ProviderInfo> get availableProviders => _availableProviders;

  /// Charge les providers disponibles
  Future<void> loadProviders() async {
    try {
      _availableProviders = _paymentSdk.getAvailableProviders;
    } catch (e) {
      if (e is YurePaymentException) {
        throw Exception(e.message);
      }
      throw Exception('Erreur chargement providers');
    }
  }

  /// Sélectionne un provider
  void selectProvider(ProviderInfo provider) {
    _selectedProvider = provider;
  }

  /// Traite le paiement principal
  Future<PaymentResult> processMainPayment({
    required int amount,
    required String providerName,
  }) async {
    if (providerName.isEmpty) {
      throw Exception('Nom du provider requis');
    }

    try {
      return await _paymentSdk.processPayment(
        PaymentRequest(providerName: providerName, amount: amount),
      );
    } catch (e) {
      if (e is YurePaymentException) {
        throw Exception(e.message);
      }
      throw Exception("Erreur lors du paiement. Veuilez réessayer.");
    }
  }

  /// Récupère l'historique des paiements
  Future<List<Payment>> getPaymentHistory() async {
    try {
      return await _paymentSdk.getPayments();
    } catch (e) {
      if (e is YurePaymentException) {
        throw Exception(e.message);
      }
      throw Exception('Erreur récupération historique');
    }
  }

  /// Annule un paiement en cours
  Future<bool> cancelPayment(int transactionId) async {
    try {
      return await _paymentSdk.cancelPayment(transactionId);
    } catch (e) {
      if (e is YurePaymentException) {
        throw Exception(e.message);
      }
      throw Exception('Erreur annulation');
    }
  }

  Stream<PaymentStatus> getPaymentStatus(int transactionId) {
    try {
      return _paymentSdk.getPaymentStatus(transactionId);
    } catch (e) {
      if (e is YurePaymentException) {
        throw Exception(e.message);
      }
      throw Exception('Erreur récupération statut');
    }
  }
}
