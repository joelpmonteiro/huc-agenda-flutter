import 'package:agenda/src/app/com/hempupcaring/agenda/resultSet.dart';

class Metadata {
  final ResultSet resultSet;

  Metadata({this.resultSet});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      resultSet: ResultSet.fromJson(json['resultSet'])
    );
  }
}