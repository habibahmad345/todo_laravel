import 'package:flutter/material.dart';

import '../../cores/constants.dart';
import '../../models/task.dart';
import '../../services/api_services.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> {
  late Future<List<Task>> _future;
  String _category = 'All';

  final _categories = const [
    ('All', Icons.apps),
    ('Work', Icons.work),
    ('Personal', Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchTasks();
  }

  void _reload() => setState(() => _future = ApiService.fetchTasks());

  Future<void> _complete(Task t) async {
    await ApiService.completeTask(t.id);
    _reload();
  }

  Future<void> addTask() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Judul tugas'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;
    await ApiService.addTask(title, _category == 'Personal' ? 2 : 1);
    _reload();
  }

  Widget _categoryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((c) {
                  final selected = _category == c.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _category = c.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? kBlue : kChip,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(c.$2,
                                size: 20,
                                color: selected ? Colors.white : Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              c.$1,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'refresh') _reload();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'refresh', child: Text('Muat ulang')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: kChip.withOpacity(0.6),
              borderRadius: BorderRadius.circular(48),
            ),
            child: const Icon(Icons.checklist_rounded, size: 90, color: kBlue),
          ),
          const SizedBox(height: 32),
          const Text('Belum ada tugas di daftar ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Tambahkan tugas pertama atau pilih kategori lain.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: addTask,
            icon: const Icon(Icons.add),
            label: const Text('Tambah tugas'),
            style: FilledButton.styleFrom(
              backgroundColor: kBlue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readyCard(int doneToday) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: kChip, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.check_circle, size: 44, color: kBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Siap untuk hari ini',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Setiap tugas yang dijadwalkan hari ini selesai.',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: kChip, borderRadius: BorderRadius.circular(20)),
                  child: Text('$doneToday Selesai hari ini',
                      style: const TextStyle(
                          color: kBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Task t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: kBlue, width: 4)),
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
          if (t.dueDate != null) t.dueDate!,
          if (t.reminderTime != null) '⏰ ${t.reminderTime}',
        ].join('  •  ')),
        trailing: t.isPinned ? const Icon(Icons.push_pin_outlined) : null,
      ),
    );
  }

  Widget _sectionTitle(String text, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Text(text,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.shade50,
            child: Text('$count',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(int total) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman riwayat belum dibuat'))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.history, color: Colors.green, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lihat riwayat lengkap',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('$total menyelesaikan tugas',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _taskList() {
    return FutureBuilder<List<Task>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: ${snap.error}'),
            ),
          );
        }

        final all = snap.data!
            .where((t) => _category == 'All' || t.category == _category)
            .toList();
        final pending = all.where((t) => !t.isCompleted).toList();
        final doneToday = all.where((t) => t.completedToday).toList();
        final totalDone = all.where((t) => t.isCompleted).length;

        return ListView(
          children: [
            if (pending.isEmpty && doneToday.isEmpty) _emptyState(),
            if (pending.isEmpty && doneToday.isNotEmpty)
              _readyCard(doneToday.length),
            ...pending.map(_taskCard),
            if (doneToday.isNotEmpty) ...[
              _sectionTitle('Selesai hari ini', doneToday.length),
              ...doneToday.map(_taskCard),
            ],
            _historyCard(totalDone),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Column(
        children: [_categoryBar(), Expanded(child: _taskList())],
      ),
    );
  }
}

