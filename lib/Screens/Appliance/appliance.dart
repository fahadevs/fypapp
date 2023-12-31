class Appliance {
  final int id;
  final String name;
  final int wattage;
  final int consumption;
  final String status;

  Appliance({
    required this.id,
    required this.name,
    required this.wattage,
    required this.consumption,
    required this.status,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') ||
        !json.containsKey('a_name') ||
        !json.containsKey('a_watt') ||
        !json.containsKey('a_consumption')||
      !json.containsKey('a_status')){
      throw FormatException('Invalid JSON structure for Appliance');
    }

    return Appliance(
      id: json['id'],
      name: json['a_name'],
      wattage: json['a_watt'],
      consumption: json['a_consumption'],
      status: json['a_status'],
    );
  }
}