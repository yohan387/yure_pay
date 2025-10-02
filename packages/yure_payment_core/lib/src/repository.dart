import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/core/exceptions.dart';
import 'package:yure_payment_core/src/common/interfaces.dart';
import 'package:yure_payment_core/src/common/errors/error_handler.dart';
import 'package:yure_payment_core/src/services/interface.dart';

/// Repository principal du SDK de paiement Yure
///
/// Orchestre les interactions entre les providers de paiement
/// et le service backend. Gère le cycle de vie complet des transactions.
class YurePaymentRepo with ErrorHandlerMixin {
  final List<IPaymentProvider> _providers;
  final IYurePayBackendService _backend;
  static late final PaymentConfig _config;

  /// Configure les paramètres du marchand
  set paymentConfig(PaymentConfig config) {
    _config = config;
  }

  YurePaymentRepo(this._providers, this._backend);

  // Trouve le provider capable de traiter une requête donnée
  IPaymentProvider _getProvider(PaymentRequest request) {
    return executeSyncWithErrorHandler(
      () => _providers.firstWhere(
        (p) => p.canHandle(request),
        orElse: () => throw ProviderNotAvailableException(request.providerName),
      ),
      errorMapper: (e) => ProviderNotAvailableException(request.providerName),
    );
  }

  List<ProviderInfo> get getAvailableProviders {
    return executeSyncWithErrorHandler(
      () => _providers
          .map((p) => ProviderInfo(id: p.name, name: p.name, logo: p.logo))
          .toList(),
      errorMapper: (e) => ConfigurationException(
        'Erreur lors de la récupération des providers: ${e.toString()}',
      ),
    );
  }

  Future<PaymentResult> processPayment(PaymentRequest request) async {
    return executeWithErrorHandler(
      () async => _processPaymentInternal(request),
      errorMapper: (e) => PaymentProcessingException(
        request.providerName,
        'Erreur lors du traitement: ${e.toString()}',
      ),
    );
  }

  /// Implémentation interne du processus de paiement
  Future<PaymentResult> _processPaymentInternal(PaymentRequest request) async {
    final provider = _getProvider(request);

    final transactionId = await _backend.createTransaction(request);

    _startBackgroundProcessing(provider, transactionId, request);

    return PaymentResult(
      transactionId: transactionId,
      message: "Paiement en cours de traitement.",
      status: PaymentStatus.inProgress,
      request: request,
    );
  }

  /// Traitement asynchrone en arrière-plan avec le provider
  ///
  /// Exécuté séparément du flux principal pour ne pas bloquer
  /// le retour immédiat au marchand.
  Future<void> _startBackgroundProcessing(
    IPaymentProvider provider,
    int transactionId,
    PaymentRequest request,
  ) async {
    try {
      final result = await provider.processPayment(
        merchantId: _config.merchantId,
        transactionId: transactionId,
        amount: request.amount,
      );

      await _backend.updateTransaction(result);
    } catch (error, _) {
      await _backend.updateTransaction(
        PaymentResult(
          transactionId: transactionId,
          status: PaymentStatus.failed,
          message: "Erreur de traitement: $error",
          request: request,
        ),
      );
    }
  }

  Future<bool> cancelPayment(int transactionId) async {
    return executeWithErrorHandler(
      () async => _cancelPaymentInternal(transactionId),
      errorMapper: (e) => CancelPaymentException(
        transactionId,
        'Erreur lors de l\'annulation: ${e.toString()}',
      ),
    );
  }

  /// Implémentation interne de l'annulation
  Future<bool> _cancelPaymentInternal(int transactionId) async {
    final request = await _backend.getPaymentInfos(transactionId);

    final provider = _getProvider(request);

    final cancellationResult = await provider.cancelPayment(transactionId);

    return cancellationResult;
  }

  Stream<PaymentStatus> getPaymentStatus(int transactionId) {
    return executeStreamWithErrorHandler(
      () => _getPaymentStatusInternal(transactionId),
      errorMapper: (e) =>
          UnknownException('Erreur lors du suivi de statut: ${e.toString()}'),
    );
  }

  /// Implémentation interne du stream de statut
  Stream<PaymentStatus> _getPaymentStatusInternal(int transactionId) async* {
    while (true) {
      try {
        final status = await _backend.getPaymentStatus(transactionId);

        yield status;

        if (_isFinalStatus(status)) {
          break;
        }

        await Future.delayed(const Duration(seconds: 2));
      } catch (error, _) {
        yield PaymentStatus.failed;
        break;
      }
    }
  }

  Future<List<Payment>> getPayments() async {
    return executeWithErrorHandler(
      () async => _getPaymentsInternal(),
      errorMapper: (e) =>
          UnknownException('Erreur récupération historique: ${e.toString()}'),
    );
  }

  Future<List<Payment>> _getPaymentsInternal() async {
    final payments = await _backend.getPayments();

    return payments;
  }

  /// Vérifie si un statut est final (non modifiable)
  bool _isFinalStatus(PaymentStatus status) {
    return status == PaymentStatus.succeeded ||
        status == PaymentStatus.failed ||
        status == PaymentStatus.canceled;
  }
}
