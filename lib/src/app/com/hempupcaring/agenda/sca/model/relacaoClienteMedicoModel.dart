import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';

class RelacaoClienteMedicoModel {

  String id;
  ClienteModel cliente;
  MedicoModel medico;

  RelacaoClienteMedicoModel({this.id, this.cliente, this.medico});

  factory RelacaoClienteMedicoModel.fromJson(Map<String, dynamic> json) {
    return RelacaoClienteMedicoModel(
      id: json['id'],
      cliente: ClienteModel.fromJson(json['cliente']),
      medico: MedicoModel.fromJson(json['medico'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'medico': medico
    };
  }

}