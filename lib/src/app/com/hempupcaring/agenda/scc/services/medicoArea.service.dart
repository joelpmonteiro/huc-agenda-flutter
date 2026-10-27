import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/medicoAreaModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<void> save(List<MedicoAreaModel> medicoAreaList) async {
  final prefs = await SharedPreferences.getInstance();

  var body;

  if (medicoAreaList != null && medicoAreaList.length > 0) {
    body = json.encode(medicoAreaList);
  }
  else {
    body = prefs.getString('medico_id');
  }

  var url = API_URL + "/medicoArea";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  await http.post(Uri.parse(url), headers: headers, body: body);
}

Future<List<MedicoAreaModel>> findAllByCurrentMedicoId() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/medicoArea/findAllByMedicoId?medicoId=" + prefs.getString('medico_id');
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var medicoAreaListResponse = response.results;
  List<MedicoAreaModel> medicoAreaList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var clientePatologia = MedicoAreaModel.fromJson(medicoAreaListResponse[i]);
    medicoAreaList.add(clientePatologia);
  }

  return medicoAreaList;
}