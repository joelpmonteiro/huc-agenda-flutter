import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chat.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Chat> findOrCreateChat(String medicoId, String clienteId) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/chat/findOrCreate";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  Chat chatToFindOrCreate = new Chat();
  chatToFindOrCreate.medico = new MedicoModel();
  chatToFindOrCreate.medico.id = medicoId;
  chatToFindOrCreate.cliente = new ClienteModel();
  chatToFindOrCreate.cliente.id = clienteId;

  String body = jsonEncode(chatToFindOrCreate);

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);
  var response = Response.fromJson(json.decode(retorno.body));
  var chat = Chat.fromJson(response.result);

  return chat;
}