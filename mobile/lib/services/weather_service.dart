import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final String baseUrl = 'http://localhost:3000/api'; // Use actual backend URL in production

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'weather_cache';

    try {
      final response = await http.get(Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString(cacheKey, response.body);
        return data;
      }
    } catch (e) {
      // Return cached data if available
      final cached = prefs.getString(cacheKey);
      if (cached != null) {
        return json.decode(cached);
      }
    }
    
    // Default mock data if no cache and no internet
    return {
      'location': 'Rwanda (Offline)',
      'forecast': [
        {'day': 'Today', 'temp': '--', 'condition': 'Offline', 'advice': 'No data available.'}
      ]
    };
  }
}
