import 'dart:convert';

class RelacaoClienteMedicoFilter {

  String usuarioNome;
  String usuarioCpf;
  String usuarioGenero;
  String usuarioDataNascInicio;
  String usuarioDataNascFim;
  String medicoCrm;
  String medicoId;
  String clienteId;
  int alvo;

  RelacaoClienteMedicoFilter({this.usuarioNome, this.usuarioCpf, this.usuarioGenero, this.usuarioDataNascInicio, this.usuarioDataNascFim, this.medicoCrm, this.medicoId, this.clienteId, this.alvo});

  factory RelacaoClienteMedicoFilter.fromJson(Map<String, dynamic> json) {
    return RelacaoClienteMedicoFilter(
      usuarioNome: utf8.decode(json['usuarioNome'].toString().codeUnits),
      usuarioCpf: utf8.decode(json['usuarioCpf'].toString().codeUnits),
      usuarioGenero: utf8.decode(json['usuarioGenero'].toString().codeUnits),
      usuarioDataNascInicio: utf8.decode(json['usuarioDataNascInicio'].toString().codeUnits),
      usuarioDataNascFim: utf8.decode(json['usuarioDataNascFim'].toString().codeUnits),
      medicoCrm: utf8.decode(json['medicoCrm'].toString().codeUnits),
      medicoId: utf8.decode(json['medicoId'].toString().codeUnits),
      clienteId: utf8.decode(json['clienteId'].toString().codeUnits),
      alvo: json['alvo']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioNome': usuarioNome,
      'usuarioCpf': usuarioCpf,
      'usuarioGenero': usuarioGenero,
      'usuarioDataNascInicio': usuarioDataNascInicio,
      'usuarioDataNascFim': usuarioDataNascFim,
      'medicoCrm': medicoCrm,
      'medicoId': medicoId,
      'clienteId': clienteId,
      'alvo': alvo
    };
  }

}