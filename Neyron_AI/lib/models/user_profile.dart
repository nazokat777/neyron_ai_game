enum AgeGroup {
  child,        // 3-7
  youngTeen,    // 8-12
  teen,         // 13-17
  adult,        // 18-39
  midAge,       // 40-59
  senior;       // 60-70

  static AgeGroup fromAge(int age) {
    if (age <= 7) return AgeGroup.child;
    if (age <= 12) return AgeGroup.youngTeen;
    if (age <= 17) return AgeGroup.teen;
    if (age <= 39) return AgeGroup.adult;
    if (age <= 59) return AgeGroup.midAge;
    return AgeGroup.senior;
  }

  String get displayName {
    switch (this) {
      case AgeGroup.child: return 'Kichik kashfiyotchi';
      case AgeGroup.youngTeen: return 'Yosh izlanuvchi';
      case AgeGroup.teen: return 'Yosh tadqiqotchi';
      case AgeGroup.adult: return 'Muvaffaqiyat sari';
      case AgeGroup.midAge: return 'Tajribali tadqiqotchi';
      case AgeGroup.senior: return 'Dono mutaxassis';
    }
  }
}

class UserProfile {
  final String name;
  final int age;
  final DateTime joinedDate;
  final int streakDays;
  final int totalSessions;
  final int coins;
  final Map<String, double> skills; // memory, attention, logic, speed, flexibility

  UserProfile({
    required this.name,
    required this.age,
    required this.joinedDate,
    this.streakDays = 0,
    this.totalSessions = 0,
    this.coins = 0,
    Map<String, double>? skills,
  }) : skills = skills ?? {
          'memory': 0.0,
          'attention': 0.0,
          'logic': 0.0,
          'speed': 0.0,
          'flexibility': 0.0,
        };

  AgeGroup get ageGroup => AgeGroup.fromAge(age);

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'joinedDate': joinedDate.toIso8601String(),
        'streakDays': streakDays,
        'totalSessions': totalSessions,
        'coins': coins,
        'skills': skills,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        age: json['age'] as int,
        joinedDate: DateTime.parse(json['joinedDate'] as String),
        streakDays: json['streakDays'] as int? ?? 0,
        totalSessions: json['totalSessions'] as int? ?? 0,
        coins: json['coins'] as int? ?? 0,
        skills: Map<String, double>.from(
          (json['skills'] as Map?)?.map(
                (k, v) => MapEntry(k as String, (v as num).toDouble()),
              ) ??
              {},
        ),
      );

  UserProfile copyWith({
    String? name,
    int? age,
    int? streakDays,
    int? totalSessions,
    int? coins,
    Map<String, double>? skills,
  }) =>
      UserProfile(
        name: name ?? this.name,
        age: age ?? this.age,
        joinedDate: joinedDate,
        streakDays: streakDays ?? this.streakDays,
        totalSessions: totalSessions ?? this.totalSessions,
        coins: coins ?? this.coins,
        skills: skills ?? this.skills,
      );
}
