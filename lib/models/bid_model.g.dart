// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BidModelAdapter extends TypeAdapter<BidModel> {
  @override
  final int typeId = 1;

  @override
  BidModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BidModel(
      id: fields[0] as String,
      clientName: fields[1] as String,
      projectName: fields[2] as String,
      projectType: fields[3] as String?,
      clientEmail: fields[4] as String?,
      clientPhone: fields[5] as String?,
      clientAddress: fields[6] as String?,
      notes: fields[7] as String?,
      items: (fields[8] as List).cast<BidItemModel>(),
      status: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime?,
      submittedAt: fields[12] as DateTime?,
      approvedAt: fields[13] as DateTime?,
      approvedBy: fields[14] as String?,
      rejectionReason: fields[15] as String?,
      isSynced: fields[16] as bool,
      userId: fields[17] as String?,
      serverBidId: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BidModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.projectName)
      ..writeByte(3)
      ..write(obj.projectType)
      ..writeByte(4)
      ..write(obj.clientEmail)
      ..writeByte(5)
      ..write(obj.clientPhone)
      ..writeByte(6)
      ..write(obj.clientAddress)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.items)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.submittedAt)
      ..writeByte(13)
      ..write(obj.approvedAt)
      ..writeByte(14)
      ..write(obj.approvedBy)
      ..writeByte(15)
      ..write(obj.rejectionReason)
      ..writeByte(16)
      ..write(obj.isSynced)
      ..writeByte(17)
      ..write(obj.userId)
      ..writeByte(18)
      ..write(obj.serverBidId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
