import 'dart:async';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/usuarioModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/chat.model.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/mensagem.model.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart'
    as medicoService;
import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/cliente.service.dart'
    as clienteService;
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/chat.service.dart'
    as chatService;
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/services/mensagem.service.dart'
    as mensagemService;

class MensagemPageForm extends StatefulWidget {
  String clienteId;
  String medicoId;

  @override
  _MensagemPageFormState createState() =>
      _MensagemPageFormState(this.clienteId, this.medicoId);

  MensagemPageForm(this.clienteId, this.medicoId);
}

class _MensagemPageFormState extends State<MensagemPageForm> {
  final prefs = SharedPreferences.getInstance();
  final formKey = GlobalKey<FormState>();
  final txtChatIdCtrl = new TextEditingController();
  final txtTextCtrl = new TextEditingController();
  final scrollController = ScrollController();
  String clienteId;
  String medicoId;
  String currentUserId;
  String destinatarioNome = "";
  UsuarioModel usuarioDestinatario = null;
  UsuarioModel usuarioRemetente = null;
  ImageProvider destinatarioFoto = AssetImage('assets/user_default.png');
  Chat chat = null;
  int ultimaMensagemIndex = -1;
  bool requestLock = false;
  bool rolar = true;
  Timer clockTimer;

  List<Mensagem> mensagemList = [];

  _MensagemPageFormState(this.clienteId, this.medicoId);

