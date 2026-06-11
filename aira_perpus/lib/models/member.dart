class Member {
  final int id;
  final String name;
  final String nis;
  final String memberClass;

  Member({
    required this.id,
    required this.name,
    required this.nis,
    required this.memberClass,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nis': nis,
        'memberClass': memberClass,
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        name: json['name'] ?? '',
        nis: json['nis'] ?? '',
        memberClass: json['class'] ?? json['memberClass'] ?? 'VII-A',
      );
}
