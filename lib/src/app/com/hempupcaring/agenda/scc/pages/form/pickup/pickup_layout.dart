import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chamada.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/pickup/pickup_screen.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/chamada.service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final String usuarioId;
  final ChamadaService chamadaService = ChamadaService();

  PickupLayout({
    @required this.scaffold,
    @required this.usuarioId
  });

  @override
  Widget build(BuildContext context) {
    return this.usuarioId != null && this.usuarioId.isNotEmpty ? StreamBuilder<DocumentSnapshot>(
      stream: chamadaService.chamadaStream(uid: usuarioId),
      builder: (context, snapshot) {

        if (snapshot.hasData && snapshot.data.data() != null) {
          Chamada chamada = Chamada.fromMap(snapshot.data.data());

          if (!chamada.hasDialled) {

            return PickupScreen(chamada: chamada);
          } 

          return scaffold;
        }
        return scaffold;
      },
    ) : Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}