import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

/// Interface pour le service backend de paiement Yure
///
/// Définit le contrat pour les opérations de persistance et de gestion
/// des transactions de paiement dans le système backend.
abstract interface class IYurePayBackendService {
  /// Crée une nouvelle transaction dans le système
  ///
  /// [request] : Les détails de la requête de paiement
  ///
  /// **Retour :** L'identifiant unique de la transaction créée
  ///
  /// **Exceptions :**
  /// - `TransactionCreationException` si la création échoue
  Future<int> createTransaction(PaymentRequest request);

  /// Récupère les informations de paiement d'une transaction
  ///
  /// [transactionId] : L'identifiant de la transaction
  ///
  /// **Retour :** Les informations originales de la requête de paiement
  ///
  /// **Exceptions :**
  /// - `TransactionNotFoundException` si la transaction n'existe pas
  Future<PaymentRequest> getPaymentInfos(int transactionId);

  /// Met à jour le statut d'une transaction existante
  ///
  /// [paymentResult] : Le résultat du paiement avec le nouveau statut
  ///
  /// **Exceptions :**
  /// - `TransactionNotFoundException` si la transaction n'existe pas
  /// - `TransactionUpdateException` si la mise à jour échoue
  Future<void> updateTransaction(PaymentResult paymentResult);

  /// Récupère le statut courant d'une transaction
  ///
  /// [transactionId] : L'identifiant de la transaction
  ///
  /// **Retour :** Le statut actuel de la transaction
  ///
  /// **Exceptions :**
  /// - `TransactionNotFoundException` si la transaction n'existe pas
  Future<PaymentStatus> getPaymentStatus(int transactionId);

  /// Récupère l'historique complet des paiements
  ///
  /// **Retour :** Liste de tous les paiements triés par date de création
  Future<List<Payment>> getPayments();
}
