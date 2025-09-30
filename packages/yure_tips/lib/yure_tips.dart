import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yure_tips/src/service.dart';
import 'package:yure_tips/src/yure_tips_ui.dart';
import 'package:yure_tips/src/repository.dart';

const String _kBoxName = 'tipsBox';

/// Singleton pour gérer les tips et/ou leur UI
class YureTips {
  static YureTips? _instance;

  late final Box<TipHiveModel> _box;

  /// Logique métier des tips (accès aux données, ajout, suppression, etc.)
  late final IBaseYureTips tips;

  /// Interface UI des tips (widgets, affichage, animations, etc.)
  late final IYureTipsUi tipsUI;

  // Constructeur privé pour empêcher l'instanciation directe
  YureTips._();

  /// ⚠️ Initialisation asynchrone obligatoire avant toute utilisation
  ///
  /// Configure Hive, ouvre la box locale et initialise les services et UI.
  static Future<void> init() async {
    if (_instance != null) return;

    final instance = YureTips._();

    final dir = await getApplicationCacheDirectory();
    Hive.init(dir.path);

    instance._box = await Hive.openBox<TipHiveModel>(_kBoxName);

    final localStorage = HiveTipsStorageService(instance._box);

    final repo = LocalTipsRepo(localStorage);

    instance.tips = BaseYureTips(repo);
    instance.tipsUI = YureTipsUI(instance.tips);

    _instance = instance;
  }

  /// Accès synchronisé à l'instance singleton après initialisation
  ///
  /// ⚠️ Appeler [init] avant d'utiliser ce getter, sinon exception.
  static YureTips get instance {
    if (_instance == null) {
      throw Exception("YureTips not initialized. Call YureTips.init() first.");
    }
    return _instance!;
  }
}
