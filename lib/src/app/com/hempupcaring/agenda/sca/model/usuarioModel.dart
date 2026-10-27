import 'dart:convert';
import 'dart:typed_data';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/municipioModel.dart';

class UsuarioModel {

  String id;
  String nome;
  String email;
  String cpf;
  String senha;
  String celular;
  Uint8List foto;
  String dataNascimento;
  String genero;
  bool habilitado;
  MunicipioModel municipio;
  bool isRelacionado;

  UsuarioModel({this.id, this.nome, this.email, this.cpf, this.senha, this.celular, this.foto, this.dataNascimento, this.genero, this.habilitado, this.municipio, this.isRelacionado});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nome: utf8.decode(json['nome'].toString().codeUnits),
      email: utf8.decode(json['email'].toString().codeUnits),
      cpf: utf8.decode(json['cpf'].toString().codeUnits),
      senha: utf8.decode(json['senha'].toString().codeUnits),
      celular: utf8.decode(json['celular'].toString().codeUnits),
      foto: json['foto'] != null ? base64.decode(json['foto']) : null,
      dataNascimento: utf8.decode(json['dataNascimento'].toString().codeUnits),
      genero: utf8.decode(json['genero'].toString().codeUnits),
      habilitado: json['habilitado'],
      municipio: json['municipio'] != null ? MunicipioModel.fromJson(json['municipio']) : null,
      isRelacionado: json['isRelacionado']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'senha': senha,
      'celular': celular,
      'foto': foto,
      'dataNascimento': dataNascimento,
      'genero': genero,
      'habilitado': habilitado,
      'municipio': municipio,
      'isRelacionado': isRelacionado
    };
  }

}