import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final String _baseUrl;

  InventoryService() : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://ventopos.duckdns.org';

  Map<String, String> get _headers {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getState() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/state'), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load state: ${response.statusCode}');
    }
  }

  Future<void> ingest(InventoryItem item) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/ingest'),
      headers: _headers,
      body: json.encode(item.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to ingest item: ${response.statusCode}');
    }
  }

  Future<void> undo() async {
    final response = await http.post(Uri.parse('$_baseUrl/api/undo'), headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to undo: ${response.statusCode}');
    }
  }

  Future<void> sort() async {
    final response = await http.post(Uri.parse('$_baseUrl/api/sort'), headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to sort matrix: ${response.statusCode}');
    }
  }

  Future<void> clearAll() async {
    final response = await http.post(Uri.parse('$_baseUrl/api/clear'), headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to clear inventory: ${response.statusCode}');
    }
  }

  Future<List<InventoryItem>> search(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/search?q=$query'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to search: ${response.statusCode}');
    }
  }
}

