import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/lesson_card.dart';
import '../widgets/break_card.dart';
import 'group_selection_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController(initialPage: DateTime.now().weekday - 1);
  String? selectedGroup;
  bool showBreaks = false;
  bool isUpperWeek = true;
  Map<String, List<ScheduleItem>> scheduleData = {};
  bool isLoading = true;
  
  late AnimationController _weekSwitchController;

  @override
  void initState() {
    super.initState();
    
    _weekSwitchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _loadInitialData();
  }

  @override
  void dispose() {
    _weekSwitchController.dispose();
    pageController.dispose();
    super.dispose();
  }

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
      isUpperWeek = DateHelper.getWeekType(DateTime.now()) == 'верхняя';
    });
    
    await _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    if (selectedGroup == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final data = await ApiService.getSchedule(selectedGroup!, isUpperWeek: isUpperWeek);
      setState(() {
        scheduleData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToGroupSelection() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GroupSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _toggleWeekType() {
    print('Текущая неделя: ${isUpperWeek ? "Верхняя" : "Нижняя"}');
    _weekSwitchController.forward().then((_) {
      setState(() {
        isUpperWeek = !isUpperWeek;
        print('Переключили на: ${isUpperWeek ? "Верхняя" : "Нижняя"}');
      });
      _weekSwitchController.reverse();
      _loadSchedule();
    });
  }

  void _toggleBreaks() async {
    setState(() {
      showBreaks = !showBreaks;
    });
    await StorageService.saveShowBreaks(showBreaks);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedGroup == null) {
      return const GroupSelectionScreen();
    }

    final currentWeekDays = DateHelper.getWeekDays(DateTime.now());
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: isLoading
                    ? _buildLoadingIndicator()
                    : _buildScheduleContent(currentWeekDays),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentWeekType = DateHelper.getWeekType(DateTime.now());
    final isCurrentUpper = currentWeekType == 'верхняя';
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _navigateToGroupSelection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Группа $selectedGroup',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        DateHelper.formatDate(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isCurrentUpper ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: isCurrentUpper 
                            ? AppConstants.upperWeekColor 
                            : AppConstants.lowerWeekColor,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Row(
            children: [
              IconButton(
                onPressed: _toggleBreaks,
                icon: Icon(
                  showBreaks ? Icons.pause_circle : Icons.pause_circle_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              GestureDetector(
                onTap: _toggleWeekType,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUpperWeek
                        ? AppConstants.upperWeekColor
                        : AppConstants.lowerWeekColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isUpperWeek ? 'Верхняя' : 'Нижняя',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Загружаем расписание...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(List<DateTime> weekDays) {
    return PageView.builder(
      controller: pageController,
      itemCount: 6, // Понедельник - Суббота
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final day = weekDays[index];
        final dayName = DateHelper.getDayName(day);
        final lessonsForDay = scheduleData[dayName.toLowerCase()] ?? [];
        
        return _buildDaySchedule(day, lessonsForDay);
      },
    );
  }

  Widget _buildDaySchedule(DateTime day, List<ScheduleItem> lessons) {
    final currentWeekType = DateHelper.getWeekType(DateTime.now());
    final isCurrentWeek = (isUpperWeek && currentWeekType == 'верхняя') || 
                         (!isUpperWeek && currentWeekType == 'нижняя');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            child: Column(
              children: [
                Text(
                  DateHelper.getDayName(day),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: isCurrentWeek
                      ? Text(
                          DateHelper.formatDate(day),
                          key: const ValueKey('date-visible'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('date-hidden'),
                          height: 0,
                        ),
                ),
                if (DateHelper.isToday(day) && isCurrentWeek)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Сегодня',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: _buildNoLessonsWidget(),
            )
          else
            Expanded(
              child: _buildLessonsList(lessons),
            ),
        ],
      ),
    );
  }

  Widget _buildNoLessonsWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.free_breakfast,
            size: 50,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Занятий нет',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Можно отдохнуть!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList(List<ScheduleItem> lessons) {
    List<Widget> items = [];
    
    for (int i = 0; i < lessons.length; i++) {
      items.add(LessonCard(lesson: lessons[i]));
      
      if (showBreaks && i < lessons.length - 1) {
        items.add(BreakCard(
          startTime: lessons[i].timeEnd,
          endTime: lessons[i + 1].timeStart,
        ));
      }
      
      if (i < lessons.length - 1) {
        items.add(const SizedBox(height: 15));
      }
    }
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: items,
      ),
    );
  }

}