  @override
  void dispose() {
    if (clockTimer != null) {
      clockTimer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openLoadingDialog(this.context);

      prefs.then((prefs) => {
            currentUserId = prefs.getString('id'),
            if (prefs.getString('medico_id') != null)
              {
                clienteService.findById(this.clienteId).then((cliente) => {
                      setState(() {
                        usuarioDestinatario = new UsuarioModel();
                        usuarioDestinatario.id = cliente.usuario.id;
                        usuarioRemetente = new UsuarioModel();
                        usuarioRemetente.id = prefs.getString('id');
                        destinatarioNome = cliente.usuario.nome;
                        if (cliente.usuario.foto != null) {
                          destinatarioFoto = MemoryImage(cliente.usuario.foto);
                        }

                        chatService
                            .findOrCreateChat(this.medicoId, this.clienteId)
                            .then((chat) => {
                                  this.chat = new Chat(),
                                  this.chat.id = chat.id,
                                  mensagemService
                                      .findAllByChatId(this.chat.id)
                                      .then((mensagemList) => {
                                            setState(() {
                                              this.mensagemList = mensagemList;
                                            }),
                                            for (Mensagem mensagem
                                                in this.mensagemList)
                                              {
                                                if (mensagem.index >
                                                    this.ultimaMensagemIndex)
                                                  {
                                                    this.ultimaMensagemIndex =
                                                        mensagem.index,
                                                  }
                                              },
                                            scrollController.jumpTo(
                                                scrollController
                                                    .position.maxScrollExtent),
                                            clockTimer = Timer.periodic(
                                                new Duration(seconds: 1),
                                                (timer) {
                                              if (this.rolar) {
                                                scrollController.jumpTo(
                                                    scrollController.position
                                                        .maxScrollExtent);
                                                this.rolar = false;
                                              }

                                              if (!this.requestLock) {
                                                this.requestLock = true;
                                                mensagemService
                                                    .findAllByChatIdAndIndex(
                                                        this.chat.id,
                                                        this.ultimaMensagemIndex)
                                                    .then((mensagemList) => {
                                                          for (Mensagem mensagem
                                                              in mensagemList)
                                                            {
                                                              if (mensagem
                                                                      .index >
                                                                  this
                                                                      .ultimaMensagemIndex)
                                                                {
                                                                  this.ultimaMensagemIndex =
                                                                      mensagem
                                                                          .index
                                                                },
                                                              if (!this
                                                                  .mensagemList
                                                                  .contains(
                                                                      mensagem))
                                                                {
                                                                  setState(() {
                                                                    this
                                                                        .mensagemList
                                                                        .add(
                                                                            mensagem);
                                                                  }),
                                                                }
                                                            },
                                                          this.requestLock =
                                                              false,
                                                          if (mensagemList
                                                                  .length >
                                                              0)
                                                            {this.rolar = true}
                                                        });
                                              }
                                            }),
                                            Navigator.pop(context)
                                          })
                                });
                      })
                    })
              }
            else
              {
                medicoService.findById(this.medicoId).then((medico) => {
                      setState(() {
                        usuarioDestinatario = new UsuarioModel();
                        usuarioDestinatario.id = medico.usuario.id;
                        usuarioRemetente = new UsuarioModel();
                        usuarioRemetente.id = prefs.getString('id');
                        destinatarioNome = medico.usuario.nome;
                        if (medico.usuario.foto != null) {
                          destinatarioFoto = MemoryImage(medico.usuario.foto);
                        }

                        chatService
                            .findOrCreateChat(this.medicoId, this.clienteId)
                            .then((chat) => {
                                  this.chat = new Chat(),
                                  this.chat.id = chat.id,
                                  mensagemService
                                      .findAllByChatId(this.chat.id)
                                      .then((mensagemList) => {
                                            setState(() {
                                              this.mensagemList = mensagemList;
                                            }),
                                            for (Mensagem mensagem
                                                in this.mensagemList)
                                              {
                                                if (mensagem.index >
                                                    this.ultimaMensagemIndex)
                                                  {
                                                    this.ultimaMensagemIndex =
                                                        mensagem.index
                                                  }
                                              },
                                            Timer.periodic(
                                                new Duration(seconds: 1),
                                                (timer) {
                                              if (this.rolar) {
                                                scrollController.jumpTo(
                                                    scrollController.position
                                                        .maxScrollExtent);
                                                this.rolar = false;
                                              }

                                              if (!this.requestLock) {
                                                this.requestLock = true;
                                                mensagemService
                                                    .findAllByChatIdAndIndex(
                                                        this.chat.id,
                                                        this.ultimaMensagemIndex)
                                                    .then((mensagemList) => {
                                                          for (Mensagem mensagem
                                                              in mensagemList)
                                                            {
                                                              if (mensagem
                                                                      .index >
                                                                  this
                                                                      .ultimaMensagemIndex)
                                                                {
                                                                  this.ultimaMensagemIndex =
                                                                      mensagem
                                                                          .index
                                                                },
                                                              if (!this
                                                                  .mensagemList
                                                                  .contains(
                                                                      mensagem))
                                                                {
                                                                  setState(() {
                                                                    this
                                                                        .mensagemList
                                                                        .add(
                                                                            mensagem);
                                                                  }),
                                                                }
                                                            },
                                                          this.requestLock =
                                                              false,
                                                          if (mensagemList
                                                                  .length >
                                                              0)
                                                            {this.rolar = true}
                                                        });
                                              }
                                            }),
                                            Navigator.pop(context)
                                          })
                                });
                      })
                    })
              }
          });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ),
                SizedBox(
                  width: 2.0,
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: destinatarioFoto,
                      )),
                ),
                SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(destinatarioNome,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 145,
              maxHeight: MediaQuery.of(context).size.height - 145,
            ),
            child: ListView.builder(
              controller: this.scrollController,
              itemCount: mensagemList.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                  child: Align(
                    alignment: mensagemList[index].usuarioRemetente.id ==
                            this.currentUserId
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: mensagemList[index].usuarioRemetente.id ==
                                  this.currentUserId
                              ? Colors.blue[200]
                              : Colors.grey.shade200),
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mensagemList[index].texto, style: TextStyle(fontSize: 15)),
                          SizedBox(height: 8,),
                          Text(formatDateTime(mensagemList[index].dataHora), style: TextStyle(fontSize: 8))
                        ]
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: txtTextCtrl,
                      decoration: InputDecoration(
                          hintText: "Mensagem",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      enviarMensagem();
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Color(0xFF486832),
                    elevation: 0,
                  ),
                ])),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {

    String data = dateTime.toLocal().toString().split(" ")[0];
    data = data.split("-").reversed.join("/");
    String hora = dateTime.toLocal().toString().split(" ")[1];
    hora = hora.split(".")[0].substring(0, 5);

    return data + " " + hora;
  }

  void enviarMensagem() {
    if (txtTextCtrl.text != null && txtTextCtrl.text.trim().isNotEmpty) {
      Mensagem mensagem = new Mensagem();
      mensagem.chat = this.chat;
      mensagem.isExcluida = false;
      mensagem.dataHora = null;
      mensagem.texto = txtTextCtrl.text;
      mensagem.usuarioDestinatario = this.usuarioDestinatario;
      mensagem.usuarioRemetente = this.usuarioRemetente;

      mensagem.texto = mensagem.texto.replaceAll(RegExp('[^ -Ý]'), '');

      if (mensagem.texto != null && mensagem.texto.trim().isNotEmpty) {
        mensagemService.create(mensagem);
        txtTextCtrl.clear();
      }
    }
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
}
