// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BidItemModelAdapter extends TypeAdapter<BidItemModel> {
  @override
  final int typeId = 2;

  @override
  BidItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BidItemModel(
      id: fields[0] as String,
      description: fields[1] as String,
      quantity: fields[2] as int,
      unitPrice: fields[3] as double,
      discountPercent: fields[4] as double,
      taxPercent: fields[5] as double,
      notes: fields[6] as String?,
      unit: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BidItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.discountPercent)
      ..writeByte(5)
      ..write(obj.taxPercent)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
