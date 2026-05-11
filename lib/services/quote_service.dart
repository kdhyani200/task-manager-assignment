import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuoteService {
  static const String _url = 'https://zenquotes.io/api/random';

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return Quote(quoteText: data[0]['q'], author: data[0]['a']);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      return Quote(
        quoteText: "Keep going. Everything you need will come to you.",
        author: "Unknown",
      );
    }
  }
}
