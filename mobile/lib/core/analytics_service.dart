import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<void> logEvent(String eventName, Map<String, dynamic> params) async {
    final event = {
      'event': eventName,
      'params': params,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Log to console in debug mode
    print('Analytics: $eventName $params');

    // Store locally to batch upload later (Offline-first)
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('analytics_logs') ?? [];
    logs.add(json.encode(event));
    await prefs.setStringList('analytics_logs', logs);

    // If online, try to upload
    if (logs.length >= 10) {
      _uploadLogs(logs);
    }
  }

  Future<void> _uploadLogs(List<String> logs) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analytics'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'logs': logs.map((l) => json.decode(l)).toList()}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('analytics_logs');
      }
    } catch (e) {
      // Fail silently, keep logs for next attempt
    }
  }
}

