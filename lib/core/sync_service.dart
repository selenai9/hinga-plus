import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hinga_plus/database/database.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  final AppDatabase db;
  final String baseUrl = 'http://localhost:3000/api';

  SyncService(this.db);

  Future<void> sync() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    // 1. Push local changes to server
    final unsyncedItems = await (db.select(db.syncQueue)).get();
    if (unsyncedItems.isNotEmpty) {
      final updates = unsyncedItems.map((item) => {
        'table': item.tableName,
        'operation': item.operation,
        'data': json.decode(item.payload),
      }).toList();

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/sync'),
          headers: {'Content-Type': 'application/json', 'x-user-id': 'MOCK_USER_ID'},
          body: json.encode({'updates': updates}),
        );

        if (response.statusCode == 200) {
          // Clear sync queue if successful
          await db.delete(db.syncQueue).go();
        }
      } catch (e) {
        // Log error and retry later
      }
    }

    // 2. Pull latest data from server
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sync'),
        headers: {'x-user-id': 'MOCK_USER_ID'},
      );

      if (response.statusCode == 200) {
        final serverData = json.decode(response.body)['server_data'];
        // Update local database with server data
        // (Conflict resolution: last-write-wins with server timestamp)
        // Implementation for each table...
      }
    } catch (e) {
      // Log error
    }
  }

  Future<void> addToQueue(String tableName, String operation, Map<String, dynamic> data) async {
    await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
      tableName: tableName,
      operation: operation,
      payload: json.encode(data),
    ));
  }
}

