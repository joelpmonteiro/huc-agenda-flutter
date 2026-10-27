import 'dart:convert';

class AreaModel {

  String id;
  String nome;

  AreaModel({this.id, this.nome});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'],
      nome: utf8.decode(json['nome'].toString().codeUnits)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome
    };
  }

}