import 'package:yure_payment_core/core/enums.dart';
import 'package:yure_payment_core/core/exceptions.dart';
import 'package:yure_payment_core/core/models.dart';
import 'package:yure_payment_core/yure_payment_core.dart';
import 'package:yure_tips/core/models/tip.dart';
import 'package:yure_tips/src/service.dart';

abstract class ITipsRepo {
  Future<void> addTip(TipRequest tipRequest);
  Future<List<Tip>> listTips();
}

class LocalTipsRepo implements ITipsRepo {
  final ILocalTipsStorageService _storage;
  final YurePayment _yurePayment;
  PaymentConfig? _config;

  /// Configure les paramètres du marchand
  void setPaymentConfig(PaymentConfig config) {
    _config = config;
  }

  PaymentConfig? get config => _config;

  LocalTipsRepo(this._storage, this._yurePayment);

  @override
  Future<void> addTip(TipRequest tipRequest) async {
    if (_config == null) {
      throw Exception(
        "PaymentConfig non configuré. Appelez setPaymentConfig() d'abord.",
      );
    }

    try {
      final result = await _yurePayment.processPayment(
        PaymentRequest(
          providerName: tipRequest.providerName,
          amount: tipRequest.amount,
        ),
      );

      if (result.status == PaymentStatus.inProgress) {
        await _storage.addTip(
          Tip(merchantId: _config!.merchantId, amount: tipRequest.amount),
        );
      }
    } catch (e) {
      if (e is YurePaymentException) {
        throw Exception(e.message);
      }
      throw Exception("Erreur lors de paiement du pourboire");
    }
  }

  @override
  Future<List<Tip>> listTips() async {
    return _storage.getTips();
  }
}

class RemoteTipsRepo implements ITipsRepo {
  @override
  Future<void> addTip(TipRequest tipRequest) {
    // Implémentation de la logique pour un ajout sur le serveur
    throw UnimplementedError();
  }

  @override
  Future<List<Tip>> listTips() {
    // Implémentation de la logique pour récupérer dépuis le serveur
    throw UnimplementedError();
  }
}
