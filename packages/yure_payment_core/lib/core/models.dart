import 'package:yure_payment_core/core/enums.dart';

/// SDK de Paiement - Classes principales exposées au marchand
///
/// Ce SDK permet aux marchands d'intégrer un système de paiement
/// avec multiple providers dans leur application Flutter.

/// Résultat d'une opération de paiement retourné au marchand
///
/// Contient les informations finales sur l'état du paiement
/// après traitement par le provider sélectionné.
class PaymentResult {
  /// Identifiant unique de la transaction dans le système
  /// Peut être null si la transaction n'a pas pu être créée
  final int? transactionId;

  /// Message descriptif sur l'état du paiement
  /// (succès, échec, raison du refus, etc.)
  final String? message;

  /// Statut courant du paiement
  /// [PaymentStatus.inProgress] : En cours de traitement
  /// [PaymentStatus.succeeded] : Paiement réussi
  /// [PaymentStatus.failed] : Paiement échoué
  /// [PaymentStatus.canceled] : Paiement annulé
  final PaymentStatus status;

  /// Requête de paiement originale qui a initié la transaction
  /// Permet de conserver le contexte du paiement
  final PaymentRequest? request;

  PaymentResult({
    this.transactionId,
    this.message,
    required this.status,
    this.request,
  });
}

/// Paramètres de paiement fournis par le marchand
///
/// Cette classe encapsule toutes les informations nécessaires
/// pour initier un processus de paiement.
class PaymentRequest {
  /// Identifiant du provider de paiement à utiliser
  /// Ex: 'visa', 'momo', 'paypal', 'mock'
  final String providerName;

  /// Montant de la transaction
  final int amount;

  const PaymentRequest({required this.providerName, required this.amount});
}

/// Configuration du marchand pour le SDK de paiement
///
/// Contient les identifiants et informations du marchand
/// nécessaires à l'authentification et au tracking.
class PaymentConfig {
  /// Identifiant unique du marchand dans le système de paiement
  /// Utilisé pour l'authentification et le reporting
  final String merchantId;

  /// Nom commercial du marchand
  /// Affiché dans l'interface de paiement si nécessaire
  final String merchantName;

  const PaymentConfig({required this.merchantId, required this.merchantName});
}

/// Informations d'un provider de paiement disponible
///
/// Présenté au marchand pour sélection du mode de paiement
/// dans l'interface utilisateur.
class ProviderInfo {
  /// Identifiant technique du provider
  /// Ex: 'Mock', 'Visa', 'Paypal'
  final String id;

  /// Nom d'affichage du provider
  /// Ex: 'Carte Bancaire', 'Mobile Money', 'PayPal'
  final String name;

  /// Logo du provider
  final String logo;

  ProviderInfo({required this.id, required this.name, required this.logo});
}

/// Représentation d'une transaction de paiement
///
/// Utilisé pour le suivi et l'historique des transactions
/// dans le système du marchand.
class Payment {
  /// Identifiant unique de la transaction
  final int id;

  /// Montant de la transaction
  final int amount;

  /// Nom du provider utilisé pour ce paiement
  final String providerName;

  /// Statut courant de la transaction
  /// Peut évoluer dans le temps (inProgress → succeeded/failed)
  PaymentStatus status;

  Payment({
    required this.id,
    required this.amount,
    required this.providerName,
    required this.status,
  });
}
