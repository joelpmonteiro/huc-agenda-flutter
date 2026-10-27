import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/clientePatologiaModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> save(List<ClientePatologiaModel> clientePatologiaList) async {
  final prefs = await SharedPreferences.getInstance();

  var body;

  if (clientePatologiaList != null && clientePatologiaList.length > 0) {
    body = json.encode(clientePatologiaList);
  }
  else {
    body = prefs.getString('cliente_id');
  }

  var url = API_URL + "/clientePatologia";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  await http.post(Uri.parse(url), headers: headers, body: body);
}

Future<List<ClientePatologiaModel>> findAllByCurrentClienteId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/clientePatologia/findAllByClienteId?clienteId=" + prefs.getString('cliente_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var clientePatologiaListResponse = response.results;
  List<ClientePatologiaModel> clientePatologiaList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var clientePatologia = ClientePatologiaModel.fromJson(clientePatologiaListResponse[i]);
    clientePatologiaList.add(clientePatologia);
  }

  return clientePatologiaList;
}