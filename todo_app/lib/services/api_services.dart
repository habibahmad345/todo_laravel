import 'dart:convert';
import 'package:http/http.dart' as http;

import '../cores/constants.dart';
import '../models/task.dart';

class ApiService {
  static const _json = {'Accept': 'application/json'};

  
  static Future<List<Task>> fetchTasks() async {
    final res = await http.get(Uri.parse('$baseUrl/tasks'), headers: _json);
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Task.fromJson(e)).toList();
  }

  static Future<void> completeTask(int id) async {
    await http.patch(Uri.parse('$baseUrl/tasks/$id/complete'), headers: _json);
  }

static Future<void> addTask({
  required String title,
  required DateTime date,
  String? time, // format "HH:mm"
  required int categoryId,
}) async {
  final d =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  await http.post(
    Uri.parse('$baseUrl/tasks'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': title,
      'due_date': d,
      'reminder_time': time,
      'category_id': categoryId,
    }),
  );
}
}