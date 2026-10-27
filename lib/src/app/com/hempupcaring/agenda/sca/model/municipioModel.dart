import 'dart:convert';

class MunicipioModel {

  String id;
  String cidade;
  String uf;

  MunicipioModel({this.id, this.cidade, this.uf});

  factory MunicipioModel.fromJson(Map<String, dynamic> json) {
    return MunicipioModel(
      id: json['id'],
      cidade: json['cidade'] != null ? utf8.decode(json['cidade'].toString().codeUnits) : null,
      uf: json['uf'] != null ? utf8.decode(json['uf'].toString().codeUnits) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cidade': cidade,
      'uf': uf
    };
  }

}