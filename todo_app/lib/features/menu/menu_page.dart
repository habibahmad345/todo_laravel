import 'package:flutter/material.dart';
import 'package:flutter_appk/cores/constants.dart';
import 'package:flutter_appk/features/tugas/tasks_page.dart';
import '../../cores/constants.dart';
import '../../models/task.dart';
import '../../services/api_services.dart';
import '../tugas/history_page.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _reminderOn = true;
  bool _darkMode = false;

  void _soon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name belum dibuat')),
    );
  }

  //history
  Future<void> _openHistory() async {
  try {
    final all = await ApiService.fetchTasks();
    final done = all.where((t) => t.isCompleted).toList();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryPage(tasks: done)),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat riwayat: $e')),
    );
  }
}



  Widget _statItem(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _stats() {
    // Angka masih contoh, nanti diambil dari API
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _statItem(Icons.check_circle, Colors.green, '6', 'Selesai'),
          _statItem(Icons.pending_actions, Colors.orange, '2', 'Aktif'),
          _statItem(Icons.folder_outlined, kBlue, '2', 'Kategori'),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _group(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, indent: 64, endIndent: 16),
          ],
        ],
      ),
    );
  }

  Widget _icon(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _tile(IconData icon, Color color, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: _icon(icon, color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () => _soon(title),
    );
  }

  Widget _switchTile(IconData icon, Color color, String title, bool value,
      ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: _icon(icon, color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      activeThumbColor: kBlue,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          
          _stats(),
          _sectionLabel('Umum'),
          _group([
            _tile(Icons.folder_outlined, kBlue, 'Kelola kategori',
                subtitle: 'Work, Personal'),
            _switchTile(Icons.notifications_active_outlined, Colors.orange,
                'Pengingat tugas', _reminderOn,
                (v) => setState(() => _reminderOn = v)),
            _switchTile(Icons.dark_mode_outlined, Colors.indigo, 'Tema gelap',
                _darkMode, (v) {
              setState(() => _darkMode = v);
              _soon('Tema gelap');
            }),
          ]),
          _sectionLabel('Data'),
          _group([
           _tile(Icons.history, Colors.green, 'Riwayat tugas',
           onTap: _openHistory
         ),
            _tile(Icons.file_download_outlined, Colors.teal, 'Ekspor data'),
            _tile(Icons.sync, kBlue, 'Sinkronisasi',
                subtitle: 'Terhubung ke server'),
          ]),


          _sectionLabel('Tentang'),
          _group([
            _tile(Icons.help_outline, Colors.deepPurple, 'Bantuan'),
            _tile(Icons.info_outline, Colors.grey, 'Versi aplikasi',
                subtitle: '1.0.0',
                onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'To-Do List',
                      applicationVersion: '1.0.0',
                    )),
          ]),
        ],
      ),
    );
  }
}