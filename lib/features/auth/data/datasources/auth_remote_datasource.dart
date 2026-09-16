import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(
      {required String email, required String password});
  Future<AuthResponseModel> register(
      {required String email, required String password});
  Future<void> logout({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login(
      {required String email, required String password}) async {
    return _call(ApiConstants.loginPath, email: email, password: password);
  }

  @override
  Future<AuthResponseModel> register(
      {required String email, required String password}) async {
    return _call(ApiConstants.registerPath, email: email, password: password);
  }

  @override
  Future<void> logout({required String token}) async {
    try {
      await dio.post(
        ApiConstants.logoutPath,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw ServerException(
        'Logout server error (${e.response?.statusCode ?? 'unknown'})',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<AuthResponseModel> _call(String path,
      {required String email, required String password}) async {
    try {
      final response =
          await dio.post(path, data: {'email': email, 'password': password});
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      final status = e.response?.statusCode;
      if (status == 400 || status == 401) {
        final msg = (e.response?.data is Map)
            ? (e.response?.data['error'] as String? ?? 'Invalid credentials')
            : 'Invalid credentials';
        throw ValidationException(msg);
      }
      throw ServerException(
        'Auth server error (${status ?? 'unknown'})',
        statusCode: status,
      );
    }
  }
}
