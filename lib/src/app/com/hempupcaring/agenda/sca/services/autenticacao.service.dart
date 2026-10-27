import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/autenticacaoResponse.dart';
import 'dart:convert';

Future<AutenticacaoResponse> autenticar(email, senha) async {
  var url = API_URL + "/authenticate";
  Map<String, String> headers = new Map<String, String>();
  headers["Content-Type"] = "application/json";
  
  var autenticacao = {
    "username": email,
    "password": senha
  };

  String body = jsonEncode(autenticacao);
  
  var requestResponse = await http.post(Uri.parse(url), headers: headers, body: body);
  
  AutenticacaoResponse autenticacaoResponse = new AutenticacaoResponse(
    statusCode: requestResponse.statusCode,
    token: requestResponse.statusCode == 200 ? json.decode(requestResponse.body)["token"] : null
  );

  return autenticacaoResponse;
}