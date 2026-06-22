// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient()
      ..id = fields[0] as String
      ..nom = fields[1] as String
      ..prenom = fields[2] as String
      ..dateNaissance = fields[3] as DateTime
      ..telephone = fields[4] as String
      ..groupeSanguin = fields[5] as String
      ..antecedents = fields[6] as String
      ..statut = fields[7] as String
      ..derniereVisite = fields[8] as DateTime?
      ..estSynchronise = fields[9] as bool;
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.prenom)
      ..writeByte(3)
      ..write(obj.dateNaissance)
      ..writeByte(4)
      ..write(obj.telephone)
      ..writeByte(5)
      ..write(obj.groupeSanguin)
      ..writeByte(6)
      ..write(obj.antecedents)
      ..writeByte(7)
      ..write(obj.statut)
      ..writeByte(8)
      ..write(obj.derniereVisite)
      ..writeByte(9)
      ..write(obj.estSynchronise);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
