import 'package:flutter/material.dart';

import 'cores/constants.dart';
import 'features/tugas/tasks_page.dart';
import 'features/kalender/calender_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/menu/menu_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: kBlue, useMaterial3: true),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _tasksKey = GlobalKey<TasksPageState>();

  late final List<Widget> _pages = [
    TasksPage(key: _tasksKey),
    const CalenderPage(),
    const DashboardPage(),
    const MenuPage(),
  ];

  Widget _navItem(IconData icon, String label, int index) {
    final active = _index == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? kBlue : Colors.grey.shade600),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? const Color.fromARGB(255, 59, 112, 186) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      extendBody: true,
      body: SafeArea(
        child: IndexedStack(index: _index, children: _pages),
      ),
      floatingActionButton: 
         SizedBox(
           width: 68,
           height: 68,
          child: FloatingActionButton(
            onPressed: () {
              setState(() => _index = 0);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _tasksKey.currentState?.addTask(),
              );
            },
            backgroundColor: kBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 36),
          ),
        ), 
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
          
            children: [
              _navItem(Icons.checklist, 'Tugas', 0),
              _navItem(Icons.calendar_today_outlined, 'Kalender', 1),
              const SizedBox(width: 80),
              _navItem(Icons.dashboard_outlined, 'Dasbor', 2),
              _navItem(Icons.menu, 'Menu', 3),
            ],
          ),
        ),
      ),
    );
  }
}