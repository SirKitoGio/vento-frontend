import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final String _baseUrl;

  InventoryService() : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  Future<Map<String, dynamic>> getState() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/state'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load state');
    }
  }

  Future<void> ingest(InventoryItem item) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ingest'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to ingest item');
    }
  }

  Future<void> undo() async {
    final response = await http.post(Uri.parse('$_baseUrl/api/undo'));
    if (response.statusCode != 200) {
      throw Exception('Failed to undo');
    }
  }

  Future<void> sort() async {
    final response = await http.post(Uri.parse('$_baseUrl/api/sort'));
    if (response.statusCode != 200) {
      throw Exception('Failed to sort matrix');
    }
  }

  Future<void> clearAll() async {
    final response = await http.post(Uri.parse('$_baseUrl/api/clear'));
    if (response.statusCode != 200) {
      throw Exception('Failed to clear inventory');
    }
  }

  Future<List<InventoryItem>> search(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/search?q=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to search');
    }
  }
}
