import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> firstInstituteGroups = [
    '1132', '1135', '1136', '1137', '1145',
    '1211', '1212', '1222', '1223', '1224', '1231', '1232', '1233', '1241', '1242', '1243', '1245',
    '1311', '1313', '1321', '1322', '1323', '1331', '1332', '1333', '1334', '1335', '1341', '1342', '1343', '1346',
    '1410м', '1411', '1412', '1421', '1422', '1423', '1423м', '1425', '1426м', '1430м', '1431', '1432', '1433', '1435', '1438', '1440м', '1441', '1442', '1443', '1445', '1446',
    '1510м', '1511', '1512', '1522', '1523', '1523м', '1524', '1526м', '1530м', '1531', '1532', '1533', '1535', '1538', '1539', '1540м', '1541', '1542', '1543', '1545', '1546'
  ];

  static const List<String> weekDays = [
    'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'
  ];

  static const Color upperWeekColor = Colors.red;
  static const Color lowerWeekColor = Colors.blue;
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFf093fb),
      Color(0xFFf5576c),
    ],
  );

  static const Map<String, Color> lessonTypes = {
    'лек': Color(0xFF4CAF50),    // Зеленый для лекций
    'пр': Color(0xFF2196F3),     // Синий для практик
    'лаб': Color(0xFFFF9800),    // Оранжевый для лабораторных
    'зач': Color(0xFF9C27B0),    // Фиолетовый для зачетов
    'экз': Color(0xFFF44336),    // Красный для экзаменов
    'кр': Color(0xFFE91E63),     // Розовый для курсовых
    'л': Color(0xFF4CAF50),      // Зеленый для лекций (сокращенно)
    'п': Color(0xFF2196F3),      // Синий для практик (сокращенно)
    'лр': Color(0xFFFF9800),     // Оранжевый для лабораторных (сокращенно)
  };
}
