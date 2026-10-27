import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';

class PrescricaoMedicamentoModel {

  String id;
  String nome;
  ClienteModel cliente;
  MedicoModel medico;
  String descricao;
  DateTime dataHoraSolicitacao;
  int status;

  PrescricaoMedicamentoModel({this.id, this.nome, this.cliente, this.medico, this.descricao, this.dataHoraSolicitacao, this.status});

  factory PrescricaoMedicamentoModel.fromJson(Map<String, dynamic> json) {
    return PrescricaoMedicamentoModel(
      id: json['id'],
      nome: json['nome'],
      cliente: json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
      medico: json['medico'] != null ? MedicoModel.fromJson(json['medico']) : null,
      descricao: json['descricao'] != null ? utf8.decode(json['descricao'].toString().codeUnits) : null,
      dataHoraSolicitacao: json['dataHoraSolicitacao'] != null ? DateTime.parse(json['dataHoraSolicitacao']).toLocal() : null,
      status: json['status'] != null ? json['status'] : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cliente': cliente,
      'medico': medico,
      'descricao': descricao,
      'dataHoraSolicitacao': dataHoraSolicitacao != null ? dataHoraSolicitacao.toLocal().toString().split(' ').join('T') + 'Z' : null,
      'status': status
    };
  }

}