import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _selectedGroupKey = 'selected_group';
  static const String _showBreaksKey = 'show_breaks';
  
  static Future<void> saveSelectedGroup(String groupNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedGroupKey, groupNumber); // Сохраняем выбранную группу
  }
  
  static Future<String?> getSelectedGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedGroupKey); // Получаем сохраненную группу
  }
  
  static Future<void> saveShowBreaks(bool showBreaks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showBreaksKey, showBreaks); // Сохраняем настройку перерывов
  }
  
  static Future<bool> getShowBreaks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showBreaksKey) ?? false; // Получаем настройку перерывов
  }
  
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
