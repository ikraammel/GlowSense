import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/constants.dart';
import '../models/user_model.dart';
import '../models/skin_analysis_model.dart';
import '../models/notification_model.dart';
import '../models/coach_model.dart';
import '../models/product_scan_model.dart';
import 'local_storage_service.dart';

class ApiService {
  late final Dio _dio;
  final LocalStorageService _storage;

  ApiService(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: "${AppConstants.baseUrl}/api",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print("CALLING: ${options.method} ${options.baseUrl}${options.path}");
        }
        final token = _storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print("STATUS: ${error.response?.statusCode}");
          print("PATH: ${error.requestOptions.path}");
          print("DATA: ${error.response?.data}");
        }
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${_storage.getAccessToken()}';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  // ── AUTH & USER ──────────────────────────────────────────
  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
      return AuthResponse.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<AuthResponse> register(String firstName, String lastName, String email, String password) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'firstName': firstName, 'lastName': lastName, 'email': email, 'password': password
      });
      return AuthResponse.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<UserModel> getProfile() async {
    try {
      final res = await _dio.get('/users/me');
      return UserModel.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<void> forgotPassword(String email) async {
    try { await _dio.post('/auth/forgot-password', data: {'email': email}); }
    on DioException catch (e) { throw _error(e); }
  }

  Future<void> verifyResetCode(String token) async {
    try { 
      // Si votre backend a un endpoint de validation :
      await _dio.post('/auth/verify-reset-code', data: {'token': token}); 
      
      // Note: Si le backend n'a pas cet endpoint, on peut simuler ou 
      // attendre l'appel final à reset-password.
    } on DioException catch (e) { throw _error(e); }
  }

  Future<AuthResponse> resetPassword(String token, String newPassword) async {
    try {
      final res = await _dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      // On suppose que le reset connecte l'utilisateur ou renvoie ses données
      return AuthResponse.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });
      await _dio.post('/users/me/avatar', data: formData);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/users/me', data: data);
      return UserModel.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _dio.put('/users/me/password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) { throw _error(e); }
  }

  Future<void> deleteAccount() async {
    try {
      await _dio.delete('/auth/delete-account');
    } on DioException catch (e) { throw _error(e); }
  }

  Future<void> completeOnboarding(Map<String, dynamic> data) async {
    try {
      await _dio.post('/users/me/onboarding', data: data);
    } on DioException catch (e) {
      throw _error(e);
    }
  }

  // ── DASHBOARD ────────────────────────────────────────────
  Future<DashboardModel> getDashboard() async {
    try {
      final res = await _dio.get('/dashboard');
      return DashboardModel.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  // ── ANALYSES ─────────────────────────────────────────────
  Future<SkinAnalysisModel> analyzeSkin(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'image.jpg')
      });
      final res = await _dio.post('/analyses', data: formData);
      return SkinAnalysisModel.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<List<SkinAnalysisModel>> getAnalysisHistory({int page = 0, int size = 10}) async {
    try {
      final res = await _dio.get('/analyses', queryParameters: {'page': page, 'size': size});
      final content = (res.data['data'] ?? res.data)['content'] as List? ?? [];
      return content.map((e) => SkinAnalysisModel.fromJson(e)).toList();
    } on DioException catch (e) { throw _error(e); }
  }

  Future<List<SkinAnalysisModel>> getRecentAnalyses({int limit = 5}) async {
    try {
      final res = await _dio.get('/analyses/recent', queryParameters: {'limit': limit});
      final content = (res.data['data'] ?? res.data) as List? ?? [];
      return content.map((e) => SkinAnalysisModel.fromJson(e)).toList();
    } on DioException catch (e) { throw _error(e); }
  }

  // ── AI COACH ─────────────────────────────────────────────
  Future<CoachMessageModel> chatWithCoach(String message, String sessionId) async {
    try {
      final res = await _dio.post('/coach/chat', data: {'message': message, 'sessionId': sessionId});
      return CoachMessageModel.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<List<CoachMessageModel>> getCoachHistory(String sessionId) async {
    try {
      final res = await _dio.get('/coach/history', queryParameters: {'sessionId': sessionId});
      final content = (res.data['data'] ?? res.data) as List? ?? [];
      return content.map((e) => CoachMessageModel.fromJson(e)).toList();
    } on DioException catch (e) { throw _error(e); }
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────
  Future<List<NotificationModel>> getNotifications({int page = 0, int size = 20}) async {
    try {
      final res = await _dio.get('/notifications', queryParameters: {'page': page, 'size': size});
      final content = (res.data['data'] ?? res.data)['content'] as List? ?? [];
      return content.map((e) => NotificationModel.fromJson(e)).toList();
    } on DioException catch (e) { throw _error(e); }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/notifications/unread-count');
      return (res.data['data'] ?? res.data)['count'] ?? 0;
    } on DioException catch (e) { throw _error(e); }
  }

  Future<void> markAllRead() async {
    try { await _dio.put('/notifications/read-all'); }
    on DioException catch (e) { throw _error(e); }
  }

  Future<void> markOneRead(int id) async {
    try { await _dio.put('/notifications/$id/read'); }
    on DioException catch (e) { throw _error(e); }
  }

  // ── PRODUCTS ─────────────────────────────────────────────
  Future<ProductScanModel> scanProduct(ProductScanRequestModel request) async {
    try {
      final res = await _dio.post('/products/scan', data: request.toJson());
      return ProductScanModel.fromJson(res.data['data'] ?? res.data);
    } on DioException catch (e) { throw _error(e); }
  }

  Future<List<ProductScanModel>> getProductHistory({int page = 0, int size = 10}) async {
    try {
      final res = await _dio.get('/products/history', queryParameters: {'page': page, 'size': size});
      final content = (res.data['data'] ?? res.data)['content'] as List? ?? [];
      return content.map((e) => ProductScanModel.fromJson(e)).toList();
    } on DioException catch (e) { throw _error(e); }
  }

  // ── PRIVATE HELPERS ──────────────────────────────────────
  Future<bool> _tryRefreshToken() async {
    final refresh = _storage.getRefreshToken();
    if (refresh == null) return false;
    try {
      final res = await Dio().post('${AppConstants.baseUrl}/api/auth/refresh', data: {'refreshToken': refresh});
      final access = (res.data['data'] ?? res.data)['accessToken'];
      final newRefresh = (res.data['data'] ?? res.data)['refreshToken'];
      await _storage.saveTokens(access, newRefresh);
      return true;
    } catch (_) {
      await _storage.clearTokens();
      return false;
    }
  }

  String _error(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message'] ??
             data['error'] ??
             data['detail'] ??
             (data['errors'] is List ? (data['errors'] as List).first.toString() : null) ??
             "Erreur serveur";
    }
    return e.message ?? "Une erreur est survenue";
  }
}
