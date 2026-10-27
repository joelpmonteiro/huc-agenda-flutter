import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';

class Chat {

  String id;
  MedicoModel medico;
  ClienteModel cliente;

  Chat({this.id, this.medico, this.cliente});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      medico: json['medico'] != null ? MedicoModel.fromJson(json['medico']) : null,
      cliente: json['cliente'] != null ? ClienteModel.fromJson(json['cliente']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medico': medico,
      'cliente': cliente
    };
  }

}