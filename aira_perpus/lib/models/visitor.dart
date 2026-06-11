class Visitor {
  final String id;
  final String nis;
  final String name;
  final String classRoom;
  final String timestamp;
  final String method; // 'camera' | 'barcode' | 'manual'

  Visitor({
    required this.id,
    required this.nis,
    required this.name,
    required this.classRoom,
    required this.timestamp,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nis': nis,
        'name': name,
        'classRoom': classRoom,
        'timestamp': timestamp,
        'method': method,
      };

  factory Visitor.fromJson(Map<String, dynamic> json) => Visitor(
        id: json['id'] ?? '',
        nis: json['nis'] ?? '',
        name: json['name'] ?? '',
        classRoom: json['classRoom'] ?? json['class'] ?? 'VII-A',
        timestamp: json['timestamp'] ?? '',
        method: json['method'] ?? 'manual',
      );
}
