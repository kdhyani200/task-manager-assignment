import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _url = 'https://api.quotable.io/random';

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quote(quoteText: data['content'], author: data['author']);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      return Quote(
        quoteText: "The only way to do great work is to love what you do.",
        author: "Steve Jobs",
      );
    }
  }
}
