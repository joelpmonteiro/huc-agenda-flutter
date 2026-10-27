import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Response> existsByEmail(email) async {
  var url = API_URL + "/usuario/existsByEmail?email=" + email;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  
  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    return Response.fromJson(json.decode(response.body));
  }
  else {
    throw Exception('Falha ao verificar e-mail');
  }
}

Future<Response> existsByCpf(cpf) async {
  var url = API_URL + "/usuario/existsByCpf?cpf=" + cpf;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  
  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    return Response.fromJson(json.decode(response.body));
  }
  else {
    throw Exception('Falha ao verificar CPF');
  }
}

Future<Response> getTipoUsuario(email) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/usuario/getTipoUsuario?email=" + email;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  final response = await http.get(Uri.parse(url), headers: headers);
  return Response.fromJson(json.decode(response.body));
}

Future<Response> getIdByEmail(email) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/usuario/getIdByEmail?email=" + email;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  final response = await http.get(Uri.parse(url), headers: headers);
  return Response.fromJson(json.decode(response.body));
}

Future<Response> getCurrent() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/usuario/getById?id=" + prefs.getString('id');
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  final response = await http.get(Uri.parse(url), headers: headers);
  return Response.fromJson(json.decode(response.body));
}

Future<void> update(UsuarioModel usuario) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/usuario";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  usuario.id = prefs.getString('id');

  await http.put(Uri.parse(url), headers: headers, body: jsonEncode(usuario));
}

Future<UsuarioModel> findById(String id) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/usuario/getById?id=" + id;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  final retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));
  var usuario = UsuarioModel.fromJson(response.result);

  return usuario;
}