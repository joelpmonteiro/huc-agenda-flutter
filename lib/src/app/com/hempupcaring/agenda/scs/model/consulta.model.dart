import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/horarioAtendimentoModel.dart';

class ConsultaModel {

  String id;
  DateTime dataHoraSolicitacao;
  DateTime dataHoraMarcada;
  int status;
  DateTime dataHoraInicio;
  DateTime dataHoraTermino;
  String observacao;
  ClienteModel cliente;
  HorarioAtendimentoModel horario;

  ConsultaModel({this.id, this.dataHoraSolicitacao, this.dataHoraMarcada, this.status, this.dataHoraInicio, this.dataHoraTermino, this.observacao, this.cliente, this.horario});

  factory ConsultaModel.fromJson(Map<String, dynamic> json) {
    return ConsultaModel(
      id: json['id'],
      dataHoraSolicitacao: json['dataHoraSolicitacao'] != null ? DateTime.parse(json['dataHoraSolicitacao']).toLocal() : null,
      dataHoraMarcada: json['dataHoraMarcada'] != null ? DateTime.parse(json['dataHoraMarcada']).toLocal() : null,
      status: json['status'],
      dataHoraInicio: json['dataHoraInicio'] != null ? DateTime.parse(json['dataHoraInicio']).toLocal() : null,
      dataHoraTermino: json['dataHoraTermino'] != null ? DateTime.parse(json['dataHoraTermino']).toLocal() : null,
      observacao: json['observacao'] != null ? utf8.decode(json['observacao'].toString().codeUnits) : null,
      cliente: json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      horario: json['horario'] != null ? HorarioAtendimentoModel.fromJson(json['horario']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataHoraSolicitacao': dataHoraSolicitacao,
      'dataHoraMarcada': dataHoraMarcada,
      'status': status,
      'dataHoraInicio': dataHoraInicio,
      'dataHoraTermino': dataHoraTermino,
      'observacao': observacao,
      'cliente': cliente,
      'horario': horario
    };
  }

}