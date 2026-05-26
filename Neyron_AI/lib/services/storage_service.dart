import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/message.dart';

class StorageService {
  static const _kUserProfile = 'user_profile';
  static const _kChatHistory = 'chat_history';
  static const _kApiKey = 'api_key';
  static const _kLastActiveDate = 'last_active_date';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserProfile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveChatHistory(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    // Faqat oxirgi 50 ta xabar saqlanadi (xotira tejash)
    final toSave = messages.length > 50 ? messages.sublist(messages.length - 50) : messages;
    final encoded = jsonEncode(toSave.map((m) => m.toJson()).toList());
    await prefs.setString(_kChatHistory, encoded);
  }

  Future<List<Message>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kChatHistory);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kApiKey, key);
  }

  Future<String?> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kApiKey);
  }

  Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastActiveDate, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastActiveDate);
    if (raw == null) return null;
    return DateTime.parse(raw);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
