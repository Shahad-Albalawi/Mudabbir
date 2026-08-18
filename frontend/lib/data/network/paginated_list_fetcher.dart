import 'package:dio/dio.dart';
import 'package:mudabbir/data/network/api_exception.dart';

/// Fetches all pages from a Laravel paginated list endpoint.
Future<List<Map<String, dynamic>>> fetchAllPaginatedPages(
  Dio dio,
  String path, {
  Map<String, dynamic>? queryParameters,
  int perPage = 100,
}) async {
  final items = <Map<String, dynamic>>[];
  var page = 1;
  var lastPage = 1;

  do {
    final response = await dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {
        ...?queryParameters,
        'page': page,
        'per_page': perPage,
      },
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ApiException(message: 'Failed to load $path (page $page)');
    }

    final data = body['data'];
    if (data is List) {
      for (final raw in data) {
        if (raw is Map) {
          items.add(Map<String, dynamic>.from(raw));
        }
      }
    } else if (data is Map && data['data'] is List) {
      for (final raw in data['data'] as List) {
        if (raw is Map) {
          items.add(Map<String, dynamic>.from(raw));
        }
      }
    }

    final meta = body['meta'];
    if (meta is Map) {
      lastPage = (meta['last_page'] as num?)?.toInt() ?? page;
    } else {
      lastPage = page;
    }

    page++;
  } while (page <= lastPage);

  return items;
}
