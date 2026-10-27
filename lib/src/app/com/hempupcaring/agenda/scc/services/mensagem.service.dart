import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/mensagem.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> create(Mensagem mensagem) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/mensagem";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  String body = jsonEncode(mensagem);

  await http.post(Uri.parse(url), headers: headers, body: body);
}

Future<List<Mensagem>> findAllByChatId(String chatId) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/mensagem/findAllByChatId?chatId=" + chatId;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var mensagemListResponse = response.results;
  List<Mensagem> mensagemList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var mensagem = Mensagem.fromJson(mensagemListResponse[i]);
    mensagemList.add(mensagem);
  }

  return mensagemList;
}

Future<List<Mensagem>> findAllByChatIdAndIndex(String chatId, int index) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/mensagem/findAllByChatIdAndIndex?chatId=" + chatId + "&index=" + index.toString();
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var mensagemListResponse = response.results;
  List<Mensagem> mensagemList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var mensagem = Mensagem.fromJson(mensagemListResponse[i]);
    mensagemList.add(mensagem);
  }

  return mensagemList;
}