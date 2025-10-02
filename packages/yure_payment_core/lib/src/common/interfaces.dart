import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';

/// Interface principale du SDK de Paiement Yure
///
/// Définit le contrat que doit implémenter le SDK de paiement
/// et toutes autres versions spécifiques.
/// Elle fournit les fonctionnalités essentielles aux marchands.
///
/// ### Cycle de vie typique :
/// 1. Récupérer les providers disponibles → [getAvailableProviders]
/// 2. Initier un paiement → [processPayment]
/// 3. Suivre le statut → [getPaymentStatus]
/// 4. Optionnellement annuler → [cancelPayment]
abstract class IYurePaymentSdk {
  /// Liste des providers de paiement disponibles et configurés
  ///
  /// Retourne la liste des moyens de paiement supportés
  /// (cartes, mobile money, etc.) avec leurs métadonnées
  /// pour affichage dans l'interface de sélection.
  ///
  /// **Exemple :**
  /// ```dart
  /// final providers = paymentSdk.getAvailableProviders;
  /// providers.forEach((provider) {
  ///   print('${provider.name} - ${provider.logo}');
  /// });
  /// ```
  List<ProviderInfo> get getAvailableProviders;

  /// Récupère l'historique complet des transactions du marchand
  ///
  /// Retourne la liste chronologique des paiements effectués
  /// avec leurs statuts et métadonnées. Utile pour :
  /// - Affichage de l'historique
  /// - Rapports de ventes
  /// - Synchronisation avec le système du marchand
  ///
  /// **Retour :** Liste des transactions triées
  Future<List<Payment>> getPayments();

  /// Initie un processus de paiement avec le provider spécifié
  ///
  /// Crée une nouvelle transaction et la soumet au provider
  /// de paiement sélectionné. Le processus est asynchrone
  /// et peut inclure des redirections vers des interfaces tierces.
  ///
  /// [request] : Paramètres du paiement (provider, montant)
  ///
  /// **Retour :** [PaymentResult] avec le statut initial et l'ID de transaction
  ///
  /// **Exceptions :**
  /// - `ProviderNotAvailableException` si le provider n'est pas configuré
  /// - `InvalidAmountException` si le montant est invalide
  /// - `NetworkException` en cas d'erreur de connexion
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// Tente d'annuler une transaction en cours
  ///
  /// Annule une transaction si elle est encore en état annulable.
  /// Disponibilité dépendante du provider et du timing.
  ///
  /// [transactionId] : Identifiant de la transaction à annuler
  ///
  /// **Retour :** `true` si l'annulation est acceptée, `false` sinon
  ///
  /// **Notes :**
  /// - Les transactions déjà terminées ne peuvent être annulées
  /// - Certains providers n'autorisent pas l'annulation
  /// - L'annulation peut prendre quelques secondes à se propager
  Future<bool> cancelPayment(int transactionId);

  /// Stream des mises à jour de statut d'une transaction
  ///
  /// Fournit un flux en temps réel des changements d'état
  /// d'une transaction spécifique. Essentiel pour :
  /// - Mettre à jour l'interface utilisateur
  /// - Déclencher des actions post-paiement
  /// - Surveiller les transactions longues
  ///
  /// [transactionId] : Identifiant de la transaction à suivre
  ///
  /// **Retour :** Stream émettant les [PaymentStatus] successifs
  ///
  /// **Cycle typique :**
  /// `inProgress` → `succeeded` | `failed` | `canceled`
  ///
  /// **Exemple :**
  /// ```dart
  /// paymentSdk.getPaymentStatus(transactionId).listen((status) {
  ///   print('Statut mis à jour: $status');
  /// });
  /// ```
  Stream<PaymentStatus> getPaymentStatus(int transactionId);
}

/// Interface contractuelle des providers de paiement
///
/// Définit le contrat que doit implémenter chaque intégration
/// de provider (Visa, Mobile Money, PayPal, etc.).
///
/// ### Pattern Provider :
/// - Chaque provider implémente cette interface
/// - Le SDK orchestre les providers disponibles
/// - Extensible par ajout de nouveaux providers
abstract class IPaymentProvider {
  /// Nom d'affichage du provider
  ///
  /// Utilisé dans les interfaces utilisateur pour identifier
  /// le moyen de paiement de manière lisible.
  ///
  /// **Exemples :** "Visa/MasterCard", "Mobile Money", "PayPal"
  String get name;

  /// URL ou asset path du logo du provider
  ///
  /// Permet d'afficher visuellement le provider
  /// dans les sélecteurs de moyen de paiement.
  ///
  /// **Formats supportés :**
  /// - Data URL pour les images embarquées
  String get logo;

  /// Vérifie si ce provider peut traiter une requête donnée
  ///
  /// Permet au SDK de router automatiquement les requêtes
  /// vers le provider approprié selon :
  /// - Le type de paiement
  /// - La devise
  /// - Les restrictions géographiques
  /// - La configuration du marchand
  ///
  /// [request] : Requête de paiement à évaluer
  ///
  /// **Retour :** `true` si le provider peut traiter la requête
  /// NB : Pour la démo, l'on se base uniquement sur le nom pour
  /// déterminer si le provider peut effectuer la transaction.
  bool canHandle(PaymentRequest request);

  /// Traite une transaction de paiement
  ///
  /// Méthode principale qui exécute le flux de paiement
  /// spécifique au provider. Peut inclure :
  /// - Appels API REST
  /// - Redirections utilisateur
  /// - Validation de sécurité
  /// - Communication avec les banques
  ///
  /// [merchantId] : Identifiant du marchand. Cas mobile money : son n° de téléphone,
  /// cas d'une banque : son RIB, etc
  /// [transactionId] : ID unique de la transaction dans le système Yure
  /// [amount] : Montant de la transaction
  ///
  /// **Retour :** [PaymentResult] avec le statut final du traitement
  ///
  /// **Exceptions :**
  /// - `PaymentProcessingException` pour les erreurs métier
  /// - `NetworkException` pour les problèmes de connexion
  /// - `SecurityException` pour les échecs d'authentification
  Future<PaymentResult> processPayment({
    required String merchantId,
    required int transactionId,
    required int amount,
  });

  /// Tente d'annuler une transaction chez le provider
  ///
  /// Méthode spécifique au provider pour annuler une transaction
  /// en cours. L'implémentation varie selon les capacités
  /// techniques de chaque provider.
  ///
  /// [transactionId] : ID de la transaction à annuler
  ///
  /// **Retour :** `true` si l'annulation est confirmée par le provider
  ///
  /// **Notes :**
  /// - Certains providers ne supportent pas l'annulation
  /// - Les délais d'annulation varient
  /// - Les frais peuvent s'appliquer selon le provider
  Future<bool> cancelPayment(int transactionId);
}
