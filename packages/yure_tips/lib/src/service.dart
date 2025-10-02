import 'package:yure_tips/core/models/tip.dart';
import 'package:hive/hive.dart';

abstract class ILocalTipsStorageService {
  Future<void> addTip(Tip tip);
  Future<List<Tip>> getTips();
}

class HiveTipsStorageService implements ILocalTipsStorageService {
  final Box<TipHiveModel> _tipBox;

  HiveTipsStorageService(this._tipBox);

  @override
  Future<void> addTip(Tip tip) async {
    await _tipBox.add(TipHiveModel.fromTip(tip));
  }

  @override
  Future<List<Tip>> getTips() async {
    return _tipBox.values.map((e) => e.toTip()).toList();
  }
}

@HiveType(typeId: 1)
class TipHiveModel {
  @HiveField(0)
  final String merchantId;

  @HiveField(1)
  final int amount;

  TipHiveModel({required this.merchantId, required this.amount});

  factory TipHiveModel.fromTip(Tip tip) {
    return TipHiveModel(merchantId: tip.merchantId, amount: tip.amount);
  }

  Tip toTip() {
    return Tip(merchantId: merchantId, amount: amount);
  }
}

class TipHiveModelAdapter extends TypeAdapter<TipHiveModel> {
  @override
  final int typeId = 1;

  @override
  TipHiveModel read(BinaryReader reader) {
    final merchantId = reader.readString();
    final amount = reader.readInt();
    return TipHiveModel(merchantId: merchantId, amount: amount);
  }

  @override
  void write(BinaryWriter writer, TipHiveModel obj) {
    writer.writeString(obj.merchantId);
    writer.writeInt(obj.amount);
  }
}
