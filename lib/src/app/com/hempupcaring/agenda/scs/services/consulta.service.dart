import 'dart:convert';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consulta.filter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consulta.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> save(consulta) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/consulta";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  String body = jsonEncode(consulta);

  if (consulta['id'] == null || consulta['id'].toString().trim().isEmpty) {
    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 500) {
      throw response;
    }
  } else {
    url += '/' + consulta['id'];
    var response = await http.put(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 500) {
      throw response;
    }
  }
}

Future<void> remarcar(consulta) async {
  final prefs = await SharedPreferences.getInstance();
  var url = API_URL + "/consulta/remarcar";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  String body = jsonEncode(consulta);

  var response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 500) {
    throw response;
  }
}

Future<List<ConsultaModel>> findAllByfilter(ConsultaFilter filter) async {
  final prefs = await SharedPreferences.getInstance();

  var body = jsonEncode(filter);

  var url = API_URL + "/consulta/findAllByfilter";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var retorno = await http.post(Uri.parse(url), headers: headers, body: body);

  if (retorno.statusCode == 500) {
    throw retorno;
  }

  var response = Response.fromJson(json.decode(retorno.body));

  var consultaListResponse = response.results;
  List<ConsultaModel> consultaList = [];

  for (var i = 0; i < response.metadata.resultSet.count; i++) {
    var consulta = ConsultaModel.fromJson(consultaListResponse[i]);
    consultaList.add(consulta);
  }

  return consultaList;
}

Future<void> updateStatus(String id, int status) async {
  final prefs = await SharedPreferences.getInstance();

  ConsultaModel consulta = new ConsultaModel();
  consulta.id = id;
  consulta.status = status;

  var body = jsonEncode(consulta);

  var url = API_URL + "/consulta/updateStatus";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 500) {
    throw response;
  }
}

Future<void> delete(String id) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/consulta/" + id;

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var response = await http.delete(Uri.parse(url), headers: headers);

  if (response.statusCode == 500) {
    throw response;
  }
}

Future<void> comecar(ConsultaModel consulta) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/consulta/comecar";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var consultaToSave = {
    'id': consulta.id,
    'medico': {'id': consulta.horario.medico.id},
    'cliente': {'id': consulta.cliente.id},
    'dataMarcada': null,
    'horarioMarcado': null,
    'status': consulta.status,
    'observacao': consulta.observacao
  };

  String body = jsonEncode(consultaToSave);

  var response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 500) {
    throw response;
  }
}

Future<void> finalizar(ConsultaModel consulta) async {
  final prefs = await SharedPreferences.getInstance();

  var url = API_URL + "/consulta/finalizar";

  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  headers["Authorization"] = "Bearer " + prefs.getString('token');

  var consultaToSave = {
    'id': consulta.id,
    'medico': {'id': consulta.horario.medico.id},
    'cliente': {'id': consulta.cliente.id},
    'dataMarcada': null,
    'horarioMarcado': null,
    'status': consulta.status,
    'observacao': consulta.observacao
  };

  String body = jsonEncode(consultaToSave);

  var response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 500) {
    throw response;
  }
}
