import 'dart:convert';
import 'package:http/http.dart' as http;

class Patients {
  Future<List<Map<String, dynamic>>> fetchData() async {
    final url = Uri.parse("http://localhost:8000/api/get-clinical-data");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("data $data");

        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception(
            'API response is not a list, received: ${data.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
