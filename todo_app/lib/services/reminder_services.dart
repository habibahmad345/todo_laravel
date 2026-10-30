import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import '../models/task.dart';
import 'api_services.dart';

class ReminderService {
  static Timer? _timer;
  static final Set<int> _fired = {};
  static final Map<int, DateTime> _snooze = {};
  static final AudioPlayer _player = AudioPlayer();
  static bool enabled = true;

  /// Mulai memeriksa tugas setiap 15 detik.
  static void start(void Function(Task) onDue) {
    _timer?.cancel();
    _check(onDue);
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _check(onDue));
  }

  static void stop() => _timer?.cancel();

  static DateTime? _dueAt(Task t) {
    if (t.dueDate == null || t.dueDate!.length < 10) return null;
    if (t.reminderTime == null || t.reminderTime!.length < 5) return null;
    final d = DateTime.tryParse(t.dueDate!.substring(0, 10));
    if (d == null) return null;
    final h = int.tryParse(t.reminderTime!.substring(0, 2));
    final m = int.tryParse(t.reminderTime!.substring(3, 5));
    if (h == null || m == null) return null;
    return DateTime(d.year, d.month, d.day, h, m);
  }

  static Future<void> _check(void Function(Task) onDue) async {
    if (!enabled) return;
    try {
      final tasks = await ApiService.fetchTasks();
      final now = DateTime.now();
      for (final t in tasks) {
        if (t.isCompleted) continue;
        final snoozed = _snooze[t.id];
        if (snoozed == null && _fired.contains(t.id)) continue;

        final at = snoozed ?? _dueAt(t);
        if (at == null || now.isBefore(at)) continue;
        // abaikan pengingat yang sudah lewat lebih dari 30 menit
        if (now.difference(at) > const Duration(minutes: 30)) continue;

        _fired.add(t.id);
        _snooze.remove(t.id);
        onDue(t);
      }
    } catch (_) {
      // server mati / tidak ada internet: coba lagi 15 detik berikutnya
    }
  }

  static void snooze(int id, int minutes) {
    _snooze[id] = DateTime.now().add(Duration(minutes: minutes));
  }

  // ---------- SUARA ----------
  static Future<void> startAlarm() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(BytesSource(_beepWav(), mimeType: 'audio/wav'));
    } catch (_) {}
  }

  static Future<void> stopAlarm() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  /// Membuat bunyi "bip-bip-bip" 880 Hz dalam format WAV.
  static Uint8List _beepWav() {
    const rate = 22050;
    final samples = <int>[];

    void tone(double sec) {
      final n = (rate * sec).toInt();
      for (int i = 0; i < n; i++) {
        samples.add((sin(2 * pi * 880 * i / rate) * 0x4FFF).toInt());
      }
    }

    void silence(double sec) {
      samples.addAll(List.filled((rate * sec).toInt(), 0));
    }

    for (int i = 0; i < 3; i++) {
      tone(0.25);
      silence(0.15);
    }
    silence(0.6);

    final dataSize = samples.length * 2;
    final b = ByteData(44 + dataSize);
    void txt(int o, String s) {
      for (int i = 0; i < s.length; i++) {
        b.setUint8(o + i, s.codeUnitAt(i));
      }
    }

    txt(0, 'RIFF');
    b.setUint32(4, 36 + dataSize, Endian.little);
    txt(8, 'WAVE');
    txt(12, 'fmt ');
    b.setUint32(16, 16, Endian.little);
    b.setUint16(20, 1, Endian.little); // PCM
    b.setUint16(22, 1, Endian.little); // mono
    b.setUint32(24, rate, Endian.little);
    b.setUint32(28, rate * 2, Endian.little);
    b.setUint16(32, 2, Endian.little);
    b.setUint16(34, 16, Endian.little);
    txt(36, 'data');
    b.setUint32(40, dataSize, Endian.little);
    for (int i = 0; i < samples.length; i++) {
      b.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return b.buffer.asUint8List();
  }
}