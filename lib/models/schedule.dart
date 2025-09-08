class InfoModel {
  final String years;
  final bool isAutumn;
  final DateTime dateRelease;
  final DateTime dateImport;
  final int currentWeek;
  final bool isWeekOdd;
  final int currentDay;
  final int currentLess;
  final int pastLess;
  final int upcomingLess;
  final DateTime time;

  InfoModel({
    required this.years,
    required this.isAutumn,
    required this.dateRelease,
    required this.dateImport,
    required this.currentWeek,
    required this.isWeekOdd,
    required this.currentDay,
    required this.currentLess,
    required this.pastLess,
    required this.upcomingLess,
    required this.time,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      years: (json['years'] ?? json['Years'] ?? '').toString(),
      isAutumn: json['isAutumn'] ?? json['IsAutumn'] ?? false,
      dateRelease: DateTime.tryParse((json['dateRelease'] ?? json['DateRelease'] ?? '').toString()) ?? DateTime.now(),
      dateImport: DateTime.tryParse((json['dateImport'] ?? json['DateImport'] ?? '').toString()) ?? DateTime.now(),
      currentWeek: (json['currentWeek'] ?? json['CurrentWeek'] ?? 1) as int,
      isWeekOdd: json['isWeekOdd'] ?? json['IsWeekOdd'] ?? true, // Нечетная неделя (верхняя)
      currentDay: (json['currentDay'] ?? json['CurrentDay'] ?? 1) as int,
      currentLess: (json['currentLess'] ?? json['CurrentLess'] ?? 1) as int,
      pastLess: (json['pastLess'] ?? json['PastLess'] ?? 0) as int,
      upcomingLess: (json['upcomingLess'] ?? json['UpcomingLess'] ?? 0) as int,
      time: DateTime.tryParse((json['time'] ?? json['Time'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class EventModel {
  final int id;
  final String subgId;
  final int week;
  final String type;
  final String dics; // дисциплина
  final int chairId;
  final List<int> groupsAisIds;
  final List<int> prepsAisIds;
  final List<int> roomsIds;

  EventModel({
    required this.id,
    required this.subgId,
    required this.week,
    required this.type,
    required this.dics,
    required this.chairId,
    required this.groupsAisIds,
    required this.prepsAisIds,
    required this.roomsIds,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? json['Id'] ?? 0,
      subgId: json['subgId'] ?? json['SubgId'] ?? '',
      week: json['week'] ?? json['Week'] ?? 0,
      type: json['type'] ?? json['Type'] ?? '',
      dics: json['dics'] ?? json['Dics'] ?? '',
      chairId: json['chairId'] ?? json['ChairId'] ?? 0,
      groupsAisIds: List<int>.from((json['groupsAisIds'] ?? json['GroupsAisIds'] ?? []) as List<dynamic>),
      prepsAisIds: List<int>.from((json['prepsAisIds'] ?? json['PrepsAisIds'] ?? []) as List<dynamic>),
      roomsIds: List<int>.from((json['roomsIds'] ?? json['RoomsIds'] ?? []) as List<dynamic>),
    );
  }
}

class LessModel {
  final int less;
  final String? begin;
  final String? end;
  final List<EventModel> weekAll;
  final List<EventModel> week1;
  final List<EventModel> week2;

  LessModel({
    required this.less,
    this.begin,
    this.end,
    required this.weekAll,
    required this.week1,
    required this.week2,
  });

  factory LessModel.fromJson(Map<String, dynamic> json) {
    String? extractTime(dynamic timeData) {
      if (timeData == null) return null;
      if (timeData is String) {
        if (timeData.contains(':')) {
          final parts = timeData.split(':');
          if (parts.length >= 2) {
            return '${parts[0]}:${parts[1]}';
          }
        }
        try {
          final dateTime = DateTime.parse(timeData);
          return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          return timeData;
        }
      }
      return null;
    }

    return LessModel(
      less: json['less'] ?? json['Less'] ?? 0,
      begin: extractTime(json['begin'] ?? json['Begin']),
      end: extractTime(json['end'] ?? json['End']),
      weekAll: ((json['weekAll'] ?? json['WeekAll']) as List<dynamic>? ?? [])
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      week1: ((json['week1'] ?? json['Week1']) as List<dynamic>? ?? [])
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      week2: ((json['week2'] ?? json['Week2']) as List<dynamic>? ?? [])
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<EventModel> getEventsForWeek(bool isOddWeek) {
    if (weekAll.isNotEmpty) return weekAll;
    return isOddWeek ? week1 : week2;
  }
}

class DayModel {
  final int day;
  final String title;
  final List<LessModel> lessons;

  DayModel({
    required this.day,
    required this.title,
    required this.lessons,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      day: json['day'] ?? json['Day'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      lessons: ((json['lessons'] ?? json['Lessons']) as List<dynamic>? ?? [])
          .map((e) => LessModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RaspFullModel {
  final InfoModel info;
  final List<DayModel> days;

  RaspFullModel({
    required this.info,
    required this.days,
  });

  factory RaspFullModel.fromJson(Map<String, dynamic> json) {
    return RaspFullModel(
      info: InfoModel.fromJson(json['info'] ?? json['Info'] ?? {}),
      days: ((json['days'] ?? json['Days']) as List<dynamic>? ?? [])
          .map((e) => DayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PrepModel {
  final int id;
  final int aisId;
  final String fio;
  final String degree;

  PrepModel({
    required this.id,
    required this.aisId,
    required this.fio,
    required this.degree,
  });

  factory PrepModel.fromJson(Map<String, dynamic> json) {
    return PrepModel(
      id: json['id'] ?? json['Id'] ?? 0,
      aisId: json['aisId'] ?? json['AisId'] ?? 0,
      fio: json['fio'] ?? json['FIO'] ?? '',
      degree: json['degree'] ?? json['Degree'] ?? '',
    );
  }
}

class RoomModel {
  final int id;
  final String title;

  RoomModel({
    required this.id,
    required this.title,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? json['Id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
    );
  }
}

class BuildingModel {
  final int id;
  final String title;
  final List<RoomModel> rooms;

  BuildingModel({
    required this.id,
    required this.title,
    required this.rooms,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'] ?? json['Id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
      rooms: ((json['rooms'] ?? json['Rooms']) as List<dynamic>? ?? [])
          .map<RoomModel>((room) => RoomModel.fromJson(room as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChairModel {
  final int id;
  final String title;

  ChairModel({
    required this.id,
    required this.title,
  });

  factory ChairModel.fromJson(Map<String, dynamic> json) {
    return ChairModel(
      id: json['id'] ?? json['Id'] ?? 0,
      title: json['title'] ?? json['Title'] ?? '',
    );
  }
}

class ScheduleItem {
  final String timeStart;
  final String timeEnd;
  final String subject;
  final String type;
  final String room;
  final String building;
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
    required this.building,
    required this.teacher,
    required this.teacherPosition,
    required this.groups,
    required this.department,
  });

  factory ScheduleItem.fromEventModel(EventModel event, LessModel lesson, 
      {String room = '', String building = '', String teacher = '', 
       String teacherPosition = '', String department = ''}) {
    return ScheduleItem(
      timeStart: lesson.begin ?? '',
      timeEnd: lesson.end ?? '',
      subject: event.dics, // Название предмета
      type: event.type, // Тип пары (лек, пр, лаб)
      room: room,
      building: building, // Корпус
      teacher: teacher, // Преподаватель
      teacherPosition: teacherPosition, // Должность преподавателя
      groups: event.groupsAisIds.map((id) => id.toString()).toList(), // Список групп
      department: department, // Кафедра
    );
  }
}
