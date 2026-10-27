import 'package:agenda/src/app/com/hempupcaring/agenda/sca/model/medicoModel.dart';
import 'package:agenda/src/app/com/hempupcaring/agenda/scc/model/areaModel.dart';

class MedicoAreaModel {

  String id;
  MedicoModel medico;
  AreaModel area;

  MedicoAreaModel({this.id, this.medico, this.area});

  factory MedicoAreaModel.fromJson(Map<String, dynamic> json) {
    return MedicoAreaModel(
      id: json['id'],
      medico: MedicoModel.fromJson(json['medico']),
      area: AreaModel.fromJson(json['area'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medico': medico,
      'area': area
    };
  }

}