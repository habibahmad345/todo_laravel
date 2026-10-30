import 'package:flutter/material.dart';
import 'package:flutter_appk/cores/constants.dart';
import '../../cores/constants.dart';
import '../../models/task.dart';
import '../../services/api_services.dart';
import 'package:flutter/material.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _dayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  late Future<List<Task>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchTasks();
  }

  void _reload() => setState(() => _future = ApiService.fetchTasks());

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime? _due(Task t) {
    if (t.dueDate == null || t.dueDate!.length < 10) return null;
    return DateTime.tryParse(t.dueDate!.substring(0, 10));
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  // ---------- KARTU ----------
  Widget _card({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
  
  Widget _progressCard(int done, int total) {
    final pct = total == 0 ? 0.0 : done / total;
    const name = 'Habib';
    return _card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 9,
                    backgroundColor: kChip,
                    color: kBlue,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text('${(pct * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? _greeting() : '${_greeting()}, $name',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Belum ada tugas. Yuk mulai tambah.'
                      : '$done dari $total tugas selesai',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                Text(label,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stats(int total, int done, int active, int late) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: [
          Row(children: [
            _statCard(Icons.list_alt, kBlue, '$total', 'Total'),
            const SizedBox(width: 10),
            _statCard(Icons.check_circle, Colors.green, '$done', 'Selesai'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _statCard(
                Icons.pending_actions, Colors.orange, '$active', 'Aktif'),
            const SizedBox(width: 10),
            _statCard(Icons.warning_amber_rounded, Colors.red, '$late',
                'Terlambat'),
          ]),
        ],
      ),
    );
  }

  // ---------- GRAFIK 7 HARI ----------
  Widget _weekChart(List<Task> tasks) {
    final today = _today();
    final days = [for (int i = 6; i >= 0; i--) today.subtract(Duration(days: i))];

    final counts = days.map((d) {
      return tasks.where((t) {
        final c = t.completedAt;
        return c != null &&
            c.year == d.year &&
            c.month == d.month &&
            c.day == d.day;
      }).length;
    }).toList();

    final maxCount = counts.fold<int>(1, (m, c) => c > m ? c : m);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selesai 7 hari terakhir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < 7; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(counts[i] == 0 ? '' : '${counts[i]}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Container(
                          width: 22,
                          height: counts[i] == 0
                              ? 4
                              : 12 + 80 * counts[i] / maxCount,
                          decoration: BoxDecoration(
                            color: i == 6 ? kBlue : kChip,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_dayShort[days[i].weekday - 1],
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- PER KATEGORI ----------
  Widget _categoryProgress(List<Task> tasks) {
    final names = <String>{
      for (final t in tasks) t.category ?? 'Tanpa kategori',
    }.toList()
      ..sort();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Per kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (names.isEmpty)
            Text('Belum ada data',
                style: TextStyle(color: Colors.grey.shade600)),
          for (final n in names) ...[
            Builder(builder: (_) {
              final list =
                  tasks.where((t) => (t.category ?? 'Tanpa kategori') == n);
              final done = list.where((t) => t.isCompleted).length;
              final total = list.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(n,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('$done/$total',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 10,
                        backgroundColor: kChip,
                        color: n == 'Personal' ? Colors.orange : kBlue,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ---------- TUGAS MENDATANG ----------
  Widget _upcoming(List<Task> active) {
    final sorted = [...active]..sort((a, b) {
        final x = _due(a) ?? DateTime(2100);
        final y = _due(b) ?? DateTime(2100);
        return x.compareTo(y);
      });
    final top = sorted.take(3).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tugas mendatang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Tidak ada tugas aktif',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
          for (final t in top)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: kChip, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.event, color: kBlue, size: 20),
              ),
              title: Text(t.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text([
                if (t.dueDate != null) t.dueDate!,
                if (t.reminderTime != null) '⏰ ${t.reminderTime}',
              ].join('  •  ')),
            ),
        ],
      ),
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

          final tasks = snap.data!;
          final done = tasks.where((t) => t.isCompleted).length;
          final active = tasks.where((t) => !t.isCompleted).toList();
          final today = _today();
          final late = active.where((t) {
            final d = _due(t);
            return d != null && d.isBefore(today);
          }).length;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _progressCard(done, tasks.length),
                _stats(tasks.length, done, active.length, late),
                _weekChart(tasks),
                _categoryProgress(tasks),
                _upcoming(active),
              ],
            ),
          );
        },
      ),
    );
  }
}