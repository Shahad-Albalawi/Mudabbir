import 'package:dio/dio.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/data/network/dio_client.dart';
import 'package:mudabbir/domain/models/app_notification.dart';

class NotificationApiService {
  NotificationApiService(this._dioClient);

  final DioClient _dioClient;

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await _dioClient.dio.get('/notifications');
      final body = response.data;
      if (body is Map &&
          (body['success'] == true || body['status'] == 'success')) {
        final raw = body['data'];
        final list = raw is List ? raw : <dynamic>[];
        return list
            .map(
              (item) => AppNotification.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
      throw ApiException(message: 'Failed to load notifications');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _dioClient.dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
