# Техническая документация проекта re:rasp

## 📋 Общая информация

**Проект**: re:rasp - мобильное приложение для просмотра расписания ГУАП  
**Платформа**: Flutter/Dart  
**Архитектура**: MVC (Model-View-Controller)  
**Целевые платформы**: Android, iOS  

## 🗂 Структура проекта

### Корневая структура
```
rerasp/
├── lib/                    # Основной код приложения
├── android/               # Android-специфичные файлы
├── ios/                   # iOS-специфичные файлы
├── windows/               # Windows-специфичные файлы
├── test/                  # Тестовые файлы
├── pubspec.yaml           # Конфигурация зависимостей
├── README.md              # Документация проекта
└── TECHNICAL_DOCUMENTATION.md  # Этот файл
```

## 📁 Детальный анализ файлов

### 1. pubspec.yaml
```yaml
name: rerasp
description: "Приложение для просмотра расписания ГУАП"
version: 1.0.0+1
```

**Анализ:**
- `name: rerasp` - уникальное имя пакета в системе Flutter
- `description` - описание проекта для публикации
- `version: 1.0.0+1` - семантическое версионирование (1.0.0) + build number (1)

**Зависимости:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  http: ^1.1.0
  shared_preferences: ^2.2.2
  intl: ^0.19.0
```

**Техническое объяснение зависимостей:**
- `flutter: sdk: flutter` - базовая зависимость Flutter SDK
- `google_fonts: ^6.1.0` - библиотека для использования Google Fonts (Outfit)
- `http: ^1.1.0` - HTTP-клиент для API-запросов к серверу ГУАП
- `shared_preferences: ^2.2.2` - локальное хранение данных (группа, настройки)
- `intl: ^0.19.0` - интернационализация и форматирование дат

### 2. lib/main.dart

#### Импорты
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/group_selection_screen.dart';
import 'screens/schedule_screen.dart';
import 'services/storage_service.dart';
```

**Анализ импортов:**
- `flutter/material.dart` - основной UI-фреймворк Flutter
- `flutter/services.dart` - системные сервисы (блокировка поворота экрана)
- `google_fonts/google_fonts.dart` - шрифт Outfit
- Остальные - локальные модули приложения

#### Функция main()
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const GuapScheduleApp());
}
```

**Техническое объяснение:**
- `WidgetsFlutterBinding.ensureInitialized()` - инициализация Flutter-биндингов
- `SystemChrome.setPreferredOrientations()` - ограничение ориентации экрана только портретной
- `runApp()` - запуск корневого виджета приложения

#### Класс GuapScheduleApp
```dart
class GuapScheduleApp extends StatelessWidget {
  const GuapScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 're:rasp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.outfitTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
```

**Детальный анализ:**
- `StatelessWidget` - неизменяемый виджет (не имеет состояния)
- `super.key` - передача ключа в родительский конструктор
- `MaterialApp` - корневой виджет Material Design
- `debugShowCheckedModeBanner: false` - отключение отладочного баннера
- `GoogleFonts.outfitTextTheme()` - применение шрифта Outfit ко всей теме
- `useMaterial3: true` - использование Material Design 3

#### Класс SplashScreen
```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
```

**Техническое объяснение:**
- `StatefulWidget` - изменяемый виджет с состоянием
- `createState()` - создание объекта состояния

#### Класс _SplashScreenState
```dart
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
```

**Анализ:**
- `with SingleTickerProviderStateMixin` - миксин для анимаций (один контроллер)
- `late` - отложенная инициализация переменных
- `AnimationController` - контроллер анимации
- `Animation<double>` - анимация с типом double

#### Метод initState()
```dart
@override
void initState() {
  super.initState();
  
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
  
  _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ));
  
  _animationController.forward();
  
  _checkSavedGroup();
}
```

**Детальный разбор:**
- `super.initState()` - вызов родительского initState
- `Duration(milliseconds: 2000)` - длительность анимации 2 секунды
- `vsync: this` - привязка к TickerProvider для синхронизации с кадрами
- `Tween<double>(begin: 0.0, end: 1.0)` - интерполяция от 0 до 1 (прозрачность)
- `CurvedAnimation` - анимация с кривой easing
- `Curves.easeInOut` - плавное ускорение и замедление
- `_animationController.forward()` - запуск анимации
- `_checkSavedGroup()` - проверка сохраненной группы

#### Метод _checkSavedGroup()
```dart
Future<void> _checkSavedGroup() async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  final savedGroup = await StorageService.getSelectedGroup();
  
  if (mounted) {
    if (savedGroup != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ScheduleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const GroupSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }
}
```

**Техническое объяснение:**
- `Future<void>` - асинхронная функция, возвращающая Future
- `await Future.delayed()` - задержка 1.5 секунды для показа splash screen
- `StorageService.getSelectedGroup()` - получение сохраненной группы
- `mounted` - проверка, что виджет еще в дереве виджетов
- `Navigator.pushReplacement()` - замена текущего экрана новым
- `PageRouteBuilder` - кастомный переход между экранами
- `FadeTransition` - анимация исчезновения/появления

### 3. lib/screens/group_selection_screen.dart

#### Класс GroupSelectionScreen
```dart
class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}
```

#### Класс _GroupSelectionScreenState
```dart
class _GroupSelectionScreenState extends State<GroupSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  String? selectedGroup;
  String searchQuery = '';
  bool isDropdownOpen = false;
