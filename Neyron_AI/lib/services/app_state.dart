import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/message.dart';
import 'storage_service.dart';
import 'ai_service.dart';
import 'i18n.dart';

/// Ilovaning global holati — Provider orqali tarqatiladi
class AppState extends ChangeNotifier {
  final StorageService storage = StorageService();

  UserProfile? _profile;
  List<Message> _messages = [];
  String? _apiKey;
  AiService? _ai;
  bool _isLoading = false;
  String _languageCode = I18n.deviceLanguage;
  bool _languageChosen = false;

  UserProfile? get profile => _profile;
  List<Message> get messages => List.unmodifiable(_messages);
  String? get apiKey => _apiKey;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;
  String get languageCode => _languageCode;
  bool get languageChosen => _languageChosen;

  /// Ilova ishga tushganda chaqiriladi
  Future<void> initialize() async {
    _profile = await storage.loadProfile();
    _messages = await storage.loadChatHistory();
    _apiKey = await storage.loadApiKey();
    final savedLang = await storage.loadLanguage();
    _languageCode = savedLang ?? I18n.deviceLanguage;
    _languageChosen = savedLang != null;
    I18n.override = _languageCode;
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _ai = AiService(apiKey: _apiKey!);
    }
    notifyListeners();
  }

  /// Tilni o'zgartirish (uz/ru/en) — butun ilova qayta render bo'ladi
  Future<void> setLanguage(String code) async {
    if (code != 'uz' && code != 'ru' && code != 'en') return;
    _languageCode = code;
    _languageChosen = true;
    I18n.override = code;
    await storage.saveLanguage(code);
    notifyListeners();
  }

  Future<void> setProfile(UserProfile profile) async {
    _profile = profile;
    await storage.saveProfile(profile);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    _ai = AiService(apiKey: key);
    await storage.saveApiKey(key);
    notifyListeners();
  }

  Future<void> incrementStreak() async {
    if (_profile == null) return;
    final today = DateTime.now();
    final last = await storage.getLastActive();

    int newStreak = _profile!.streakDays;
    if (last == null) {
      newStreak = 1;
    } else {
      final daysDiff = today.difference(DateTime(last.year, last.month, last.day)).inDays;
      if (daysDiff == 1) {
        newStreak += 1;
      } else if (daysDiff > 1) {
        newStreak = 1; // streak buzildi
      }
      // daysDiff == 0 → bugun allaqachon kirgan, o'zgarmaydi
    }

    await storage.updateLastActive();
    _profile = _profile!.copyWith(streakDays: newStreak);
    await storage.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> incrementSessions() async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(totalSessions: _profile!.totalSessions + 1);
    await storage.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(coins: _profile!.coins + amount);
    await storage.saveProfile(_profile!);
    notifyListeners();
  }

  /// Professor bilan suhbat
  Future<void> sendMessage(String text) async {
    if (_profile == null) return;

    final userMsg = Message(text: text, role: MessageRole.user);
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    String reply;
    if (_ai != null) {
      reply = await _ai!.chat(
        profile: _profile!,
        conversationHistory: _messages.sublist(0, _messages.length - 1),
        userMessage: text,
      );
    } else {
      reply = 'API kaliti hali kiritilmagan, ${_profile!.name}. Pasportdan kiritsangiz, suhbatni boshlaymiz.';
    }

    final professorMsg = Message(text: reply, role: MessageRole.professor);
    _messages.add(professorMsg);
    _isLoading = false;

    await storage.saveChatHistory(_messages);
    notifyListeners();
  }

  /// Professor salomlashuvi
  String greeting() {
    if (_profile == null) return 'Salom.';
    if (_ai != null) return _ai!.greeting(_profile!);
    return 'Salom, ${_profile!.name}. Boshlaymizmi?';
  }

  Future<void> reset() async {
    await storage.clearAll();
    _profile = null;
    _messages = [];
    _apiKey = null;
    _ai = null;
    notifyListeners();
  }
}
