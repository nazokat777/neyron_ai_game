import 'dart:math';

/// Universal adaptiv qiyinchilik dvigateli — barcha kognitiv o'yinlar uchun.
/// Muvaffaqiyatda D eksponensial o'sadi (yuqori chegara yo'q — cheksiz),
/// xato/sekinlikda tushadi (Flow State). Jonlar + tezlik bonusi modeli.
class AdaptiveFlowEngine {
  // Sozlanadigan parametrlar
  final double alpha; // muvaffaqiyatdagi o'sish (tez+to'g'ri)
  final double beta; // xatodagi pasayish
  final double dMin; // D ning pastki chegarasi (yuqori chegara YO'Q)
  final double rtThreshold; // "tez" javob chegarasi (soniya)
  final double maxLatency; // "juda sekin" chegarasi (soniya)
  final int basePoints;
  final int speedBonus;
  final int startLives;
  final int maxLives;
  final int streakForBonusLife; // har shuncha streak'da +1 jon

  AdaptiveFlowEngine({
    this.alpha = 0.12,
    this.beta = 0.18,
    this.dMin = 1.0,
    this.rtThreshold = 0.9,
    this.maxLatency = 3.0,
    this.basePoints = 10,
    this.speedBonus = 10,
    this.startLives = 3,
    this.maxLives = 5,
    this.streakForBonusLife = 8,
  }) {
    _lives = startLives;
  }

  double d = 1.0;
  int _lives = 3;
  int score = 0;
  int streak = 0;
  int bestStreak = 0;
  int round = 0;
  int lastGained = 0;
  bool lastCorrect = false;
  bool gainedLife = false; // oxirgi raundda jon qo'shildimi (UI uchun)

  int get lives => _lives;
  bool get isGameOver => _lives <= 0;
  int get level => d.floor(); // ko'rsatish uchun butun daraja

  /// Bir raund natijasini qayd etadi va yangi holatni qaytaradi.
  /// [reactionTime] null bo'lsa (vaqt o'lchanmaydigan o'yinlar) — "tez" deb hisoblanadi.
  void registerRound({required bool correct, double? reactionTime}) {
    round++;
    gainedLife = false;
    final fast = reactionTime == null || reactionTime < rtThreshold;
    final tooSlow = reactionTime != null && reactionTime > maxLatency;

    if (correct && !tooSlow) {
      lastCorrect = true;
      streak++;
      if (streak > bestStreak) bestStreak = streak;
      // Qiyinroq raund ko'proq ball; tez javobga bonus
      var gained = basePoints + (fast ? speedBonus : 0);
      gained = (gained * d).round();
      score += gained;
      lastGained = gained;
      // Eksponensial cheksiz o'sish — faqat tez+to'g'ri javobda
      if (fast) d *= (1 + alpha);
      // Tezlik/aniqlik mukofoti: streak bonus jon beradi
      if (streak % streakForBonusLife == 0 && _lives < maxLives) {
        _lives++;
        gainedLife = true;
      }
    } else {
      lastCorrect = false;
      lastGained = 0;
      streak = 0;
      _lives--;
      d = max(dMin, d * (1 - beta)); // dinamik ease-in
    }
  }

  /// Joriy D ni aniq o'yin parametrlariga moslaydi.
  /// Misol: { 'speed': (d) => 1 + d * 0.4, 'grid': (d) => 3 + d ~/ 2 }
  Map<String, num> resolve(Map<String, num Function(double)> configs) {
    return configs.map((k, f) => MapEntry(k, f(d)));
  }

  void reset() {
    d = 1.0;
    _lives = startLives;
    score = 0;
    streak = 0;
    bestStreak = 0;
    round = 0;
    lastGained = 0;
    lastCorrect = false;
    gainedLife = false;
  }
}