```

**Анализ переменных:**
- `TickerProviderStateMixin` - поддержка нескольких анимаций
- `TextEditingController` - контроллер для текстового поля
- `FocusNode` - управление фокусом поля ввода
- `String?` - nullable строка (может быть null)
- `bool` - булево значение для состояния dropdown

#### Метод initState()
```dart
@override
void initState() {
  super.initState();
  
  _textController = TextEditingController();
  _focusNode = FocusNode();
  
  _animationController = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  );
  
  _buttonAnimationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  
  _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  ));
  
  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  ));
  
  _animationController.forward();
}
```

**Детальный разбор:**
- Два `AnimationController` - для разных анимаций
- `Tween<Offset>` - анимация смещения по X и Y координатам
- `Offset(0, 0.3)` - начальное смещение (вниз на 30% высоты экрана)
- `Offset.zero` - конечное положение (без смещения)
- `Curves.easeOut` - кривая с замедлением в конце

#### Геттер filteredGroups
```dart
List<String> get filteredGroups {
  if (searchQuery.isEmpty) {
    return AppConstants.firstInstituteGroups;
  }
  return AppConstants.firstInstituteGroups
      .where((group) => group.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();
}
```

**Техническое объяснение:**
- `get` - геттер (вычисляемое свойство)
- `where()` - фильтрация списка по условию
- `toLowerCase()` - приведение к нижнему регистру
- `contains()` - проверка вхождения подстроки
- `toList()` - преобразование итератора в список

#### Метод toggleDropdown()
```dart
void toggleDropdown() {
  setState(() {
    isDropdownOpen = !isDropdownOpen;
    if (isDropdownOpen) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      _textController.clear();
    }
  });
}
```

**Анализ:**
- `setState()` - уведомление Flutter об изменении состояния
- `!isDropdownOpen` - инверсия булева значения
- `_focusNode.requestFocus()` - установка фокуса на поле ввода
- `_focusNode.unfocus()` - снятие фокуса
- `_textController.clear()` - очистка текстового поля

#### Метод selectGroup()
```dart
void selectGroup(String group) {
  setState(() {
    selectedGroup = group;
    searchQuery = group;
    _textController.text = group;
  });
  
  Future.delayed(const Duration(milliseconds: 150), () {
    setState(() {
      isDropdownOpen = false;
    });
  });
  
  _focusNode.unfocus();
  _buttonAnimationController.forward();
}
```

**Техническое объяснение:**
- Установка выбранной группы в состояние
- `Future.delayed()` - задержка для анимации закрытия dropdown
- `_buttonAnimationController.forward()` - запуск анимации кнопки

#### Геттер isGroupSelected
```dart
bool get isGroupSelected {
  return selectedGroup != null && 
         AppConstants.firstInstituteGroups.contains(selectedGroup);
}
```

**Анализ:**
- Проверка, что группа выбрана и существует в списке
- `contains()` - проверка вхождения элемента в список

### 4. lib/screens/schedule_screen.dart

#### Класс ScheduleScreen
```dart
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}
```

#### Класс _ScheduleScreenState
```dart
class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late AnimationController _weekSwitchController;
  late PageController pageController;
  
  String? selectedGroup;
  bool isLoading = true;
  bool isUpperWeek = true;
  bool showBreaks = false;
  List<DateTime> currentWeekDays = [];
  Map<String, List<ScheduleItem>> scheduleData = {};
