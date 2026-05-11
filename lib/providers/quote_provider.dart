import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quote.dart';

final quoteProvider = FutureProvider.autoDispose<Quote>((ref) async {
  final url = Uri.parse('https://zenquotes.io/api/random');

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return Quote(quoteText: data[0]['q'], author: data[0]['a']);
    }
    throw Exception('API Error');
  } catch (e) {
    return Quote(
      quoteText: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
    );
  }
});
