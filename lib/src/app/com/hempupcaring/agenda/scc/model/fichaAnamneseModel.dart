class FichaAnamneseModel {

  String id;

  FichaAnamneseModel({this.id});

  factory FichaAnamneseModel.fromJson(Map<String, dynamic> json) {
    return FichaAnamneseModel(
      id: json['id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id
    };
  }
  
}