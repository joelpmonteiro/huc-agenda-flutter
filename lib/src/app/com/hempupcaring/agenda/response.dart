import 'package:agenda/src/app/com/hempupcaring/agenda/metadata.dart';

class Response {
  final Object result;
  final List<Object> results;
  final Metadata metadata;
  String statusCode;

  Response({this.result, this.results, this.metadata, this.statusCode});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      result: json['result'],
      results: json['results'] != null ? json['results'] : null,
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      statusCode: ''
    );
  }

}
