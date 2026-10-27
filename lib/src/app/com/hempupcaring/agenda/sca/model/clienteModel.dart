import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/fichaAnamneseModel.dart';

class ClienteModel {

  String id;
  UsuarioModel usuario;
  int tipo;
  FichaAnamneseModel fichaAnamnese;

  ClienteModel({this.id, this.usuario, this.tipo, this.fichaAnamnese});

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'],
      usuario: UsuarioModel.fromJson(json['usuario']),
      tipo: json['tipo'],
      fichaAnamnese: json['fichaAnamnese'] != null ? FichaAnamneseModel.fromJson(json['fichaAnamnese']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'tipo': tipo,
      'fichaAnamnese': fichaAnamnese
    };
  }

}