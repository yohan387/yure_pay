import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/src/common/interfaces.dart';
import 'package:yure_payment_core/src/providers/mock_provider.dart';
import 'package:yure_payment_core/src/repository.dart';
import 'package:yure_payment_core/src/providers/visa_provider.dart';
import 'package:yure_payment_core/src/services/service.dart';

class YurePayment implements IYurePaymentSdk {
  late final YurePaymentRepo _repo;
  static YurePayment? _instance;
  late final PaymentConfig config;

  YurePayment._();

  /// Initialize the payment SDK with merchant configuration
  static Future<void> init(PaymentConfig config) async {
    // Create the instance first
    _instance = YurePayment._();

    /// Then initialize the repository
    final List<IPaymentProvider> providers = [MockProvider(), VisaProvider()];
    final backend = YurePayBackendService();

    _instance!.config = config;
    _instance!._repo = YurePaymentRepo(providers, backend);
    _instance!._repo.paymentConfig = config;
  }

  /// Get the singleton instance (throws if not initialized)
  static YurePayment get instance {
    if (_instance == null) {
      throw Exception(
        'YurePayment must be initialized first. Call YurePayment.init()',
      );
    }
    return _instance!;
  }

  @override
  /// Récupère la liste des providers de paiement disponibles
  ///
  /// **Retour :** Liste des informations des providers configurés
  /// pour affichage dans l'interface de sélection
  List<ProviderInfo> get getAvailableProviders => _repo.getAvailableProviders;

  @override
  /// Initie un processus de paiement
  ///
  /// Crée une transaction et lance le traitement asynchrone avec le provider.
  /// Retourne immédiatement avec un statut "inProgress".
  ///
  /// [request] : Paramètres du paiement (provider, montant)
  ///
  /// **Retour :** [PaymentResult] avec ID de transaction et statut initial
  ///
  /// **Exceptions :**
  /// - `ProviderNotAvailableException` si le provider n'est pas trouvé
  /// - `TransactionCreationException` si la création échoue
  Future<PaymentResult> processPayment(PaymentRequest request) {
    return _repo.processPayment(request);
  }

  @override
  /// Tente d'annuler une transaction en cours
  ///
  /// [transactionId] : Identifiant de la transaction à annuler
  ///
  /// **Retour :** `true` si l'annulation est acceptée, `false` sinon
  ///
  /// **Exceptions :**
  /// - `TransactionNotFoundException` si la transaction n'existe pas
  /// - `ProviderNotAvailableException` si le provider n'est pas trouvé
  Future<bool> cancelPayment(int transactionId) {
    return _repo.cancelPayment(transactionId);
  }

  @override
  /// Stream des mises à jour de statut d'une transaction
  ///
  /// Fournit un flux en temps réel des changements d'état
  /// via un polling régulier du backend.
  ///
  /// [transactionId] : Identifiant de la transaction à suivre
  ///
  /// **Retour :** Stream émettant les [PaymentStatus] successifs
  ///
  /// **Arrêt automatique :** Le stream se termine quand la transaction
  /// atteint un état final (succeeded, failed, canceled)
  Stream<PaymentStatus> getPaymentStatus(int transactionId) {
    return _repo.getPaymentStatus(transactionId);
  }

  @override
  /// Récupère l'historique complet des paiements
  ///
  /// **Retour :** Liste des transactions triées par date (récent → ancien)
  ///
  /// **Exceptions :**
  /// - `PaymentException` en cas d'erreur de récupération
  Future<List<Payment>> getPayments() async {
    return _repo.getPayments();
  }
}
