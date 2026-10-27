import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/relacaoClienteMedicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/relacaoClienteMedicoFilter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/sca/constantsRelacaoClienteMedico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<List<RelacaoClienteMedicoModel>> findAllByCurrentClienteId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/clientePatologia/findAllByClienteId?clienteId=" + prefs.getString('cliente_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var relacaoClienteMedicoListResponse = response.results;
  List<RelacaoClienteMedicoModel> relacaoClienteMedicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var relacaoClienteMedico = RelacaoClienteMedicoModel.fromJson(relacaoClienteMedicoListResponse[i]);
    relacaoClienteMedicoList.add(relacaoClienteMedico);
  }

  return relacaoClienteMedicoList;
}

Future<List<ClienteModel>> findAllByFilterWithRelacaoMedicoId(RelacaoClienteMedicoFilter filter) async {
  final prefs = await SharedPreferences.getInstance();
  
  filter.medicoId = prefs.getString('medico_id');
  filter.alvo = new ConstantRelacaoClienteMedico().getAlvoCliente();
  
  var body = jsonEncode(filter);

  var url = API_URL + "/relacaoClienteMedico/findAllClienteByFilter";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);
  var response = Response.fromJson(json.decode(retorno.body));

  var clienteListResponse = response.results;
  List<ClienteModel> clienteList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var cliente = ClienteModel.fromJson(clienteListResponse[i]);
    clienteList.add(cliente);
  }

  return clienteList;
}

Future<List<ClienteModel>> findAllByFilterWithOutRelacaoMedicoId(RelacaoClienteMedicoFilter filter) async {
  final prefs = await SharedPreferences.getInstance();
  
  filter.medicoId = prefs.getString('medico_id');
  filter.alvo = new ConstantRelacaoClienteMedico().getAlvoCliente();
  
  var body = jsonEncode(filter);

  var url = API_URL + "/relacaoClienteMedico/findAllClienteWithOutByFilter";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);
  var response = Response.fromJson(json.decode(retorno.body));

  var clienteListResponse = response.results;
  List<ClienteModel> clienteList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var cliente = ClienteModel.fromJson(clienteListResponse[i]);
    clienteList.add(cliente);
  }

  return clienteList;
}

Future<void> deleteByClienteIdAndCurrentMedicoId(clienteId) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/relacaoClienteMedico/deleteByClienteIdAndCurrentMedicoId?clienteId=" + clienteId + "&medicoId=" + prefs.getString('medico_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  await http.delete(Uri.parse(url), headers: headers);
}

Future<void> createByCurrentMedicoId(clienteId) async {
  final prefs = await SharedPreferences.getInstance();

  RelacaoClienteMedicoModel relacaoClienteMedico = new RelacaoClienteMedicoModel();

  ClienteModel clienteModel = new ClienteModel();
  clienteModel.id = clienteId;

  MedicoModel medicoModel = new MedicoModel();
  medicoModel.id = prefs.getString('medico_id');

  relacaoClienteMedico.cliente = clienteModel;
  relacaoClienteMedico.medico = medicoModel;

  var url = API_URL + "/relacaoClienteMedico";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  String body = jsonEncode(relacaoClienteMedico);

  await http.post(Uri.parse(url), headers: headers, body: body);
}

Future<void> createByCurrentClienteId(medicoId) async {
  final prefs = await SharedPreferences.getInstance();

  RelacaoClienteMedicoModel relacaoClienteMedico = new RelacaoClienteMedicoModel();

  ClienteModel clienteModel = new ClienteModel();
  clienteModel.id = prefs.getString('cliente_id');

  MedicoModel medicoModel = new MedicoModel();
  medicoModel.id = medicoId;

  relacaoClienteMedico.cliente = clienteModel;
  relacaoClienteMedico.medico = medicoModel;

  var url = API_URL + "/relacaoClienteMedico";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  String body = jsonEncode(relacaoClienteMedico);

  await http.post(Uri.parse(url), headers: headers, body: body);
}

Future<List<MedicoModel>> findAllByFilterWithOutRelacaoClienteId(RelacaoClienteMedicoFilter filter) async {
  final prefs = await SharedPreferences.getInstance();
  
  filter.clienteId = prefs.getString('cliente_id');
  filter.alvo = new ConstantRelacaoClienteMedico().getAlvoMedico();
  
  var body = jsonEncode(filter);

  var url = API_URL + "/relacaoClienteMedico/findAllMedicoWithOutByFilter";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);
  var response = Response.fromJson(json.decode(retorno.body));

  var medicoListResponse = response.results;
  List<MedicoModel> medicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var medico = MedicoModel.fromJson(medicoListResponse[i]);
    medicoList.add(medico);
  }

  return medicoList;
}

Future<void> deleteByMedicoIdAndCurrentClienteId(medicoId) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/relacaoClienteMedico/deleteByClienteIdAndCurrentMedicoId?clienteId=" + prefs.getString('cliente_id') + "&medicoId=" + medicoId;
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  await http.delete(Uri.parse(url), headers: headers);
}

Future<List<MedicoModel>> findAllByFilterWithRelacaoClienteId(RelacaoClienteMedicoFilter filter) async {
  final prefs = await SharedPreferences.getInstance();
  
  filter.clienteId = prefs.getString('cliente_id');
  filter.alvo = new ConstantRelacaoClienteMedico().getAlvoMedico();
  
  var body = jsonEncode(filter);

  var url = API_URL + "/relacaoClienteMedico/findAllMedicoByFilter";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);
  var response = Response.fromJson(json.decode(retorno.body));

  var medicoListResponse = response.results;
  List<MedicoModel> medicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var medico = MedicoModel.fromJson(medicoListResponse[i]);
    medicoList.add(medico);
  }

  return medicoList;
}