import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:flutter/material.dart';

class AuthMiddleware {
  Future<bool> canNavigate(Widget widget) async {
    final token = await getIt<HiveService>().getValue("token");
    return token != null;
  }
}
