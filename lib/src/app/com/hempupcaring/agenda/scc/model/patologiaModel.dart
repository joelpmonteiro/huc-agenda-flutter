import 'dart:convert';

class PatologiaModel {

  String id;
  String nome;

  PatologiaModel({this.id, this.nome});

  factory PatologiaModel.fromJson(Map<String, dynamic> json) {
    return PatologiaModel(
      id : json['id'],
      nome : utf8.decode(json['nome'].toString().codeUnits)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome
    };
  }

}