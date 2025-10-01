import 'package:dio/dio.dart';

class DioFactory {
  static Dio create({
    required String baseUrl,
    List<Interceptor> interceptors = const [],
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: 'application/json',
      ),
    );

    // if (kDebugMode) {
    //   dio.interceptors.add(
    //     LogInterceptor(
    //       requestBody: false,
    //       responseBody: false,
    //       requestHeader: false,
    //       responseHeader: false,
    //       request: false,
    //     ),
    //   );
    // }

    // dio.interceptors.addAll(interceptors);
    return dio;
  }
}
