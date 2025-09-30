import 'package:yure_tips/core/models/tip.dart';
import 'package:yure_tips/src/service.dart';

abstract class ITipsRepo {
  Future<void> addTip(Tip tip);
  Future<List<Tip>> listTips();
}

class LocalTipsRepo implements ITipsRepo {
  final ILocalTipsStorageService _storage;

  LocalTipsRepo(this._storage);

  @override
  Future<void> addTip(Tip tip) async {
    _storage.addTip(tip);
  }

  @override
  Future<List<Tip>> listTips() async {
    return _storage.getTips();
  }
}

class RemoteTipsRepo implements ITipsRepo {
  @override
  Future<void> addTip(Tip tip) {
    // TODO: Implémentation de la logique pour un ajout sur le serveur
    throw UnimplementedError();
  }

  @override
  Future<List<Tip>> listTips() {
    // TODO: Implémentation de la logique pour récupérer dépuis le serveur
    throw UnimplementedError();
  }
}
