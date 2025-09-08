import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group.dart';
import '../models/schedule.dart';

class ApiService {
  static const String baseUrl = 'https://api.guap.ru/rasp-sem';
  
  static Future<List<Group>> getGroups() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/get-groups')); // Запрос к API
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => Group.fromJson(json as Map<String, dynamic>)).toList(); // Парсим JSON
    } else {
      throw Exception('Ошибка загрузки групп: ${response.statusCode}');
    }
  }

  static List<Group> filterFirstInstituteGroups(List<Group> allGroups) {
    return allGroups.where((group) => group.title.startsWith('1')).toList(); // Фильтруем только первый институт
  }

  static Future<RaspFullModel> getRaspFull(int groupAisId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/get-rasp-full?groupAisId=$groupAisId') // Получаем полное расписание
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      return RaspFullModel.fromJson(data);
    } else {
      throw Exception('Ошибка загрузки расписания: ${response.statusCode}');
    }
  }

  static Future<InfoModel> getInfo() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/get-info'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      return InfoModel.fromJson(data);
    } else {
      throw Exception('Ошибка загрузки информации: ${response.statusCode}');
    }
  }

  static Future<List<PrepModel>> getPreps() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/get-preps'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => PrepModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Ошибка загрузки преподавателей: ${response.statusCode}');
    }
  }

  static Future<List<BuildingModel>> getBuildings() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/get-buildings'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => BuildingModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Ошибка загрузки аудиторий: ${response.statusCode}');
    }
  }

  static Future<List<ChairModel>> getChairs() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/get-chairs'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((json) => ChairModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Ошибка загрузки кафедр: ${response.statusCode}');
    }
  }

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
          
          final scheduleItem = ScheduleItem(
            timeStart: lesson.begin ?? '',
            timeEnd: lesson.end ?? '',
            subject: event.dics,
            type: event.type,
            room: roomInfo,
            building: buildingInfo,
            teacher: prep.fio,
            teacherPosition: prep.degree,
            groups: groupNames,
            department: chair.title,
          );
          dayLessons.add(scheduleItem);
        }
      }
      
      if (dayLessons.isNotEmpty) {
        schedule[day.title.toLowerCase()] = dayLessons;
      }
    }
    
    return schedule;
  }

  static String getWeekTypeFromInfo(InfoModel info) {
    return info.isWeekOdd ? 'верхняя' : 'нижняя';
  }

  static String getWeekType(DateTime date) {
    final weekNumber = ((date.difference(DateTime(date.year, 1, 1)).inDays) / 7).ceil();
    return weekNumber % 2 == 1 ? 'верхняя' : 'нижняя';
  }
  
  static int getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays;
    return ((dayOfYear / 7).ceil());
  }
}

