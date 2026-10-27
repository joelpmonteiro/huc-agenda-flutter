import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'dart:convert';

Future<List<String>> findAllUf() async {
  var url = API_URL + "/municipio/findAllUf";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json; charset=utf-8";
  
  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var ufListResponse = response.results;
  List<String> ufList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var uf = ufListResponse[i];
    ufList.add(uf);
  }

  return ufList;
}

Future<List<String>> findAllCidadeByUf(uf) async {
  var url = API_URL + "/municipio/findAllCidadeByUf?uf=" + uf;
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json; charset=utf-8";
  
  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));

  var cidadeListResponse = response.results;
  List<String> cidadeList = [];
  
  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var cidade = cidadeListResponse[i];
    cidadeList.add(cidade);
  }
  
  return cidadeList;
}