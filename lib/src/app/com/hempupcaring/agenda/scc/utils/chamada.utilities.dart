import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chamada.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/chamada.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/chamada.service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChamadaUtilities {

  static ChamadaService chamadaService = ChamadaService();

  static Future<void> dial({UsuarioModel usuarioRemetente, UsuarioModel usuarioDestinatario, context}) async {

    final prefs = await SharedPreferences.getInstance();

    List<String> channelSubId = [];
    channelSubId.add(usuarioRemetente.id.substring(0, 7));
    channelSubId.add(usuarioDestinatario.id.substring(0, 7));
    channelSubId.sort();

    Chamada chamada = Chamada(
      callerId: usuarioRemetente.id,
      callerName: usuarioRemetente.nome,
      callerPic: null,
      receiverId: usuarioDestinatario.id,
      receiverName: usuarioDestinatario.nome,
      receiverPic: null,
      channelId: channelSubId.join()
    );

    bool chamadaFeita = await chamadaService.fazerChamada(chamada: chamada);

    chamada.hasDialled = true;

    if (chamadaFeita) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ChamadaPageForm(chamada: chamada, usuarioId: prefs.getString('id'),))
      );
    }
  }

}