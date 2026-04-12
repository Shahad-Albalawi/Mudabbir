import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<String> dbFiles = [];
  String? currentUserDb;

  @override
  void initState() {
    super.initState();
    _loadDatabases();
  }

  Future<void> _loadDatabases() async {
    final databasesPath = await getDatabasesPath();
    final dir = Directory(databasesPath);
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();

    final currentUser = getIt<HiveService>().getValue(
      HiveConstants.savedUserInfo,
    );

    String? currentDbName;
    if (currentUser != null && currentUser is Map) {
      try {
        final emailText = currentUser['email'].toString().split('@').first;
        final name = currentUser['name'].toString();
        currentDbName = '${emailText}_${name}db.db';
      } catch (e) {
        debugPrint("Failed to parse Hive user data: $e");
      }
    }

    setState(() {
      dbFiles = files.map((f) => basename(f.path)).toList();
      currentUserDb = currentDbName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test / DB Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Existing Local Databases:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: dbFiles.length,
                itemBuilder: (context, index) {
                  final dbName = dbFiles[index];
                  final isCurrentUser = dbName == currentUserDb;
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: isCurrentUser ? Colors.green : ColorManager.grey,
                      size: 14,
                    ),
                    title: Text(dbName),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadDatabases,
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
                getIt<HiveService>().deleteValue(HiveConstants.savedToken);
                getIt<HiveService>().deleteValue(HiveConstants.savedUserInfo);
                // getIt<AuthNotifier>().refresh();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
