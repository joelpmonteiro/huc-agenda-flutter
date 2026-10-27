import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Response> save(cliente) async {
  var url = API_URL + "/cliente";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  
  String body = jsonEncode(cliente);

  if (cliente['id'] == null) {
    var response = await http.post(Uri.parse(url), headers: headers, body: body);
    return Response.fromJson(json.decode(response.body));
  }
  else {
    var response = await http.put(Uri.parse(url), headers: headers, body: body);
    return Response.fromJson(json.decode(response.body));
  }
}

Future<Response> findOneByUsuarioEmail(usuarioEmail) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/cliente/findOneByUsuarioEmail?usuarioEmail=" + usuarioEmail;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  final response = await http.get(Uri.parse(url), headers: headers);
  return Response.fromJson(json.decode(response.body));
}

Future<List<ClienteModel>> findAllRelacionadoByCurrentMedicoId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/cliente/findAllClienteRelacionadoByMedicoId?medicoId=" + prefs.getString('medico_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var relacaoClienteMedicoListResponse = response.results;
  List<ClienteModel> relacaoClienteMedicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var relacaoClienteMedico = ClienteModel.fromJson(relacaoClienteMedicoListResponse[i]);
    relacaoClienteMedicoList.add(relacaoClienteMedico);
  }

  return relacaoClienteMedicoList;
}

Future<List<ClienteModel>> findAllNaoRelacionadoByCurrentMedicoId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/cliente/findAllClienteNaoRelacionadoByMedicoId?medicoId=" + prefs.getString('medico_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var relacaoClienteMedicoListResponse = response.results;
  List<ClienteModel> relacaoClienteMedicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var relacaoClienteMedico = ClienteModel.fromJson(relacaoClienteMedicoListResponse[i]);
    relacaoClienteMedicoList.add(relacaoClienteMedico);
  }

  return relacaoClienteMedicoList;
}

Future<ClienteModel> findOneByCurrentClienteId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/cliente/" + prefs.getString('cliente_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  ClienteModel cliente = ClienteModel.fromJson(response.result);

  return cliente;
}

Future<ClienteModel> findById(String id) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/cliente/" + id;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  final retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));
  var cliente = ClienteModel.fromJson(response.result);

  return cliente;
}