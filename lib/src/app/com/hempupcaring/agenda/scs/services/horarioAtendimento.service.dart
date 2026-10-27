import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Response> save(horario) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/horario";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  String body = jsonEncode(horario);
  
  if (horario['id'] == null || horario['id'].toString().trim().isEmpty) {

    var response = await http.post(Uri.parse(url), headers: headers, body: body);

    Response retorno = Response.fromJson(json.decode(response.body));
    retorno.statusCode = response.statusCode.toString();

    return retorno;
  }
  else {
    
    url += '/' + horario['id'];
    var response = await http.put(Uri.parse(url), headers: headers, body: body);
    
    Response retorno = Response();
    retorno.statusCode = '204';
    return retorno;
  }
}

Future<Response> findAllByMedicoId(String medicoId) async {
  final prefs = await SharedPreferences.getInstance();
  
  String url = API_URL + "/horario/findAllByMedicoId?medicoId=" + medicoId.toString();
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  var response = await http.get(Uri.parse(url), headers: headers);
  return Response.fromJson(json.decode(response.body));
  
}

Future<Response> deleteById(String id) async {
  final prefs = await SharedPreferences.getInstance();
  
  String url = API_URL + "/horario/" + id;
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');
  
  await http.delete(Uri.parse(url), headers: headers);
  return null;
}