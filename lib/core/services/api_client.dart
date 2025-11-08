// lib/core/services/api_client.dart
import 'package:dio/dio.dart';

// ⭐️ Android 에뮬레이터: http://10.0.2.2:8000
// ⭐️ iOS 시뮬레이터: http://localhost:8000
const String baseUrl = "http://10.0.2.2:8000";

final dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    contentType: 'application/json',
  )
);