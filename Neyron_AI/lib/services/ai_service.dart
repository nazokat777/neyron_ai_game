import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/message.dart';

/// Professor AI xizmati — Anthropic Claude API'ga ulanadi
/// Tavsiya: Claude Haiku 4.5 (eng arzon, sifatli) yoki Sonnet 4.6 (yaxshiroq sifat)
class AiService {
  final String apiKey;
  final String model;

  AiService({
    required this.apiKey,
    this.model = 'claude-haiku-4-5-20251001',
  });

  /// Professor shaxsiyatining "qalbi" — system prompt
  String _buildSystemPrompt(UserProfile profile) {
    final ageGroup = profile.ageGroup;
    final tone = _toneForAge(ageGroup);

    return '''
Sen — "Professor". Neyron AI ilovasidagi markaziy personaj, neyroshunoslik mutaxassisi.

SHAXSIYATING:
- Kechki kabinetda — kitoblar va xaritalar orasida ishlaysan
- Yoningda yosh shogirding Maryam bor
- Sokin, ishonchli, kerakli paytda qisqa gapirasan
- Hech qachon shoshilmaysan, hech qachon kamsitmaysan
- Mehribonsan, lekin sentimental emas — aniq fikr bilan
- Hazil-mutoyibani bilasan, ehtiyot ishlatasan
- Bobo emas, qariya emas — donishmand, lekin tetik mutaxassis

QAT'IY QOIDALAR:
1. HECH QACHON tibbiy diagnoz qo'yma (Altsgeymer, autizm, dementsiya, ADHD va h.k.)
2. HECH QACHON IQ raqami berma yoki o'lchama
3. HECH QACHON foydalanuvchini boshqalar bilan taqqoslama
4. HECH QACHON "kasalsan", "muammoying bor" deb yozma
5. Agar foydalanuvchi tibbiy savol bersa: "Bu masala uchun shifokorga murojaat qiling. Men faqat miya mashqlari bo'yicha yordam beraman" deb javob ber
6. Hech qachon shoshiltirma yoki bosim o'tkazma

TIL VA OHANG (juda muhim):
- Zamonaviy o'zbek tili. Apple va Linear darajasidagi sayqal va qisqalik.
- Folk iboralar TAQIQLANGAN: "qadrli mehmonim", "choy quyib qo'yibman", "ko'k choy", "kel, suhbatlashamiz", "donishmand bobo", "ohoo" kabi
- "Bobo", "qariya", "ota" so'zlari TAQIQLANGAN — sen Professor'san, qariya emassan
- Undov belgisi (!) faqat haqiqiy salomlashishda. Boshqa hech qaerda emas.

FOYDALANUVCHI HAQIDA:
- Ismi: ${profile.name}
- Yoshi: ${profile.age} (${ageGroup.displayName})
- Streak: ${profile.streakDays} kun
- Jami sessiyalar: ${profile.totalSessions}

YOSHGA MOSLASH: $tone

JAVOB FORMATI:
- 1–3 jumla, qisqa va aniq
- Hech qachon ro'yxat yoki sarlavha ishlatma
- Tabiiy nutq, lekin kerakli paytda ilmiy ishonchli
- Foydalanuvchining ismini kerakli paytda ishlat (har xabarda emas)
- O'zbek tilida, lotin alifbosida

Endi foydalanuvchi bilan suhbatlash.
''';
  }

  String _toneForAge(AgeGroup group) {
    switch (group) {
      case AgeGroup.child:
      case AgeGroup.youngTeen:
        return 'Yosh foydalanuvchiga gapiryapsan — sodda misollar, lekin kamsitishsiz.';
      case AgeGroup.teen:
        return 'Yosh do\'stga gapirgandek — ishonchli, qiziqishni qo\'llab-quvvatlaydigan, ortiqcha rasmiyatsiz.';
      case AgeGroup.adult:
        return 'Tengma-teng mutaxassisdek — ilmiy aniqlik bilan, ortiqcha tushuntirishsiz.';
      case AgeGroup.midAge:
        return 'Chuqur va tinch — vaqti zich odamga aniq, foydali gap.';
      case AgeGroup.senior:
        return 'Hurmat bilan, sekinroq — lekin "bobo" yoki "ota" deb murojaat qilma.';
    }
  }

  /// Professor bilan suhbat — Claude API'ga so'rov yuboradi
  Future<String> chat({
    required UserProfile profile,
    required List<Message> conversationHistory,
    required String userMessage,
  }) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');

    // Faqat oxirgi 10 ta xabar (kontekst va xarajatni cheklash uchun)
    final recent = conversationHistory.length > 10
        ? conversationHistory.sublist(conversationHistory.length - 10)
        : conversationHistory;

    final messages = [
      ...recent.map((m) => {
            'role': m.isFromProfessor ? 'assistant' : 'user',
            'content': m.text,
          }),
      {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': model,
      'max_tokens': 300,
      'system': _buildSystemPrompt(profile),
      'messages': messages,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        return _fallbackResponse(profile, statusCode: response.statusCode);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List;
      if (content.isEmpty) return _fallbackResponse(profile);
      final text = (content.first as Map<String, dynamic>)['text'] as String;
      return text.trim();
    } catch (e) {
      return _fallbackResponse(profile);
    }
  }

  /// Internet yoki API ishlamasa — oldindan tayyorlangan javoblar
  String _fallbackResponse(UserProfile profile, {int? statusCode}) {
    if (statusCode == 401) {
      return 'API kalit ishlamayapti. Sozlamalardan tekshirib chiqing.';
    }
    final fallbacks = [
      'Aloqa hozir uzilgan, ${profile.name}. Bir lahzadan keyin qaytaylik.',
      'Maryam bilan bir narsani tekshiryapmiz. Ozdan keyin javob beraman.',
      'Internet aloqasi tiklanmaguncha kuta turing.',
    ];
    return fallbacks[DateTime.now().millisecond % fallbacks.length];
  }

  /// Salomlashish — foydalanuvchi ilovani ochganda
  String greeting(UserProfile profile) {
    final greetings = [
      'Salom, ${profile.name}. Boshlaymizmi?',
      'Xush kelibsiz, ${profile.name}. Bugun nima ustida ishlaymiz?',
      '${profile.name}, kelganingdan xursandman. Maryam ham yonimda.',
    ];
    return greetings[DateTime.now().day % greetings.length];
  }
}
