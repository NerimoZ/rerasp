import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
  
  static String getDayName(DateTime date) {
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    ];
    return days[date.weekday - 1];
  }
  
  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
  
  static List<DateTime> getWeekDays(DateTime date) {
    final weekStart = getWeekStart(date);
    return List.generate(6, (index) => weekStart.add(Duration(days: index)));
  }
  
  static String getWeekType(DateTime date) {
    final year = date.year;
    final startOfYear = DateTime(year, 1, 1);
    
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    
    final weekNumber = ((date.difference(firstMonday).inDays) / 7).floor() + 1;
    
    return weekNumber % 2 == 1 ? 'верхняя' : 'нижняя';
  }
  
  static int getWeekNumber(DateTime date) {
    final year = date.year;
    final startOfYear = DateTime(year, 1, 1);
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    
    return ((date.difference(firstMonday).inDays) / 7).floor() + 1;
  }
  
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
