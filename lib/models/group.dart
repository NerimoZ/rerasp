class Group {
  final int id;
  final int aisId;
  final String title;

  Group({
    required this.id,
    required this.aisId,
    required this.title,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['Id'] ?? json['id'] ?? 0,
      aisId: json['AisId'] ?? json['aisId'] ?? 0,
      title: json['Title'] ?? json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AisId': aisId,
      'Title': title,
    };
  }

  String get number => title;
}
