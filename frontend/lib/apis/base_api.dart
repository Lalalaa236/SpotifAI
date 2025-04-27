import 'package:dio/dio.dart';
import 'dio_client.dart';

class BaseApi {
  final Dio _dio = DioClient.instance;
  
  dynamic _handleResponse(Response response) {
    return response.data;
  }
  
  Exception _handleError(DioException e) {
    String errorMessage;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        errorMessage = 'Error $statusCode: ${responseData?['message'] ?? 'Unknown server error'}';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      default:
        errorMessage = e.message ?? 'Unexpected error occurred';
    }
    
    return Exception(errorMessage);
  }
  
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } 
    on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } 
    on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _handleResponse(response);
    } 
    on DioException catch (e) {
      throw _handleError(e);
    }
  }
}