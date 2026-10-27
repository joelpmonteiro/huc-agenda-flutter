class ResultSet {
  final int count;
  final int limit;
  final int offset;

  ResultSet({this.count, this.limit, this.offset});

  factory ResultSet.fromJson(Map<String, dynamic> json) {
    return ResultSet(
      count: json['count'],
      limit: json['limit'],
      offset: json['offset']
    );
  }
}