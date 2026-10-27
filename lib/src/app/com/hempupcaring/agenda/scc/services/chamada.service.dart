import 'package:agenda/configs/agora_configs.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/constants/chamada.constant.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chamada.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/constantsAPI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:agenda/src/app/com/hempupcaring/agenda/response.dart';
import 'dart:convert';

class ChamadaService {

  final CollectionReference chamadaCollection = FirebaseFirestore.instance.collection(CHAMADA_COLLECTION);

  Stream<DocumentSnapshot> chamadaStream({String uid}) => chamadaCollection.doc(uid).snapshots();

  Future<String> gerarToken(String channelName, String uId) async {
    final prefs = await SharedPreferences.getInstance();

    var url = API_URL + "/agora/gerarToken?appId=" + APP_ID + "&channelName=" + channelName + "&uId=" + uId;

    Map<String, String> headers = new Map<String, String>();
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = "Bearer " + prefs.getString('token');

    var retorno = await http.get(Uri.parse(url), headers: headers);
    var response = Response.fromJson(json.decode(retorno.body));

    return response.result;
  }

  Future<bool> fazerChamada({Chamada chamada}) async {

    try {

      chamada.hasDialled = true;
      Map<String, dynamic> hasDialledMap = chamada.toMap(chamada);

      chamada.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = chamada.toMap(chamada);

      await chamadaCollection.doc(chamada.callerId).set(hasDialledMap);
      await chamadaCollection.doc(chamada.receiverId).set(hasNotDialledMap);

      return true;
    } catch (e) {

      print(e);
      return false;
    }
  }

  Future<bool> finalizarChamada({Chamada chamada}) async {

    try {

      await chamadaCollection.doc(chamada.callerId).delete();
      await chamadaCollection.doc(chamada.receiverId).delete();

      return true;
    } catch (e) {
      
      print(e);
      return false;
    }
  }

}