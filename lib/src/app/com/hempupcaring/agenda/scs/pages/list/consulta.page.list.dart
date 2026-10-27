import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/clienteModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/pages/form/mensagem.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/utils/chamada.utilities.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/utils/permissions.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consulta.filter.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/model/consulta.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/form/consulta.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/pages/form/consultaFilter.page.form.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/scs/constantsConsulta.dart';
import 'package:agenda/widgets/expansion-panel.dart';
import 'package:flutter/material.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scs/services/consulta.service.dart'
    as consultaService;
import 'package:intl/intl.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/util/dataUtil.dart'
    as dataUtil;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/usuario.service.dart'
    as usuarioService;
import 'dart:convert';

class ConsultaPageList extends StatefulWidget {
  @override
  _ConsultaPageListState createState() => _ConsultaPageListState();
}

class _ConsultaPageListState extends State<ConsultaPageList> {
  final prefs = SharedPreferences.getInstance();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _clienteConsultaFormKey = GlobalKey<FormState>();
  ListView consultaPanelList;
  List<CustomExpansionPanel> consultaList = [];
  bool isSnackbarActive = false;
  List<CustomExpansionPanel> consultaPainelExpansivoList = [];
  ConsultaFilter consultaFilter = null;
  bool isCurrentMedico = false;
  DateFormat formatter;
  final filtroFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      prefs.then((prefs) => {
            if (prefs.getString('medico_id') != null)
              {this.isCurrentMedico = true},
            consultaFilter = new ConsultaFilter(),
            if (!this.isCurrentMedico)
              {
                consultaFilter.cliente = new ClienteModel(),
                consultaFilter.cliente.id = prefs.getString('cliente_id')
              }
            else
              {
                consultaFilter.medico = new MedicoModel(),
                consultaFilter.medico.id = prefs.getString('medico_id')
              },
            findAllByfilter(consultaFilter)
          });
      this.formatter = DateFormat('dd/MM/yyyy HH:mm');
    });
  }

  @override
  Widget build(BuildContext context) {
    consultaPanelList = ListView.builder(
      itemCount: consultaPainelExpansivoList.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpansionPanelList(
          animationDuration: Duration(milliseconds: 1000),
          dividerColor: Colors.red,
          elevation: 1,
          children: [
            ExpansionPanel(
              body: Container(
                  padding: EdgeInsets.all(10),
                  child: consultaPainelExpansivoList[index].body),
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: consultaPainelExpansivoList[index].header,
                );
              },
              isExpanded: consultaPainelExpansivoList[index].expanded,
            )
          ],
          expansionCallback: (int item, bool status) {
            setState(() {
              consultaPainelExpansivoList[index].expanded =
                  !consultaPainelExpansivoList[index].expanded;
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
          title: Text("Minhas Consultas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          actions: <Widget>[
            IconButton(
              iconSize: 40,
              icon: Icon(
                Icons.filter_alt,
              ),
              tooltip: 'Filtrar',
              onPressed: () {
                setState(() {
                  this.openConsultaFilter(context);
                });
              },
            ),
          ],
        ),
        body: consultaPanelList,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            this.openConsultaForm(context, true, null);
          },
          child: new Icon(Icons.add),
        ),
      ),
    );

    return willPopScope;
  }

  Future<void> findAllByfilter(ConsultaFilter consultaFilter) async {
    _openLoadingDialog(this.context);
    consultaService.findAllByfilter(consultaFilter).then((consultaList) => {
          if (this.isCurrentMedico)
            {
              setState(() {
                montarMedicoConsultaList(consultaList).then((list) => {
                      this.consultaPainelExpansivoList = list,
                      Navigator.pop(context)
                    });
              })
            }
          else
            {
              setState(() {
                montarClienteConsultaList(consultaList).then((list) => {
                      this.consultaPainelExpansivoList = list,
                      Navigator.pop(context)
                    });
              })
            }
        });
  }

  Future<void> openConsultaFilter(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return SingleChildScrollView(
          child: AlertDialog(
              title: Text("Filtrar"),
              content: ConsultaFilterPageForm(prefs.getString('cliente_id'),
                  prefs.getString('medico_id'), this.findAllByfilter)),
        );
      },
    );
  }

  void _openLoadingDialog(BuildContext context) {
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

  Future<List<CustomExpansionPanel>> montarClienteConsultaList(
      List<ConsultaModel> consultaList) async {
    final prefs = await SharedPreferences.getInstance();
    List<CustomExpansionPanel> consultaPainelExpansivoList = [];
    CustomExpansionPanel consultaPainelExpansivo;
    Color headerColor;

    for (var i = 0; i < consultaList.length; i++) {
      if (consultaList[i].status == ConstantsConsulta().STATUS_PENDENTE)
        headerColor = Colors.blue;
      else if (consultaList[i].status == ConstantsConsulta().STATUS_AGENDADO)
        headerColor = Colors.green;
      else if (consultaList[i].status == ConstantsConsulta().STATUS_CANCELADO)
        headerColor = Colors.red;
      else if (consultaList[i].status ==
          ConstantsConsulta().STATUS_EM_ANDAMENTO)
        headerColor = Colors.green;
      else if (consultaList[i].status == ConstantsConsulta().STATUS_FINALIZADO)
        headerColor = Colors.grey;
      else
        headerColor = Colors.yellow;

      consultaPainelExpansivo = CustomExpansionPanel(
          false,
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: consultaList[i].horario.medico.usuario.foto != null
                    ? Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MemoryImage(
                                  consultaList[i].horario.medico.usuario.foto),
                            )),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/user_default.png'),
                            )),
                      ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(consultaList[i].horario.medico.usuario.nome,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.circle_rounded,
                        color: headerColor,
                        size: 16.0,
                      ),
                    ],
                  ),
                  Text(dataUtil.montarData(
                          consultaList[i].dataHoraMarcada.day,
                          consultaList[i].dataHoraMarcada.month,
                          consultaList[i].dataHoraMarcada.year,
                          "dd/MM/yyyy") +
                      " " +
                      dataUtil.montarHorario(
                          consultaList[i].dataHoraMarcada.hour + 1,
                          consultaList[i].dataHoraMarcada.minute,
                          "hh:mm")),
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (consultaList[i].observacao != null)
                Container(
                  child: Text(consultaList[i].observacao),
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
                            prefs.getString("cliente_id"),
                            consultaList[i].horario.medico.id,
                            consultaList[i].horario.medico.usuario.nome);
                      });
                    },
                  ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_EM_ANDAMENTO)
                    IconButton(
                      icon: Icon(
                        Icons.camera_front,
                        color: Colors.blue,
                      ),
                      tooltip: 'Vídeo chamada',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarVideoChamada(
                              context,
                              consultaList[i],
                              consultaList[i].horario.medico.usuario.nome,
                              prefs.getString('id'),
                              consultaList[i].horario.medico.usuario.id
                          );
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                          ConstantsConsulta().STATUS_AGENDADO &&
                      (consultaList[i]
                              .dataHoraMarcada
                              .isBefore(DateTime.now()) ||
                          consultaList[i]
                              .dataHoraMarcada
                              .isAtSameMomentAs(DateTime.now())))
                    IconButton(
                      icon: Icon(
                        Icons.login,
                        color: Colors.green,
                      ),
                      tooltip: 'Começar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarComecar(context, consultaList[i],
                              consultaList[i].horario.medico.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_EM_ANDAMENTO)
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      tooltip: 'Finalizar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarFinalizar(context, consultaList[i],
                              consultaList[i].horario.medico.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_AGENDADO)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.yellow,
                      ),
                      tooltip: 'Remarcar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarRemarcar(context, consultaList[i],
                              consultaList[i].horario.medico.usuario.nome);
                        });
                      },
                    ),
                ],
              ),
            ],
          ));
      consultaPainelExpansivoList.add(consultaPainelExpansivo);
    }

    return consultaPainelExpansivoList;
  }

  Future<List<CustomExpansionPanel>> montarMedicoConsultaList(
      List<ConsultaModel> consultaList) async {
    final prefs = await SharedPreferences.getInstance();
    List<CustomExpansionPanel> consultaPainelExpansivoList = [];
    CustomExpansionPanel consultaPainelExpansivo;
    Color headerColor;

    for (var i = 0; i < consultaList.length; i++) {
      if (consultaList[i].status == ConstantsConsulta().STATUS_PENDENTE)
        headerColor = Colors.blue;
      else if (consultaList[i].status == ConstantsConsulta().STATUS_AGENDADO)
        headerColor = Colors.green;
      else if (consultaList[i].status == ConstantsConsulta().STATUS_CANCELADO)
        headerColor = Colors.red;
      else if (consultaList[i].status ==
          ConstantsConsulta().STATUS_EM_ANDAMENTO)
        headerColor = Colors.green;
      else if (consultaList[i].status == ConstantsConsulta().STATUS_FINALIZADO)
        headerColor = Colors.grey;
      else
        headerColor = Colors.yellow;

      consultaPainelExpansivo = CustomExpansionPanel(
          false,
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: consultaList[i].cliente.usuario.foto != null
                    ? Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MemoryImage(
                                  consultaList[i].cliente.usuario.foto),
                            )),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/user_default.png'),
                            )),
                      ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(consultaList[i].cliente.usuario.nome,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.circle_rounded,
                        color: headerColor,
                        size: 16.0,
                      ),
                    ],
                  ),
                  Text(dataUtil.montarData(
                          consultaList[i].dataHoraMarcada.day,
                          consultaList[i].dataHoraMarcada.month,
                          consultaList[i].dataHoraMarcada.year,
                          "dd/MM/yyyy") +
                      " " +
                      dataUtil.montarHorario(
                          consultaList[i].dataHoraMarcada.hour + 1,
                          consultaList[i].dataHoraMarcada.minute,
                          "hh:mm")),
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (consultaList[i].observacao != null)
                Container(
                  child: Text(consultaList[i].observacao),
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
                            consultaList[i].cliente.id,
                            prefs.getString("medico_id"),
                            consultaList[i].cliente.usuario.nome);
                      });
                    },
                  ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_EM_ANDAMENTO)
                    IconButton(
                      icon: Icon(
                        Icons.camera_front,
                        color: Colors.blue,
                      ),
                      tooltip: 'Vídeo chamada',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarVideoChamada(
                              context,
                              consultaList[i],
                              consultaList[i].cliente.usuario.nome,
                              prefs.getString('id'),
                              consultaList[i].cliente.usuario.id);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                          ConstantsConsulta().STATUS_AGENDADO &&
                      (consultaList[i]
                              .dataHoraMarcada
                              .isBefore(DateTime.now()) ||
                          consultaList[i]
                              .dataHoraMarcada
                              .isAtSameMomentAs(DateTime.now())))
                    IconButton(
                      icon: Icon(
                        Icons.login,
                        color: Colors.green,
                      ),
                      tooltip: 'Começar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarComecar(context, consultaList[i],
                              consultaList[i].cliente.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_EM_ANDAMENTO)
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      tooltip: 'Finalizar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarFinalizar(context, consultaList[i],
                              consultaList[i].cliente.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_PENDENTE)
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      tooltip: 'Confirmar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarConfirmacao(
                              context,
                              consultaList[i].id,
                              consultaList[i].cliente.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                      ConstantsConsulta().STATUS_AGENDADO)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.yellow,
                      ),
                      tooltip: 'Remarcar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarRemarcar(context, consultaList[i],
                              consultaList[i].cliente.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                          ConstantsConsulta().STATUS_PENDENTE ||
                      consultaList[i].status ==
                          ConstantsConsulta().STATUS_AGENDADO)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      tooltip: 'Cancelar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarCancelar(
                              context,
                              consultaList[i].id,
                              consultaList[i].cliente.usuario.nome);
                        });
                      },
                    ),
                  if (consultaList[i].status ==
                          ConstantsConsulta().STATUS_CANCELADO ||
                      consultaList[i].status ==
                          ConstantsConsulta().STATUS_REAGENDADO ||
                      consultaList[i].status ==
                          ConstantsConsulta().STATUS_FINALIZADO)
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      tooltip: 'Deletar',
                      onPressed: () {
                        setState(() {
                          this.openConfirmarDeletar(context, consultaList[i].id,
                              consultaList[i].cliente.usuario.nome);
                        });
                      },
                    ),
                ],
              ),
            ],
          ));
      consultaPainelExpansivoList.add(consultaPainelExpansivo);
    }

    return consultaPainelExpansivoList;
  }

  void openConfirmarVideoChamada(BuildContext context, ConsultaModel consulta, String usuarioNome, String usuarioRemetenteId, String usuarioDestinatarioId) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Vídeo chamada"),
            content: Container(
              child: Text('Deseja realmente entrar em vídeo chamada com ' +
                  usuarioNome +
                  '?'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  _openLoadingDialog(this.context);

                  if (await Permissions.cameraAndMicrophonePermissionsGranted()) {

                    UsuarioModel usuarioRemetente = await usuarioService.findById(usuarioRemetenteId);
                    UsuarioModel usuarioDestinatario = await usuarioService.findById(usuarioDestinatarioId);

                    Navigator.of(context).pop();

                    ChamadaUtilities.dial(
                      usuarioRemetente: usuarioRemetente,
                      usuarioDestinatario: usuarioDestinatario,
                      context: context
                    );
                  }

                },
                child: Text(
                  "Entrar",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openConfirmarFinalizar(
      BuildContext context, ConsultaModel consulta, String usuarioNome) {
    var errorObj;
    var errorMsg;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Finalizar"),
            content: Container(
              child: Text('Deseja realmente finalizar a consulta com ' +
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
                  this._openLoadingDialog(context);
                  consultaService
                      .finalizar(consulta)
                      .then((value) => {
                            Navigator.pop(context),
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ConsultaPageList(),
                              ),
                            ),
                          })
                      .catchError((error) => {
                            errorObj = error = json.decode(error.body),
                            errorMsg = utf8.decode(
                                errorObj['message'].toString().codeUnits),
                            _displaySnackBar(this.context, errorMsg)
                          });
                  ;
                },
                child: Text(
                  "Finalizar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openConfirmarComecar(
      BuildContext context, ConsultaModel consulta, String usuarioNome) {
    var errorObj;
    var errorMsg;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Começar"),
            content: Container(
              child: Text('Deseja realmente começar a consulta com ' +
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
                  this._openLoadingDialog(context);
                  consultaService
                      .comecar(consulta)
                      .then((value) => {
                            Navigator.pop(context),
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ConsultaPageList(),
                              ),
                            ),
                          })
                      .catchError((error) => {
                            errorObj = error = json.decode(error.body),
                            errorMsg = utf8.decode(
                                errorObj['message'].toString().codeUnits),
                            Navigator.of(context).pop(),
                            Navigator.of(context).pop(),
                            _displaySnackBar(this.context, errorMsg)
                          });
                },
                child: Text(
                  "Começar",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openConfirmarRemarcar(
      BuildContext context, ConsultaModel consulta, String usuarioNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Remarcar"),
            content: Container(
              child: Text('Deseja realmente remarcar a consulta com ' +
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
                  this.openConsultaForm(context, false, consulta);
                },
                child: Text(
                  "Remarcar",
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              child: Text('Deseja realmente deletar a consulta com ' +
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
                  this._openLoadingDialog(context);
                  consultaService.delete(id).then((value) => {
                        Navigator.pop(context),
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ConsultaPageList(),
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

  void openConfirmarConfirmacao(
      BuildContext context, String id, String clienteNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Confirmar"),
            content: Container(
              child: Text(
                  'Deseja realmente confirmar a consulta com o cliente ' +
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
                  this._openLoadingDialog(context);
                  consultaService
                      .updateStatus(id, ConstantsConsulta().STATUS_AGENDADO)
                      .then((value) => {
                            Navigator.pop(context),
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ConsultaPageList(),
                              ),
                            ),
                          });
                },
                child: Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void openConfirmarCancelar(
      BuildContext context, String id, String clienteNome) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text("Cancelar"),
            content: Container(
              child: Text(
                  'Deseja realmente cancelar a consulta com o cliente ' +
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
                  this._openLoadingDialog(context);
                  consultaService
                      .updateStatus(id, ConstantsConsulta().STATUS_CANCELADO)
                      .then((value) => {
                            Navigator.pop(context),
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ConsultaPageList(),
                              ),
                            ),
                          });
                },
                child: Text(
                  "Confirmar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> openConsultaForm(
      BuildContext context, bool isNovoRegistro, ConsultaModel consulta) async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: isNovoRegistro
                ? Text("Nova Consulta")
                : Text("Remarcar Consulta"),
            content: ConsultaPageForm(
                prefs.getString('cliente_id'),
                prefs.getString('medico_id'),
                isNovoRegistro,
                consulta,
                _displaySnackBar),
          ),
        );
      },
    ).then((value) {});
  }

  _displaySnackBar(BuildContext context, String msg) {
    if (this.isSnackbarActive) _scaffoldKey.currentState.hideCurrentSnackBar();

    final snackBar = SnackBar(content: Text(msg));
    this.isSnackbarActive = true;
    _scaffoldKey.currentState.showSnackBar(snackBar).closed.then((value) => {
          this.isSnackbarActive = false,
        });
  }
}
