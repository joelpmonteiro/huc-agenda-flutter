import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chat.model.dart';

class Mensagem {

  String id;
  String texto;
  DateTime dataHora;
  bool isExcluida;
  Chat chat;
  int index;
  UsuarioModel usuarioDestinatario;
  UsuarioModel usuarioRemetente;

  Mensagem({this.id, this.texto, this.dataHora, this.isExcluida, this.chat, this.index, this.usuarioDestinatario, this.usuarioRemetente});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'],
      texto: utf8.decode(json['texto'].toString().codeUnits),
      usuarioDestinatario: json['usuarioDestinatario'] != null ? UsuarioModel.fromJson(json['usuarioDestinatario']) : null,
      usuarioRemetente: json['usuarioRemetente'] != null ? UsuarioModel.fromJson(json['usuarioRemetente']) : null,
      chat: json['chat'] != null ? Chat.fromJson(json['chat']) : null,
      index: json['index'],
      dataHora: json['dataHora'] != null ? DateTime.parse(json['dataHora']).toLocal() : null,
      isExcluida: json['isExcluida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'isExcluida': isExcluida,
      'chat': chat,
      'index': null,
      'usuarioDestinatario': usuarioDestinatario,
      'usuarioRemetente': usuarioRemetente,
      'dataHora': dataHora != null ? dataHora.toLocal().toString().split(' ').join('T') + 'Z' : null
    };
  }

}