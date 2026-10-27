import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';

class MedicoModel {

  String id;
  UsuarioModel usuario;
  String crm;
  String biografia;
  String consultorioBairro;
  String consultorioLogradouro;
  String consultorioNumero;
  String consultorioComplemento;
  String consultorioCep;

  MedicoModel({this.id, this.usuario, this.crm, this.biografia, this.consultorioBairro, this.consultorioLogradouro, this.consultorioNumero, this.consultorioComplemento, this.consultorioCep});

  factory MedicoModel.fromJson(Map<String, dynamic> json) {
    return MedicoModel(
      id: json['id'],
      usuario: UsuarioModel.fromJson(json['usuario']),
      crm: utf8.decode(json['crm'].toString().codeUnits),
      biografia: json['biografia'] != null ? utf8.decode(json['biografia'].toString().codeUnits) : null,
      consultorioBairro: utf8.decode(json['consultorioBairro'].toString().codeUnits),
      consultorioLogradouro: utf8.decode(json['consultorioLogradouro'].toString().codeUnits),
      consultorioNumero: utf8.decode(json['consultorioNumero'].toString().codeUnits),
      consultorioComplemento: utf8.decode(json['consultorioComplemento'].toString().codeUnits),
      consultorioCep: utf8.decode(json['consultorioCep'].toString().codeUnits)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'crm': crm,
      'biografia': biografia,
      'consultorioBairro': consultorioBairro,
      'consultorioLogradouro': consultorioLogradouro,
      'consultorioNumero': consultorioNumero,
      'consultorioComplemento': consultorioComplemento,
      'consultorioCep': consultorioCep
    };
  }

}