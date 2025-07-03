import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

const supabaseUrl = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6dXNvaXp3bW5hcmlsaHRtenVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MzE5NzgsImV4cCI6MjA2NzEwNzk3OH0.J5CqkizX6QdrleADnCiL-VTWNdAErPcsjfd6ICAv7RQ'; // dán toàn bộ chuỗi anon key bạn đã copy vào đây

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Login App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginPage(),
    );
  }
}