import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/patologiaModel.dart';

class ClientePatologiaModel {

  String id;
  ClienteModel cliente;
  PatologiaModel patologia;

  ClientePatologiaModel({this.id, this.cliente, this.patologia});

  factory ClientePatologiaModel.fromJson(Map<String, dynamic> json) {
    return ClientePatologiaModel(
      id: json['id'],
      cliente: ClienteModel.fromJson(json['cliente']),
      patologia: PatologiaModel.fromJson(json['patologia'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'patologia': patologia
    };
  }

}