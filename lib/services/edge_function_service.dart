import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jetcv__utenti/supabase/supabase_config.dart';
import 'package:jetcv__utenti/models/models.dart';

/// Servizio base per gestire le chiamate alle Edge Functions di Supabase
class EdgeFunctionService {
  static final _client = SupabaseConfig.client;

  /// Metodo generico per chiamare una Edge Function
  static Future<Map<String, dynamic>> invokeFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      debugPrint('🚀 EdgeFunctionService: Calling function $functionName');
      debugPrint('🚀 EdgeFunctionService: Request body: $body');

      final response = await _client.functions.invoke(
        functionName,
        body: body,
      );

      debugPrint('🔄 EdgeFunctionService: Response status: ${response.status}');
      debugPrint('🔄 EdgeFunctionService: Response data: ${response.data}');

      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Risposta vuota dalla funzione $functionName');
      }
    } catch (e) {
      debugPrint(
          '❌ EdgeFunctionService: Error calling function $functionName: $e');
      debugPrint('❌ EdgeFunctionService: Error type: ${e.runtimeType}');

      // Handle specific error types
      if (e.toString().contains('Failed to fetch')) {
        throw Exception(
            'Network error: Unable to connect to $functionName. Please check your internet connection.');
      } else if (e.toString().contains('ClientException')) {
        throw Exception(
            'Connection error: Unable to reach $functionName. Please try again later.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Timeout error: $functionName took too long to respond. Please try again.');
      }

      throw Exception('Errore chiamando la funzione $functionName: $e');
    }
  }

  /// Metodo generico per chiamare una Edge Function con gestione errori avanzata
  static Future<EdgeFunctionResponse<T>> invokeFunctionTyped<T>(
    String functionName,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
      );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          return EdgeFunctionResponse<T>(
            success: true,
            data: fromJson(data['data']),
            message: data['message'],
          );
        } else {
          return EdgeFunctionResponse<T>(
            success: false,
            error: data['error'] ?? 'Errore sconosciuto',
            message: data['message'],
          );
        }
      } else {
        return EdgeFunctionResponse<T>(
          success: false,
          error: 'Risposta vuota dalla funzione $functionName',
        );
      }
    } catch (e) {
      return EdgeFunctionResponse<T>(
        success: false,
        error: 'Errore chiamando la funzione $functionName: $e',
      );
    }
  }

  /// Metodo per chiamare funzioni che ritornano solo status/messaggio
  static Future<EdgeFunctionResponse<void>> invokeFunctionSimple(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
      );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;

        return EdgeFunctionResponse<void>(
          success: data['success'] == true,
          error: data['error'],
          message: data['message'],
        );
      } else {
        return EdgeFunctionResponse<void>(
          success: false,
          error: 'Risposta vuota dalla funzione $functionName',
        );
      }
    } catch (e) {
      return EdgeFunctionResponse<void>(
        success: false,
        error: 'Errore chiamando la funzione $functionName: $e',
      );
    }
  }
}

/// Classe per gestire le risposte tipizzate delle Edge Functions
class EdgeFunctionResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  EdgeFunctionResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  @override
  String toString() {
    return 'EdgeFunctionResponse(success: $success, error: $error, message: $message)';
  }
}
