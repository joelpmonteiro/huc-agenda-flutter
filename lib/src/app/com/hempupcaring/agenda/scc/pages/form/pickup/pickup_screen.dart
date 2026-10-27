import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chamada.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/chamada.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/chamada.service.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/utils/permissions.dart';
import 'package:flutter/material.dart';

class PickupScreen extends StatelessWidget {

  final Chamada chamada;
  final ChamadaService chamadaService = ChamadaService();

  PickupScreen({
    @required this.chamada,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Em breve ...", style: TextStyle(fontSize: 30)),
            SizedBox(height: 50,),
            Image.network(
              chamada.callerPic,
              height: 150,
              width: 150,
            ),
            SizedBox(height: 15,),
            Text(
              chamada.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            SizedBox(height: 75,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await chamadaService.finalizarChamada(chamada: chamada);
                  }, 
                ),
                SizedBox(width: 25,),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async => await Permissions.cameraAndMicrophonePermissionsGranted() ? Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ChamadaPageForm(chamada: chamada),
                    )
                  ) : {}, 
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}