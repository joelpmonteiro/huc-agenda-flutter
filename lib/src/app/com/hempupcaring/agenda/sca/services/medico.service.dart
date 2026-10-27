import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Response> save(medico) async {
  var url = API_URL + "/medico";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  
  String body = jsonEncode(medico);

  if (medico['id'] == null) {
    var response = await http.post(Uri.parse(url), headers: headers, body: body);
    return Response.fromJson(json.decode(response.body));
  }
  else {
    var response = await http.put(Uri.parse(url), headers: headers, body: body);
    return Response.fromJson(json.decode(response.body));
  }
}

Future<Response> existsByCrm(crm) async {
  var url = API_URL + "/medico/existsByCrm?crm=" + crm;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  
  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    return Response.fromJson(json.decode(response.body));
  }
  else {
    throw Exception('Falha ao verificar CRM');
  }
}

Future<Response> findOneByUsuarioEmail(usuarioEmail) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/medico/findOneByUsuarioEmail?usuarioEmail=" + usuarioEmail;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  final response = await http.get(Uri.parse(url), headers: headers);
  return Response.fromJson(json.decode(response.body));
}

Future<Response> findAllMedicoByUsuarioMunicipio() async {
  final prefs = await SharedPreferences.getInstance();
  
  var url = API_URL + "/medico/findAllByUsuarioMunicipio?clienteId=" + prefs.getString('cliente_id');

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  final response = await http.get(Uri.parse(url), headers: headers);
  Response teste = Response.fromJson(json.decode(response.body));
  
  return teste;
}

Future<void> atualizarDadosProfissionais(MedicoModel medico) async {
  final prefs = await SharedPreferences.getInstance();

  medico.id = prefs.getString('medico_id');
  UsuarioModel usuario = new UsuarioModel();
  usuario.id = prefs.getString('id');
  medico.usuario = usuario;

  var url = API_URL + "/medico";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  await http.put(Uri.parse(url), headers: headers, body: json.encode(medico));
}

Future<MedicoModel> getCurrent() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/medico/getById?id=" + prefs.getString('medico_id');
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  MedicoModel medico = MedicoModel.fromJson(response.result);

  return medico;
}

Future<List<MedicoModel>> findAllNaoRelacionadoByCurrentClienteId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/medico/findAllMedicoNaoRelacionadoByClienteId?clienteId=" + prefs.getString('cliente_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var relacaoClienteMedicoListResponse = response.results;
  List<MedicoModel> relacaoClienteMedicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var relacaoClienteMedico = MedicoModel.fromJson(relacaoClienteMedicoListResponse[i]);
    relacaoClienteMedicoList.add(relacaoClienteMedico);
  }

  return relacaoClienteMedicoList;
}

Future<List<MedicoModel>> findAllRelacionadoByCurrentClienteId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/medico/findAllMedicoRelacionadoByClienteId?clienteId=" + prefs.getString('cliente_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var relacaoClienteMedicoListResponse = response.results;
  List<MedicoModel> relacaoClienteMedicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var relacaoClienteMedico = MedicoModel.fromJson(relacaoClienteMedicoListResponse[i]);
    relacaoClienteMedicoList.add(relacaoClienteMedico);
  }

  return relacaoClienteMedicoList;
}

Future<List<MedicoModel>> findAll() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/medico";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var medicoListResponse = response.results;
  List<MedicoModel> medicoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var medico = MedicoModel.fromJson(medicoListResponse[i]);
    medicoList.add(medico);
  }

  return medicoList;
}

Future<MedicoModel> findById(String id) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/medico/getById?id=" + id;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  final retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));
  var medico = MedicoModel.fromJson(response.result);

  return medico;
}