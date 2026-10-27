import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/areaModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/medicoAreaModel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/medicoArea.service.dart'
    as medicoAreaService;
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/area.service.dart'
    as areaService;

class AreaPage extends StatefulWidget {
  @override
  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  final areaFormKey = GlobalKey<FormState>();
  List<dynamic> areaListItems = [];
  List<dynamic> areaListSelectedItems = [];

  dynamic obj;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: new Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  new Padding(
                    padding:
                        EdgeInsets.only(bottom: 0, left: 0, right: 20, top: 0),
                    child: new CircularProgressIndicator(),
                  ),
                  new Text('Carregando, aguarde ...'),
                ],
              ),
            ),
          );
        },
      );
    });

    findAllArea().then((value) => {
          medicoAreaService
              .findAllByCurrentMedicoId()
              .then((medicoAreaList) => {
                    for (int i = 0; i < medicoAreaList.length; i++)
                      {
                        setState(() {
                          areaListSelectedItems.add(medicoAreaList[i].area.id);
                        })
                      },
                    Navigator.pop(context),
                  }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Áreas de Atuação',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Container(
          child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: areaFormKey,
              child: Column(
                children: [
                  MultiSelect(
                    titleText: 'Areas',
                    hintText: 'Selecione uma ou mais',
                    dataSource: areaListItems,
                    valueField: 'id',
                    textField: 'nome',
                    searchBoxHintText: 'Pesquisar ...',
                    cancelButtonText: 'Cancelar',
                    saveButtonText: 'Confirmar',
                    selectedOptionsInfoText:
                        'Itens selecionados (toque para remover)',
                    initialValue: areaListSelectedItems,
                    onSaved: (value) {
                      areaListSelectedItems = value;
                      if (value == null) areaListSelectedItems = [];
                    },
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    this._openLoadingDialog(context, 'Salvando, aguarde ...');
                    setState(() {
                      atualizarPatologias(context);
                    });
                  },
                  child: Text(
                    "Salvar",
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Future<void> findAllArea() async {
    var response = await areaService.findAll();

    for (int i = 0; i < response.length; i++) {
      dynamic obj = {'id': response[i].id, 'nome': response[i].nome};

      setState(() {
        areaListItems.add(obj);
      });
    }
  }

  void _openLoadingDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                new Padding(
                  padding:
                      EdgeInsets.only(bottom: 0, left: 0, right: 20, top: 0),
                  child: new CircularProgressIndicator(),
                ),
                new Text(msg),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> atualizarPatologias(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final FormState form = areaFormKey.currentState;

    if (form.validate()) {
      form.save();

      MedicoModel medico = new MedicoModel();
      medico.id = prefs.getString('medico_id');

      List<MedicoAreaModel> medicoAreaList = [];

      for (int i = 0; i < areaListSelectedItems.length; i++) {
        AreaModel area = new AreaModel();
        area.id = areaListSelectedItems[i];

        MedicoAreaModel medicoArea = new MedicoAreaModel();
        medicoArea.medico = medico;
        medicoArea.area = area;

        medicoAreaList.add(medicoArea);
      }

      medicoAreaService
          .save(medicoAreaList)
          .then((value) => {Navigator.pop(context)});
    } else {
      Navigator.pop(context);
    }
  }
}
