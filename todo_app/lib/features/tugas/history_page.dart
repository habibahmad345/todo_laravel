import 'package:flutter/material.dart';
import '../../cores/constants.dart';
import '../../models/task.dart';
import '../menu/menu_page.dart';

class HistoryPage extends StatelessWidget {
  final List<Task> tasks;
 const HistoryPage({super.key, required this.tasks});

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd-$m-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    // urutkan dari yang terbaru selesai
    final sorted = [...tasks]..sort((a, b) {
        final x = a.completedAt ?? DateTime(2000);
        final y = b.completedAt ?? DateTime(2000);
        return y.compareTo(x);
      });

    // kelompokkan per tanggal
    final groups = <String, List<Task>>{};
    for (final t in sorted) {
      final label =
          t.completedAt == null ? 'Tanpa tanggal' : _dateLabel(t.completedAt!);
      groups.putIfAbsent(label, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Riwayat tugas'),
        backgroundColor: kBg,
      ),
      body: sorted.isEmpty
          ? const Center(child: Text('Belum ada tugas yang selesai'))
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                for (final e in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Row(
                      children: [
                        Text(e.key,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text('${e.value.length} tugas',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  for (final t in e.value)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: const Border(
                            left: BorderSide(color: Colors.green, width: 4)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle,
                            color: Colors.green),
                        title: Text(t.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text([
                          if (t.category != null) t.category!,
                          if (t.dueDate != null) 'Tempo ${t.dueDate}',
                          if (t.completedAt != null)
                            'Selesai ${t.completedAt!.hour.toString().padLeft(2, '0')}:${t.completedAt!.minute.toString().padLeft(2, '0')}',
                        ].join('  •  ')),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}
