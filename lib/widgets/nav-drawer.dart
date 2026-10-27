import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/clienteRelacaoClienteMedico.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/clienteSemRelacaoClienteMedico.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/medicoRelacaoClienteMedico.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/medicoSemRelacaoClienteMedico.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/perfil.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/profissional.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/area.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/patologia.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/list/consulta.page.list.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/list/prescricaoMedicamento.page.list.dart';
import 'package:flutter/material.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/horarioAtendimentoList.page.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/pages/entrar.page.dart';
import 'package:agenda/src/customcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  bool isMedico = false;

  @override
  void initState() {
    super.initState();
    checkIsMedico().then((value) {
      setState(() {
        isMedico = value;
      });
    });
  }

  @override
  Widget build(BuildContext context)  {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Hemp Up Caring Agênda',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: CustomColors.hucTheme,
            ),
          ),
          ListTile(
            title: Text('Perfil'),
            onTap: () => {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => PerfilPage()
                  ),
              ),
            },
          ),
          if (!isMedico)
            ListTile(
              title: Text('Patologias'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => PatologiaPage()
                  )
                )
              },
            ),
          if (isMedico)
            ListTile(
              title: Text('Dados Profissionais'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => ProfissionalPage()
                  )
                )
              },
            ),
          if (isMedico)
            ListTile(
              title: Text('Áreas de Atuação'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => AreaPage()
                  )
                )
              },
            ),
          ListTile(
            title: Text('Consultas'),
            onTap: () => {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (BuildContext context) => ConsultaPageList()
                )
              )
            },
          ),
          if (isMedico) 
            ListTile(
              title: Text('Meus Clientes'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => MedicoRelacaoClienteMedicoPage()
                  )
                )
              },
            ),
          if (isMedico) 
            ListTile(
              title: Text('Clientes'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => MedicoSemRelacaoClienteMedicoPage()
                  )
                )
              },
            ),
          if (!isMedico) 
            ListTile(
              title: Text('Meus Médicos'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => ClienteRelacaoClienteMedicoPage()
                  )
                )
              },
            ),
          if (!isMedico) 
            ListTile(
              title: Text('Médicos'),
              onTap: () => {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (BuildContext context) => ClienteSemRelacaoClienteMedicoPage()
                  )
                )
              },
            ),
          if (isMedico) 
            ListTile(
              title: Text('Horário de Atendimento'),
              onTap: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HorarioAtendimentoListPage(),
                  ),
                ),
              },
            ),
          if (isMedico) 
            ListTile(
              title: Text('Prescrição de Medicamento'),
              onTap: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => PrescricaoMedicamentoPageList(),
                  ),
                ),
              },
            ),
            ListTile(
              title: Text('Sair'),
              onTap: () => {
                clearSharedPreferences(),
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EntrarPage(),
                  ),
                ),
              },
            ),
        ],
      ),
    );
  }

  Future<bool> checkIsMedico() async {
    final prefs = await SharedPreferences.getInstance();

    var tipo = prefs.getString('tipo');
    if (tipo == 'Medico')
      return true;
    else
      return false;
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.clear();
  }

}