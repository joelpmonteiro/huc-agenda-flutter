import 'dart:convert';
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamento.filter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamento.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> save(PrescricaoMedicamentoModel prescricaoMedicamento) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/prescricaoMedicamento";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  String body = jsonEncode(prescricaoMedicamento);

  if (prescricaoMedicamento.id == null || prescricaoMedicamento.id.toString().trim().isEmpty) {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 500) {
      throw response;
    }
  } else {
    url += '/' + prescricaoMedicamento.id;
    var response = await http.put(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 500) {
      throw response;
    }
  }
}

Future<List<PrescricaoMedicamentoModel>> findAllByfilter(PrescricaoMedicamentoFilter filter) async {
  final prefs = await SharedPreferences.getInstance();

  var body = jsonEncode(filter);

  var url = API_URL + "/prescricaoMedicamento/findAllByFilter";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);

  if (retorno.statusCode == 500) {
    throw retorno;
  }

  var response = Response.fromJson(json.decode(retorno.body));

  var prescricaoMedicamentoListResponse = response.results;
  List<PrescricaoMedicamentoModel> prescricaoMedicamentoList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var prescricaoMedicamento = PrescricaoMedicamentoModel.fromJson(prescricaoMedicamentoListResponse[i]);
    prescricaoMedicamentoList.add(prescricaoMedicamento);
  }

  return prescricaoMedicamentoList;
}

Future<void> delete(String id) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/prescricaoMedicamento/" + id;

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var response = await http.delete(Uri.parse(url), headers: headers);

  if (response.statusCode == 500) {
    throw response;
  }
}