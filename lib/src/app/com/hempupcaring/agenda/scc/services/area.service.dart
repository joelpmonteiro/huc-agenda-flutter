import 'dart:convert';

import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/areaModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<AreaModel>> findAll() async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/area/findAll";
  
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.get(Uri.parse(url), headers: headers);
  var response = Response.fromJson(json.decode(retorno.body));
  
  var areaListResponse = response.results;
  List<AreaModel> areaList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var patologia = AreaModel.fromJson(areaListResponse[i]);
    areaList.add(patologia);
  }
  
  return areaList;
}