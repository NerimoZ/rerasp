import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import 'schedule_screen.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedGroup;
  bool isDropdownOpen = false;
  String searchQuery = '';
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  List<String> get filteredGroups {
    if (searchQuery.isEmpty) {
      return AppConstants.firstInstituteGroups;
    }
    return AppConstants.firstInstituteGroups
        .where((group) => group.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void toggleDropdown() {
    setState(() {
      isDropdownOpen = !isDropdownOpen;
      if (isDropdownOpen) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
        searchQuery = '';
        _textController.clear();
      }
    });
  }

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

  bool get isGroupSelected {
    return selectedGroup != null && 
           AppConstants.firstInstituteGroups.contains(selectedGroup);
  }

  Future<void> _selectGroup() async {
    if (selectedGroup != null) {
      await StorageService.saveSelectedGroup(selectedGroup!);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ScheduleScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'rerasp',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    focusNode: _focusNode,
                                    onChanged: (value) {
                                      setState(() {
                                        searchQuery = value;
                                        if (value.isNotEmpty) {
                                          isDropdownOpen = true;
                                        }
                                        if (selectedGroup != null && selectedGroup != value) {
                                          selectedGroup = null;
                                          _buttonAnimationController.reset();
                                        }
                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        isDropdownOpen = true;
                                        _focusNode.requestFocus();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: isDropdownOpen 
                                          ? 'Введите номер группы...' 
                                          : 'Выберите группу',
                                      hintStyle: TextStyle(color: Colors.grey[600]),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: toggleDropdown,
                                  child: Icon(
                                    isDropdownOpen 
                                        ? Icons.keyboard_arrow_up 
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -0.1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: isDropdownOpen && filteredGroups.isNotEmpty
                                ? Column(
                                    key: const ValueKey('dropdown'),
                                    children: [
                                      const SizedBox(height: 8),
                                      Container(
                              constraints: const BoxConstraints(
                                maxHeight: 192, // 4 группы * 48px высота
                                minHeight: 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredGroups.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey.withOpacity(0.1),
                                  thickness: 0.5,
                                ),
                                itemBuilder: (context, index) {
                                  final group = filteredGroups[index];
                                  return InkWell(
                                    onTap: () => selectGroup(group),
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          group,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                                      ],
                                    )
                                : const SizedBox(
                                    key: ValueKey('empty'),
                                    height: 0,
                                  ),
                          ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: isGroupSelected
                      ? Container(
                          key: const ValueKey('button'),
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _selectGroup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF667eea),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              'Продолжить',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('empty'),
                          height: 50,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
