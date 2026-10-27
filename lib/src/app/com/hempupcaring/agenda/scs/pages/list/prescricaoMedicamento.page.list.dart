import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/mensagem.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamento.filter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/prescricaoMedicamento.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/form/prescricaoMedicamento.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/form/prescricaoMedicamentoFilter.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/scs/constantsPrescricaoMedicamento.dart';
import 'package:agenda/widgets/expansion-panel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/services/prescricaoMedicamento.service.dart' as prescricaoMedicamentoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart' as dataUtil;

class PrescricaoMedicamentoPageList extends StatefulWidget {
  @override
  _PrescricaoMedicamentoPageListState createState() => _PrescricaoMedicamentoPageListState();
}

class _PrescricaoMedicamentoPageListState extends State<PrescricaoMedicamentoPageList> {
  final prefs = SharedPreferences.getInstance();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ListView prescricaoMedicamentoPanelList;
  PrescricaoMedicamentoFilter prescricaoMedicamentoFilter = null;
  List<CustomExpansionPanel> prescricaoMedicamentoPainelExpansivoList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      prefs.then((prefs) => {
        prescricaoMedicamentoFilter = new PrescricaoMedicamentoFilter(),
        prescricaoMedicamentoFilter.medico = new MedicoModel(),
        prescricaoMedicamentoFilter.medico.id = prefs.getString('medico_id'),
        findAllByfilter(prescricaoMedicamentoFilter)
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    prescricaoMedicamentoPanelList = ListView.builder(
      itemCount: prescricaoMedicamentoPainelExpansivoList.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpansionPanelList(
          animationDuration: Duration(milliseconds: 1000),
          dividerColor: Colors.red,
          elevation: 1,
          children: [
            ExpansionPanel(
              body: Container(
                  padding: EdgeInsets.all(10),
                  child: prescricaoMedicamentoPainelExpansivoList[index].body),
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: prescricaoMedicamentoPainelExpansivoList[index].header,
                );
              },
              isExpanded: prescricaoMedicamentoPainelExpansivoList[index].expanded,
            )
          ],
          expansionCallback: (int item, bool status) {
            setState(() {
              prescricaoMedicamentoPainelExpansivoList[index].expanded =
                  !prescricaoMedicamentoPainelExpansivoList[index].expanded;
            });
          },
        );
      },
    );

    WillPopScope willPopScope = WillPopScope(
      child: Scaffold(
        drawer: NavDrawer(),
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Prescrição de Medicamento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          actions: <Widget>[
            IconButton(
              iconSize: 40,
              icon: Icon(
                Icons.filter_alt,
              ),
              tooltip: 'Filtrar',
              onPressed: () {
                setState(() {
                  this.openPrescricaoMedicamentoFilter(context);
                });
              },
            ),
          ],
        ),
        body: prescricaoMedicamentoPanelList,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            this.openPrescricaoMedicamentoForm(context, true, null);
          },
          child: new Icon(Icons.add),
        ),
      ),
    );

    return willPopScope;
  }

  Future<void> openPrescricaoMedicamentoFilter(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return SingleChildScrollView(
          child: AlertDialog(
              title: Text("Filtrar"),
              content: PrescricaoMedicamentoFilterPageForm(this.findAllByfilter)),
        );
      },
    );
  }

  Future<void> openPrescricaoMedicamentoForm(
      BuildContext context, bool isNovoRegistro, PrescricaoMedicamentoModel prescricaoMedicamento) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: isNovoRegistro
                ? Text("Nova Prescrição")
                : Text("Editar Prescrição"),
            content: PrescricaoMedicamentoPageForm(isNovoRegistro, prescricaoMedicamento),
          ),
        );
      },
    ).then((value) {});
  }

  Future<void> findAllByfilter(PrescricaoMedicamentoFilter prescricaoMedicamentoFilter) async {
    openLoadingDialog(this.context);
    prescricaoMedicamentoService.findAllByfilter(prescricaoMedicamentoFilter).then((prescricaoMedicamentoList) => {
      setState(() {
        montarPrescricaoMedicamentoList(prescricaoMedicamentoList).then((list) => {
          this.prescricaoMedicamentoPainelExpansivoList = list,
          Navigator.pop(context)
        });
      })
    });
  }

  void openLoadingDialog(BuildContext context) {
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
                new Text('Carregando, aguarde ...'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<CustomExpansionPanel>> montarPrescricaoMedicamentoList(List<PrescricaoMedicamentoModel> prescricaoMedicamentoList) async {
    List<CustomExpansionPanel> prescricaoMedicamentoPainelExpansivoList = [];
    final prefs = await SharedPreferences.getInstance();
    CustomExpansionPanel prescricaoMedicamentoPainelExpansivo;
    Color headerColor;

    for (var prescricaoMedicamento in prescricaoMedicamentoList) {
      if (prescricaoMedicamento.status == ConstantsPrescricaoMedicamento().STATUS_SOLICITADO) {
        headerColor = Colors.blue;
      }
      else if (prescricaoMedicamento.status == ConstantsPrescricaoMedicamento().STATUS_APROVADO) {
        headerColor = Colors.green;
      }
      else if (prescricaoMedicamento.status == ConstantsPrescricaoMedicamento().STATUS_REPROVADO) {
        headerColor = Colors.red;
      }

      prescricaoMedicamentoPainelExpansivo = CustomExpansionPanel(
        false,
        Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    prescricaoMedicamento.nome,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    )
                  ),
                ),
                Icon(
                  Icons.circle_rounded,
                  color: headerColor,
                  size: 16.0,
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    prescricaoMedicamento.cliente.usuario.nome
                  ),
                ),
                Text(
                  dataUtil.montarData(
                    prescricaoMedicamento.dataHoraSolicitacao.day,
                    prescricaoMedicamento.dataHoraSolicitacao.month,
                    prescricaoMedicamento.dataHoraSolicitacao.year,
                    "dd/MM/yyyy"
                  ) + " " +
                  dataUtil.montarHorario(
                    prescricaoMedicamento.dataHoraSolicitacao.hour,
                    prescricaoMedicamento.dataHoraSolicitacao.minute,
                    "hh:mm"
                  )
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prescricaoMedicamento.descricao != null)
              Container(
                child: Text(prescricaoMedicamento.descricao),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chat_outlined,
                    color: Colors.blue,
                  ),
                  tooltip: 'Chat',
                  onPressed: () {
                    setState(() {
                      this.openConfirmarChat(
                          context,
                          prescricaoMedicamento.cliente.id,
                          prefs.getString("medico_id"),
                          prescricaoMedicamento.cliente.usuario.nome);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.yellow,
                  ),
                  tooltip: 'Editar',
                  onPressed: () {
                    setState(() {
                      this.openConfirmarEditar(context, prescricaoMedicamento,
                          prescricaoMedicamento.cliente.usuario.nome);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Deletar',
                  onPressed: () {
                    setState(() {
                      this.openConfirmarDeletar(context, prescricaoMedicamento.id,
                          prescricaoMedicamento.cliente.usuario.nome);
                    });
                  },
                ),
              ],
            )
          ],
        )
      );

      prescricaoMedicamentoPainelExpansivoList.add(prescricaoMedicamentoPainelExpansivo);
    }

    return prescricaoMedicamentoPainelExpansivoList;
  }

  void openConfirmarChat(BuildContext context, String clienteId,
      String medicoId, String usuarioNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Chat"),
            content: Container(
              child:
                  Text('Deseja realmente conversar com ' + usuarioNome + '?'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MensagemPageForm(clienteId, medicoId),
                    ),
                  );
                },
                child: Text(
                  "Conversar",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openConfirmarEditar(
      BuildContext context, PrescricaoMedicamentoModel prescricaoMedicamento, String usuarioNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Editar"),
            content: Container(
              child: Text('Deseja realmente editar a prescrição de medicamento de ' +
                  usuarioNome +
                  '?'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  this.openPrescricaoMedicamentoForm(context, false, prescricaoMedicamento);
                },
                child: Text(
                  "Editar",
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openConfirmarDeletar(
      BuildContext context, String id, String clienteNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Deletar"),
            content: Container(
              child: Text('Deseja realmente deletar a prescrição de medicamento de ' +
                  clienteNome +
                  '?'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  this.openLoadingDialog(context);
                  prescricaoMedicamentoService.delete(id).then((value) => {
                        Navigator.pop(context),
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PrescricaoMedicamentoPageList(),
                          ),
                        ),
                      });
                },
                child: Text(
                  "Deletar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}