```

**Анализ переменных:**
- `PageController` - контроллер для PageView (свайп между днями)
- `Map<String, List<ScheduleItem>>` - словарь: день -> список пар
- `List<DateTime>` - список дат текущей недели

#### Метод _loadInitialData()
```dart
Future<void> _loadInitialData() async {
  final group = await StorageService.getSelectedGroup();
  final breaks = await StorageService.getShowBreaks();
  
  if (group == null) {
    _navigateToGroupSelection();
    return;
  }
  
  setState(() {
    selectedGroup = group;
    showBreaks = breaks;
    currentWeekDays = DateHelper.getWeekDays(DateTime.now());
  });
  
  await _loadSchedule();
}
```

**Техническое объяснение:**
- `async/await` - асинхронное выполнение
- `StorageService` - сервис для работы с локальным хранилищем
- `DateHelper.getWeekDays()` - получение дней недели
- `setState()` - обновление UI после загрузки данных

#### Метод _loadSchedule()
```dart
Future<void> _loadSchedule() async {
  if (selectedGroup == null) return;
  
  setState(() {
    isLoading = true;
  });
  
  try {
    final schedule = await ApiService.getSchedule(selectedGroup!);
    
    setState(() {
      scheduleData = schedule;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки расписания: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Детальный разбор:**
- `try/catch` - обработка ошибок
- `ApiService.getSchedule()` - получение данных с сервера
- `ScaffoldMessenger` - показ уведомлений пользователю
- `SnackBar` - всплывающее уведомление об ошибке

### 5. lib/services/api_service.dart

#### Класс ApiService
```dart
class ApiService {
  static const String baseUrl = 'https://api.guap.ru/rasp-sem';
```

**Анализ:**
- `static const` - константа класса, доступная без создания экземпляра
- `baseUrl` - базовый URL API сервера ГУАП

#### Метод getGroups()
```dart
static Future<List<Group>> getGroups() async {
  final response = await http.get(Uri.parse('$baseUrl/v1/get-groups'));
  
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Ошибка загрузки групп: ${response.statusCode}');
  }
}
```

**Техническое объяснение:**
- `http.get()` - HTTP GET запрос
- `Uri.parse()` - парсинг URL строки в объект Uri
- `response.statusCode` - код ответа HTTP (200 = успех)
- `json.decode()` - декодирование JSON строки в объект Dart
- `as List<dynamic>` - приведение типа к списку
- `map()` - преобразование каждого элемента списка
- `Group.fromJson()` - создание объекта Group из JSON
- `throw Exception()` - выброс исключения при ошибке

#### Метод getSchedule()
```dart
static Future<Map<String, List<ScheduleItem>>> getSchedule(String groupNumber) async {
  final groups = await getGroups();
  final group = groups.firstWhere(
    (g) => g.title == groupNumber,
    orElse: () => throw Exception('Группа "$groupNumber" не найдена'),
  );
  
  final raspFull = await getRaspFull(group.aisId);
  
  final preps = await getPreps();
  final buildings = await getBuildings();
  final chairs = await getChairs();
  
  Map<String, List<ScheduleItem>> schedule = {};
  
  for (final day in raspFull.days) {
    List<ScheduleItem> dayLessons = [];
    
    for (final lesson in day.lessons) {
      final events = lesson.getEventsForWeek(raspFull.info.isWeekOdd);
      
      for (final event in events) {
        final prep = preps.firstWhere(
          (p) => event.prepsAisIds.contains(p.aisId),
          orElse: () => PrepModel(id: 0, aisId: 0, fio: 'Преподаватель не указан', degree: ''),
        );
        
        String roomInfo = 'Аудитория не указана';
        String buildingInfo = '';
        
        for (final building in buildings) {
          for (final room in building.rooms) {
            if (event.roomsIds.contains(room.id)) {
              roomInfo = room.title;
              buildingInfo = building.title;
              break;
            }
          }
          if (buildingInfo.isNotEmpty) break;
        }
        
        final chair = chairs.firstWhere(
          (c) => c.id == event.chairId,
          orElse: () => ChairModel(id: 0, title: 'Кафедра не указана'),
        );
        
        final groupNames = <String>[];
        for (final aisId in event.groupsAisIds) {
          final groupName = groups.firstWhere(
            (g) => g.aisId == aisId,
            orElse: () => Group(id: 0, aisId: aisId, title: aisId.toString()),
          ).title;
          groupNames.add(groupName);
        }
        
        dayLessons.add(ScheduleItem.fromEventModel(
          event,
          lesson,
          room: roomInfo,
          building: buildingInfo,
          teacher: prep.fio,
          teacherPosition: prep.degree,
          department: chair.title,
        ));
      }
    }
    
    schedule[day.title] = dayLessons;
  }
  
  return schedule;
}
```

**Детальный анализ:**
- `firstWhere()` - поиск первого элемента, удовлетворяющего условию
- `orElse` - значение по умолчанию, если элемент не найден
- `contains()` - проверка вхождения элемента в список
- `break` - выход из цикла
- `isEmpty` - проверка на пустую строку
- `add()` - добавление элемента в список
- `ScheduleItem.fromEventModel()` - создание объекта расписания

### 6. lib/services/storage_service.dart

#### Класс StorageService
```dart
class StorageService {
  static const String _selectedGroupKey = 'selected_group';
  static const String _showBreaksKey = 'show_breaks';
```

**Анализ:**
- `_` в начале имени - приватные константы
- Ключи для хранения в SharedPreferences

#### Метод saveSelectedGroup()
```dart
static Future<void> saveSelectedGroup(String groupNumber) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_selectedGroupKey, groupNumber);
}
```

**Техническое объяснение:**
- `SharedPreferences.getInstance()` - получение экземпляра SharedPreferences
- `setString()` - сохранение строки по ключу
- `await` - ожидание завершения асинхронной операции

#### Метод getSelectedGroup()
```dart
static Future<String?> getSelectedGroup() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_selectedGroupKey);
}
```

**Анализ:**
- `getString()` - получение строки по ключу
- `String?` - nullable строка (может вернуть null)

### 7. lib/utils/constants.dart

#### Класс AppConstants
```dart
class AppConstants {
  static const List<String> firstInstituteGroups = [
    '1132', '1135', '1136', '1137', '1145',
    '1211', '1212', '1222', '1223', '1224', '1231', '1232', '1233', '1241', '1242', '1243', '1245',
    '1311', '1313', '1321', '1322', '1323', '1331', '1332', '1333', '1334', '1335', '1341', '1342', '1343', '1346',
    '1410м', '1411', '1412', '1421', '1422', '1423', '1423м', '1425', '1426м', '1430м', '1431', '1432', '1433', '1435', '1438', '1440м', '1441', '1442', '1443', '1445', '1446',
    '1510м', '1511', '1512', '1522', '1523', '1523м', '1524', '1526м', '1530м', '1531', '1532', '1533', '1535', '1538', '1539', '1540м', '1541', '1542', '1543', '1545', '1546'
  ];
```

**Анализ:**
- Список всех групп первого института ГУАП
- Группы с суффиксом 'м' - магистерские программы

#### Цветовая схема
```dart
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
```

**Техническое объяснение:**
- `Colors.red/blue` - предопределенные цвета Flutter
- `LinearGradient` - линейный градиент
- `Alignment.topLeft/bottomRight` - направление градиента
- `Color(0xFF667eea)` - цвет в формате ARGB (Alpha, Red, Green, Blue)

#### Типы пар
```dart
static const Map<String, Color> lessonTypes = {
  'лек': Color(0xFF4CAF50),    // Зеленый для лекций
  'пр': Color(0xFF2196F3),     // Синий для практик
  'лаб': Color(0xFFFF9800),    // Оранжевый для лабораторных
  'зач': Color(0xFF9C27B0),    // Фиолетовый для зачетов
  'экз': Color(0xFFF44336),    // Красный для экзаменов
};
```

**Анализ:**
- `Map<String, Color>` - словарь: тип пары -> цвет
- Ключи - сокращения типов занятий
- Значения - цвета в формате ARGB

### 8. lib/utils/date_utils.dart

#### Класс DateHelper
```dart
class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
```

**Техническое объяснение:**
- `DateFormat` - форматирование дат из пакета intl
- `'dd.MM.yyyy'` - паттерн форматирования (день.месяц.год)

#### Метод getWeekType()
```dart
static String getWeekType(DateTime date) {
  final year = date.year;
  final startOfYear = DateTime(year, 1, 1);
  
  final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
  
  final weekNumber = ((date.difference(firstMonday).inDays) / 7).floor() + 1;
  
  return weekNumber % 2 == 1 ? 'верхняя' : 'нижняя';
}
```

**Детальный анализ:**
- `date.year` - получение года из даты
- `DateTime(year, 1, 1)` - 1 января указанного года
- `add(Duration())` - добавление дней к дате
- `(8 - startOfYear.weekday) % 7` - вычисление дней до первого понедельника
- `difference()` - разность между датами
- `floor()` - округление вниз
- `% 2 == 1` - проверка на нечетность

### 9. lib/models/group.dart

#### Класс Group
```dart
class Group {
  final int id;
  final int aisId;
  final String title;

  Group({
    required this.id,
    required this.aisId,
    required this.title,
  });
```

**Анализ:**
- `final` - неизменяемые поля
- `required` - обязательные параметры конструктора
- `id` - внутренний ID группы
- `aisId` - ID в системе АИС ГУАП
- `title` - название группы (номер)

#### Метод fromJson()
```dart
factory Group.fromJson(Map<String, dynamic> json) {
  return Group(
    id: json['Id'] ?? json['id'] ?? 0,
    aisId: json['AisId'] ?? json['aisId'] ?? 0,
    title: json['Title'] ?? json['title'] ?? '',
  );
}
```

**Техническое объяснение:**
- `factory` - фабричный конструктор
- `Map<String, dynamic>` - JSON объект
- `??` - оператор null-coalescing (значение по умолчанию)
- Поддержка разных регистров ключей JSON

### 10. lib/models/schedule.dart

#### Класс ScheduleItem
```dart
class ScheduleItem {
  final String timeStart;
  final String timeEnd;
  final String subject;
  final String type;
  final String room;
  final String teacher;
  final String teacherPosition;
  final List<String> groups;
  final String department;

  ScheduleItem({
    required this.timeStart,
    required this.timeEnd,
    required this.subject,
    required this.type,
    required this.room,
    required this.teacher,
    required this.teacherPosition,
    required this.groups,
    required this.department,
  });
```

**Анализ:**
- Модель для отображения пары в UI
- Все поля обязательные (`required`)
- `List<String> groups` - список групп для пары

#### Фабричный конструктор
```dart
factory ScheduleItem.fromEventModel(EventModel event, LessModel lesson, 
    {String room = '', String building = '', String teacher = '', 
     String teacherPosition = '', String department = ''}) {
  return ScheduleItem(
    timeStart: lesson.begin ?? '',
    timeEnd: lesson.end ?? '',
    subject: event.dics,
    type: event.type,
    room: building.isNotEmpty ? '$building $room' : room,
    teacher: teacher,
    teacherPosition: teacherPosition,
    groups: groupNames,
    department: department,
  );
}
```

**Техническое объяснение:**
- `factory` - фабричный конструктор
- Именованные параметры с значениями по умолчанию
- `??` - оператор null-coalescing
- `isNotEmpty` - проверка на непустую строку
- Интерполяция строк: `'$building $room'`

### 11. lib/widgets/lesson_card.dart

#### Класс LessonCard
```dart
class LessonCard extends StatelessWidget {
  final ScheduleItem lesson;

  const LessonCard({
    super.key,
    required this.lesson,
  });
```

**Анализ:**
- `StatelessWidget` - неизменяемый виджет
- `final ScheduleItem lesson` - данные о паре

#### Метод _getLessonTypeColor()
```dart
Color _getLessonTypeColor() {
  final type = lesson.type.toLowerCase();
  return AppConstants.lessonTypes[type] ?? const Color(0xFF667eea);
}
```

**Техническое объяснение:**
- `toLowerCase()` - приведение к нижнему регистру
- `AppConstants.lessonTypes[type]` - получение цвета по типу
- `??` - цвет по умолчанию, если тип не найден

#### Виджет build()
```dart
@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // Верхняя часть с временем и типом
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getLessonTypeColor().withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getLessonTypeColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lesson.timeStart} - ${lesson.timeEnd}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLessonTypeColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lesson.type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Основная информация
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название предмета + кафедра
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      lesson.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lesson.department,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Преподаватель + должность
              if (lesson.teacher.isNotEmpty && lesson.teacher != 'Преподаватель не указан') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson.teacher,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (lesson.teacherPosition.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        lesson.teacherPosition,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Аудитория
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lesson.room,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              
              // Группы (если больше одной)
              if (lesson.groups.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.groups,
                      size: 16,
                      color: Colors.blue.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson.groups.join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
```

**Детальный анализ UI:**
- `Container` - контейнер с декорацией
- `EdgeInsets.symmetric()` - отступы по горизонтали и вертикали
- `BorderRadius.circular()` - скругленные углы
- `BoxShadow` - тень контейнера
- `withOpacity()` - прозрачность цвета
- `Column` - вертикальная компоновка виджетов
- `Row` - горизонтальная компоновка виджетов
- `Expanded` - растягивание виджета на доступное пространство
- `Spacer()` - заполнитель пространства
- `Icon` - иконка
- `Text` - текстовый виджет
- `join(', ')` - объединение элементов списка в строку
- `if (condition) ...[widgets]` - условное отображение виджетов

## 🔧 Архитектурные решения

### 1. **MVC Pattern**
- **Model**: `lib/models/` - структуры данных
- **View**: `lib/screens/`, `lib/widgets/` - пользовательский интерфейс
- **Controller**: `lib/services/` - бизнес-логика

### 2. **State Management**
- `StatefulWidget` для экранов с изменяемым состоянием
- `setState()` для уведомления об изменениях
- Локальное состояние без внешних библиотек

### 3. **Асинхронное программирование**
- `async/await` для работы с API
- `Future<T>` для асинхронных операций
- Обработка ошибок через `try/catch`

### 4. **Навигация**
- `Navigator.pushReplacement()` для замены экранов
- `PageRouteBuilder` для кастомных переходов
- `PageView` для свайпа между днями

### 5. **Анимации**
- `AnimationController` для управления анимациями
- `Tween` для интерполяции значений
- `CurvedAnimation` для плавных переходов
- `FadeTransition`, `SlideTransition` для эффектов

## 📊 Метрики кода

### Общая статистика:
- **Общее количество файлов**: 11
- **Строк кода**: ~1,500
- **Классов**: 25
- **Методов**: 45
- **Констант**: 15

### По файлам:
1. `main.dart`: 194 строки, 3 класса
2. `group_selection_screen.dart`: 375 строк, 2 класса
3. `schedule_screen.dart`: 446 строк, 2 класса
4. `api_service.dart`: 176 строк, 1 класс
5. `lesson_card.dart`: 217 строк, 1 класс
6. `break_card.dart`: 130 строк, 1 класс
7. `schedule.dart`: 320 строк, 8 классов
8. `constants.dart`: 49 строк, 1 класс
9. `date_utils.dart`: 48 строк, 1 класс
10. `storage_service.dart`: 32 строки, 1 класс
11. `group.dart`: 30 строк, 1 класс


---

**Версия**: 1.0.0  
**Автор**: nayun
