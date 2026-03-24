import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hinga_plus/services/weather_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.getWeather(-1.9441, 30.0619); // Kigali coordinates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hinga+', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Card
            FutureBuilder<Map<String, dynamic>>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
                }
                final data = snapshot.data!;
                final forecast = data['forecast'][0];
                return Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('HingaHava (Kigali)', style: Theme.of(context).textTheme.titleLarge),
                                Text(forecast['condition'], style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                            Text('${forecast['temp']}°C', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Text('Inama: ${forecast['advice']}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text('Ibikoresho', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildToolCard(context, 'HingaShinga', 'Ibyonnyi', Icons.bug_report, Colors.orange),
                _buildToolCard(context, 'HingaGahunda', 'Planner', Icons.calendar_today, Colors.green),
                _buildToolCard(context, 'HingaIsoko', 'Isoko', Icons.shopping_cart, Colors.blue),
                _buildToolCard(context, 'HingaInama', 'Ubufasha', Icons.support_agent, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            // Offline Indicator Placeholder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Byose byageze kuri seriveri (10:30 AM)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
