import 'package:flutter/material.dart';
import 'package:flutter_appk/cores/constants.dart';
import '../../cores/constants.dart';
import '../../models/task.dart';
import '../../services/api_services.dart';
import 'package:flutter/material.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  late Future<List<Task>> _future;
  late DateTime _month; // tanggal 1 bulan yang tampil
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
    _future = ApiService.fetchTasks();
  }

  void _reload() => setState(() => _future = ApiService.fetchTasks());

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  void _goToday() {
    final n = DateTime.now();
    setState(() {
      _month = DateTime(n.year, n.month, 1);
      _selected = DateTime(n.year, n.month, n.day);
    });
  }

  Future<void> _complete(Task t) async {
    await ApiService.completeTask(t.id);
    _reload();
  }

  // ---------- HEADER ----------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Column(
              children: [
                Text(_months[_month.month - 1],
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                Text('${_month.year}',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right)),
          TextButton(onPressed: _goToday, child: const Text('Hari ini')),
        ],
      ),
    );
  }

  Widget _weekdayRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: _days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: d == 'Min'
                                ? Colors.red.shade300
                                : Colors.grey.shade600)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ---------- GRID TANGGAL ----------
  Widget _cell(DateTime? date, Map<String, List<Task>> byDate) {
    if (date == null) return const Expanded(child: SizedBox(height: 50));

    final selected = _key(date) == _key(_selected);
    final today = _isToday(date);
    final tasks = byDate[_key(date)] ?? [];
    final allDone = tasks.isNotEmpty && tasks.every((t) => t.isCompleted);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selected = date),
        child: SizedBox(
          height: 50,
          child: Center(
            child: Container(
              width: 42,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? kBlue : null,
                borderRadius: BorderRadius.circular(14),
                border: today && !selected
                    ? Border.all(color: kBlue, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${date.day}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : (date.weekday == 7
                                  ? Colors.red.shade400
                                  : null))),
                  const SizedBox(height: 3),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tasks.isEmpty
                          ? Colors.transparent
                          : (selected
                              ? Colors.white
                              : (allDone ? Colors.green : kBlue)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(Map<String, List<Task>> byDate) {
    final first = _month;
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final offset = first.weekday - 1; // Senin = 0

    final cells = <DateTime?>[
      for (int i = 0; i < offset; i++) null,
      for (int d = 1; d <= daysInMonth; d++)
        DateTime(first.year, first.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          for (int r = 0; r < cells.length; r += 7)
            Row(children: [
              for (int c = 0; c < 7; c++) _cell(cells[r + c], byDate),
            ]),
        ],
      ),
    );
  }

  // ---------- DAFTAR TUGAS HARI TERPILIH ----------
  Widget _taskTile(Task t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
            left: BorderSide(
                color: t.isCompleted ? Colors.green : kBlue, width: 4)),
      ),
      child: ListTile(
        leading: Checkbox(
          value: t.isCompleted,
          shape: const CircleBorder(),
          onChanged: t.isCompleted ? null : (_) => _complete(t),
        ),
        title: Text(
          t.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: t.isCompleted ? Colors.grey : null,
            decoration: t.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text([
          if (t.category != null) t.category!,
          if (t.reminderTime != null) '⏰ ${t.reminderTime}',
        ].join('  •  ')),
      ),
    );
  }

  Widget _dayList(List<Task> tasks) {
    final title =
        '${_dayNames[_selected.weekday - 1]}, ${_selected.day} ${_months[_selected.month - 1]} ${_selected.year}';

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              Text('${tasks.length} tugas',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                Icon(Icons.event_available,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('Tidak ada tugas di tanggal ini',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          )
        else
          ...tasks.map(_taskTile),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: FutureBuilder<List<Task>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${snap.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _reload, child: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }

          final byDate = <String, List<Task>>{};
          for (final t in snap.data!) {
            if (t.dueDate == null || t.dueDate!.length < 10) continue;
            byDate.putIfAbsent(t.dueDate!.substring(0, 10), () => []).add(t);
          }

          return Column(
            children: [
              _header(),
              _weekdayRow(),
              _grid(byDate),
              Expanded(child: _dayList(byDate[_key(_selected)] ?? [])),
            ],
          );
        },
      ),
    );
  }
}