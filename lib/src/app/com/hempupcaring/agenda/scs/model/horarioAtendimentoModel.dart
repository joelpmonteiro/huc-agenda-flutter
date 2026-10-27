import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:intl/intl.dart';

class HorarioAtendimentoModel {
  String id;
  int diaSemana;
  DateTime primeiroHorarioInicio;
  DateTime primeiroHorarioTermino;
  DateTime segundoHorarioInicio;
  DateTime segundoHorarioTermino;
  MedicoModel medico;

  HorarioAtendimentoModel({this.id, this.diaSemana, this.primeiroHorarioInicio, this.primeiroHorarioTermino, this.segundoHorarioInicio, this.segundoHorarioTermino, this.medico});

  factory HorarioAtendimentoModel.fromJson(Map<String, dynamic> json) {
    return HorarioAtendimentoModel(
      id: json['id'],
      diaSemana: json['diaSemana'],
      primeiroHorarioInicio: json['primeiroHorarioInicio'] != null ? DateTime.parse(DateFormat('yyyy-MM-dd ').format(DateTime.now()) + json['primeiroHorarioInicio']) : null,
      primeiroHorarioTermino: json['primeiroHorarioTermino'] != null ? DateTime.parse(DateFormat('yyyy-MM-dd ').format(DateTime.now()) + json['primeiroHorarioTermino']) : null,
      segundoHorarioInicio: json['segundoHorarioInicio'] != null ? DateTime.parse(DateFormat('yyyy-MM-dd ').format(DateTime.now()) + json['segundoHorarioInicio']) : null,
      segundoHorarioTermino: json['segundoHorarioTermino'] != null ? DateTime.parse(DateFormat('yyyy-MM-dd ').format(DateTime.now()) + json['segundoHorarioTermino']) : null,
      medico: json['medico'] != null ? MedicoModel.fromJson(json['medico']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diaSemana': diaSemana,
      'primeiroHorarioInicio': primeiroHorarioInicio,
      'primeiroHorarioTermino': primeiroHorarioTermino,
      'segundoHorarioInicio': segundoHorarioInicio,
      'segundoHorarioTermino': segundoHorarioTermino,
      'medico': medico
    };
  }

}