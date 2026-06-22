// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsultationAdapter extends TypeAdapter<Consultation> {
  @override
  final int typeId = 1;

  @override
  Consultation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Consultation()
      ..id = fields[0] as String
      ..patientId = fields[1] as String
      ..dateHeure = fields[2] as DateTime
      ..motif = fields[3] as String
      ..diagnostic = fields[4] as String
      ..traitement = fields[5] as String
      ..noteMedecin = fields[6] as String
      ..estSynchronisee = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, Consultation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.dateHeure)
      ..writeByte(3)
      ..write(obj.motif)
      ..writeByte(4)
      ..write(obj.diagnostic)
      ..writeByte(5)
      ..write(obj.traitement)
      ..writeByte(6)
      ..write(obj.noteMedecin)
      ..writeByte(7)
      ..write(obj.estSynchronisee);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
