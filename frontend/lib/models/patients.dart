import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://localhost:8000/api"; // base URL
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Fetch patients from /get-patients endpoint
  Future<List<Map<String, dynamic>>> fetchPatients({
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/get-patients");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.get(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List) {
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else {
            throw FormatException(
              'API response is not a list, received: ${data.runtimeType}',
            );
          }
        } else {
          throw HttpException(
            'Failed to load patients: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException('Network error after $retries retries: $e');
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error after retries');
  }

  // Fetch clinical data from /get-clinical-data endpoint (all records)
  Future<List<Map<String, dynamic>>> fetchPatientsClinical({
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/get-clinical-data");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.get(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List) {
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else {
            throw FormatException(
              'API response is not a list, received: ${data.runtimeType}',
            );
          }
        } else {
          throw HttpException(
            'Failed to load clinical data: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException('Network error after $retries retries: $e');
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error after retries');
  }

  // Fetch clinical data by patient ID from /get-patient-clinical-data/:id endpoint
  Future<Map<String, dynamic>?> fetchPatientClinicalData({
    required String patientId,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/get-patient-clinical-data/$patientId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.get(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data["data"];
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else if (response.statusCode == 404) {
          return null;
        } else {
          throw HttpException(
            'Failed to fetch patient clinical data: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException('Network error after $retries retries: $e');
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error after retries');
  }

  // Add patient to /add-patient endpoint
  Future<Map<String, dynamic>> addPatient({
    required Map<String, dynamic> patientData,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/add-patient");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.post(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(patientData),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to add patient: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error adding patient after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error adding patient after retries');
  }

  // Delete patient from /delete-patient/:id endpoint
  Future<Map<String, dynamic>> deletePatient({
    required String patientId,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/delete-patient/$patientId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.delete(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to delete patient: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error deleting patient after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error deleting patient after retries');
  }

  // Update patient at /update-patient/:id endpoint
  Future<Map<String, dynamic>> updatePatient({
    required String patientId,
    required Map<String, dynamic> patientData,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/update-patient/$patientId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.put(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(patientData),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to update patient: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error updating patient after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error updating patient after retries');
  }

  // Add clinical data to /add-clinical-data endpoint
  Future<Map<String, dynamic>> addClinicalData({
    required Map<String, dynamic> clinicalData,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/add-clinical-data");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.post(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(clinicalData),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to add clinical data: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error adding clinical data after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error adding clinical data after retries');
  }

  // Update clinical data at /update-clinical-data/:id endpoint
  Future<Map<String, dynamic>> updateClinicalData({
    required String clinicalId,
    required Map<String, dynamic> clinicalData,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/update-clinical-data/$clinicalId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.put(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(clinicalData),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to update clinical data: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error updating clinical data after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error updating clinical data after retries');
  }

  // Delete clinical data at /delete-clinical-data/:id endpoint
  Future<Map<String, dynamic>> deleteClinicalData({
    required String clinicalId,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/delete-clinical-data/$clinicalId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.delete(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to delete clinical data: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error deleting clinical data after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error deleting clinical data after retries');
  }

  // Fetch history for a patient from /get-history/:patientId endpoint
  Future<List<Map<String, dynamic>>> fetchPatientHistory({
    required String patientId,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/get-history/$patientId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.get(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] is List) {
            return (data['data'] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
          } else {
            throw FormatException(
              'API response data field is not a list, received: ${data['data'].runtimeType}',
            );
          }
        } else if (response.statusCode == 404) {
          // Handle case where no history exists for the patient
          return []; // Return empty list instead of throwing
        } else {
          throw HttpException(
            'Failed to fetch patient history: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException('Network error after $retries retries: $e');
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error after retries');
  }

  // Add history for a patient to /add-history/:patientId endpoint
  Future<Map<String, dynamic>> addPatientHistory({
    required String patientId,
    required Map<String, dynamic> historyData,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/add-history/$patientId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.post(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(historyData),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to add patient history: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error adding patient history after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error adding patient history after retries');
  }

  // Update history for a patient at /edit-history/:historyId endpoint
  Future<Map<String, dynamic>> updatePatientHistory({
    required String historyId,
    required Map<String, dynamic> historyData,
    Map<String, String>? headers,
    int retries = 2,
  }) async {
    final url = Uri.parse("$baseUrl/edit-history/$historyId");
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client.put(
          url,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(historyData),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          throw FormatException(
            'API response is not a map, received: ${data.runtimeType}',
          );
        } else {
          throw HttpException(
            'Failed to update patient history: ${response.statusCode} - ${response.body}',
          );
        }
      } on http.ClientException catch (e) {
        if (attempt == retries) {
          throw NetworkException(
            'Network error updating patient history after $retries retries: $e',
          );
        }
        await Future.delayed(Duration(seconds: 1 << attempt));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
    throw Exception('Unexpected error updating patient history after retries');
  }

  void dispose() {
    _client.close();
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}

class Patients {
  final ApiClient _apiClient;

  Patients({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Map<String, dynamic>>> fetchPatients() async {
    return _apiClient.fetchPatients();
  }

  Future<List<Map<String, dynamic>>> fetchPatientsClinical() async {
    return _apiClient.fetchPatientsClinical();
  }

  Future<Map<String, dynamic>> addPatient(
    Map<String, dynamic> patientData,
  ) async {
    return _apiClient.addPatient(patientData: patientData);
  }

  Future<Map<String, dynamic>> deletePatient(String patientId) async {
    return _apiClient.deletePatient(patientId: patientId);
  }

  Future<Map<String, dynamic>> updatePatient(
    String patientId,
    Map<String, dynamic> patientData,
  ) async {
    return _apiClient.updatePatient(
      patientId: patientId,
      patientData: patientData,
    );
  }

  Future<Map<String, dynamic>> addClinicalData(
    Map<String, dynamic> clinicalData,
  ) async {
    return _apiClient.addClinicalData(clinicalData: clinicalData);
  }

  Future<bool> hasClinicalData(String patientId) async {
    try {
      final clinicalData = await _apiClient.fetchPatientClinicalData(
        patientId: patientId,
      );
      return clinicalData != null;
    } catch (e) {
      print('Error checking clinical data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> updateClinicalData(
    String clinicalId,
    Map<String, dynamic> clinicalData,
  ) async {
    return _apiClient.updateClinicalData(
      clinicalId: clinicalId,
      clinicalData: clinicalData,
    );
  }

  Future<Map<String, dynamic>> deleteClinicalData(String clinicalId) async {
    return _apiClient.deleteClinicalData(clinicalId: clinicalId);
  }

  // New history-related methods

  Future<List<Map<String, dynamic>>> fetchPatientHistory(
    String patientId,
  ) async {
    return _apiClient.fetchPatientHistory(patientId: patientId);
  }

  Future<Map<String, dynamic>> addPatientHistory({
    required String patientId,
    required Map<String, dynamic> historyData,
  }) async {
    return _apiClient.addPatientHistory(
      patientId: patientId,
      historyData: historyData,
    );
  }

  Future<Map<String, dynamic>> updatePatientHistory({
    required String historyId,
    required Map<String, dynamic> historyData,
  }) async {
    return _apiClient.updatePatientHistory(
      historyId: historyId,
      historyData: historyData,
    );
  }

  void dispose() {
    _apiClient.dispose();
  }
}
