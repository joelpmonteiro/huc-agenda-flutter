import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/widgets/nav-drawer.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:agenda/src/app/com/hempupcaring/agenda/sca/services/medico.service.dart'
    as medicoService;

class ProfissionalPage extends StatefulWidget {
  @override
  _ProfissionalPageState createState() => _ProfissionalPageState();
}

class _ProfissionalPageState extends State<ProfissionalPage> {
  int currentStep = 0;
  final stepDadosBasicos = 0;
  final stepDadosConsultorio = 1;

  final basicoFormKey = GlobalKey<FormState>();
  final consultorioFormKey = GlobalKey<FormState>();

  final txtCrmCtrl = new TextEditingController();
  final txtBiografiaCtrl = new TextEditingController();
  final txtBairroCtrl = new TextEditingController();
  final txtLogradouroCtrl = new TextEditingController();
  final txtNumeroCtrl = new TextEditingController();
  final txtComplementoCtrl = new TextEditingController();
  final txtCepCtrl = new TextEditingController();
  bool proximoHabilitado = true;
  bool voltarHabilitado = false;

  var cepMaskFormatter = new MaskTextInputFormatter(
      mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});

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

    medicoService.getCurrent().then((medico) => {
          (medico.crm != null &&
                  medico.crm.trim().isNotEmpty &&
                  medico.crm != 'null')
              ? txtCrmCtrl.text = medico.crm
              : txtCrmCtrl.text = '',
          (medico.biografia != null &&
                  medico.biografia.trim().isNotEmpty &&
                  medico.biografia != 'null')
              ? txtBiografiaCtrl.text = medico.biografia
              : txtBiografiaCtrl.text = '',
          (medico.consultorioBairro != null &&
                  medico.consultorioBairro.trim().isNotEmpty &&
                  medico.consultorioBairro != 'null')
              ? txtBairroCtrl.text = medico.consultorioBairro
              : txtBairroCtrl.text = '',
          (medico.consultorioLogradouro != null &&
                  medico.consultorioLogradouro.trim().isNotEmpty &&
                  medico.consultorioLogradouro != 'null')
              ? txtLogradouroCtrl.text = medico.consultorioLogradouro
              : txtLogradouroCtrl.text = '',
          (medico.consultorioNumero != null &&
                  medico.consultorioNumero.trim().isNotEmpty &&
                  medico.consultorioNumero != 'null')
              ? txtNumeroCtrl.text = medico.consultorioNumero
              : txtNumeroCtrl.text = '',
          (medico.consultorioComplemento != null &&
                  medico.consultorioComplemento.trim().isNotEmpty &&
                  medico.consultorioComplemento != 'null')
              ? txtComplementoCtrl.text = medico.consultorioComplemento
              : txtComplementoCtrl.text = '',
          (medico.consultorioCep != null &&
                  medico.consultorioCep.trim().isNotEmpty &&
                  medico.consultorioCep != 'null')
              ? txtCepCtrl.text = medico.consultorioCep
              : txtCepCtrl.text = '',
          Navigator.pop(context)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Dados Profissionais',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Container(
        child: ListView(
          children: [
            Stepper(
              controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
                return Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: controlsDetails.onStepContinue,
                      child: Text(
                        "Próximo",
                      ),
                    ),
                    TextButton(
                      onPressed: controlsDetails.onStepCancel,
                      child: Text(
                        "Voltar",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
              steps: _profissionalSteps(),
              currentStep: currentStep,
              onStepTapped: (step) {
                setState(() {
                  this.currentStep = step;
                });
              },
              onStepContinue: proximoHabilitado ? () {
                setState(() {
                  voltarHabilitado = true;
                  if (this.currentStep < stepDadosConsultorio) {
                    this.currentStep++;
                    proximoHabilitado = false;
                  }
                });
              } : null,
              onStepCancel: voltarHabilitado ? () {
                setState(() {
                  proximoHabilitado = true;
                  if (this.currentStep > stepDadosBasicos) {
                    this.currentStep--;
                    voltarHabilitado = false;
                  }
                });
              } : null,
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
                        atualizarDadosProfissionais(context);
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
        ),
      ),
    );
  }

  List<Step> _profissionalSteps() {
    List<Step> _stepList = [
      Step(
        title: Text('Dados Básicos'),
        content: Form(
          key: basicoFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: txtCrmCtrl,
                decoration: InputDecoration(
                  labelText: 'CRM',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo CRM é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtBiografiaCtrl,
                decoration: InputDecoration(labelText: 'Biografia'),
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo biografia é obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: currentStep >= stepDadosBasicos,
      ),
      Step(
        title: Text('Dados Consultório'),
        content: Form(
          key: consultorioFormKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: txtBairroCtrl,
                decoration: InputDecoration(labelText: 'Bairro'),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo celular é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtLogradouroCtrl,
                decoration: InputDecoration(labelText: 'Logradouro'),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo logradouro é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtNumeroCtrl,
                decoration: InputDecoration(labelText: 'Número'),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo número é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtComplementoCtrl,
                decoration: InputDecoration(labelText: 'Complemento'),
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo complemento é obrigatório';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtCepCtrl,
                decoration: InputDecoration(labelText: 'CEP'),
                inputFormatters: [cepMaskFormatter],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Campo CEP é obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: currentStep >= stepDadosConsultorio,
      )
    ];
    return _stepList;
  }

  Future<void> atualizarDadosProfissionais(BuildContext context) async {
    MedicoModel medico = new MedicoModel();
    medico.crm = txtCrmCtrl.text;
    medico.biografia = txtBiografiaCtrl.text;
    medico.consultorioBairro = txtBairroCtrl.text;
    medico.consultorioLogradouro = txtLogradouroCtrl.text;
    medico.consultorioNumero = txtNumeroCtrl.text;
    medico.consultorioComplemento = txtComplementoCtrl.text;
    medico.consultorioCep = txtCepCtrl.text;

    await medicoService.atualizarDadosProfissionais(medico);
    Navigator.pop(context);
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
}
