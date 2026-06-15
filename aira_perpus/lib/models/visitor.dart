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
        // BERUBAH: Sesuai dengan kolom 'classroom' di database
        'classroom': classRoom,
        'timestamp': timestamp,
        'method': method,
      };

  factory Visitor.fromJson(Map<String, dynamic> json) => Visitor(
        // Tambahan .toString() agar aman dari error cast tipe data
        id: json['id']?.toString() ?? '',
        nis: json['nis']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        classRoom: json['classroom']?.toString() ??
            json['classRoom']?.toString() ??
            json['class']?.toString() ??
            'VII-A',
        timestamp: json['timestamp']?.toString() ?? '',
        method: json['method']?.toString() ?? 'manual',
      );
}
