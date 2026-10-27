import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/patologiaModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<PatologiaModel>> findAll() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/patologia/findAll";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));
  
  var patologiaListResponse = response.results;
  List<PatologiaModel> patologiaList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var patologia = PatologiaModel.fromJson(patologiaListResponse[i]);
    patologiaList.add(patologia);
  }
  
  return patologiaList;
}