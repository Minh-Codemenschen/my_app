import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// key
const supabaseUrl = 'https://vzusoizwmnarilhtmzuc.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6dXNvaXp3bW5hcmlsaHRtenVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MzE5NzgsImV4cCI6MjA2NzEwNzk3OH0.J5CqkizX6QdrleADnCiL-VTWNdAErPcsjfd6ICAv7RQ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? errorMessage;

  Future<void> _login() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      setState(() {}); // trigger rebuild
    } on AuthException catch (error) {
      setState(() => errorMessage = error.message);
    } catch (_) {
      setState(() => errorMessage = 'Unknown error.');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: user == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Login')),
              body: _buildLoginForm(),
            )
          : _buildHome(user.email),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text('LOGIN')),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(String? email) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('courses')
          .select()
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        final user = Supabase.instance.client.auth.currentUser;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final courses = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${email ?? 'User'}'),
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Course List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: DataTable(
                    columnSpacing: 12,
                    columns: const [
                      DataColumn(label: Expanded(child: Text('STT'))),
                      DataColumn(label: Expanded(child: Text('Name'))),
                      DataColumn(label: Expanded(child: Text('Describe'))),
                      DataColumn(label: Expanded(child: Text('Creator'))),
                      DataColumn(label: Expanded(child: Text('Date created'))),
                    ],
                    rows: List.generate(courses.length, (index) {
                      final course = courses[index];
                      final createdAt = DateTime.tryParse(
                        course['created_at'] ?? '',
                      );
                      final formattedDate = createdAt != null
                          ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                          : '';

                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(course['title'] ?? '', softWrap: true)),
                          DataCell(
                            Text(course['description'] ?? '', softWrap: true),
                          ),
                          DataCell(
                            Text(course['user_email'] ?? '', softWrap: true),
                          ),
                          DataCell(Text(formattedDate)),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCoursePage()),
              );
              if (result == true) setState(() {});
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    setState(() => loading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      final response = await Supabase.instance.client.from('courses').insert({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'user_id': userId,
        'user_email': Supabase.instance.client.auth.currentUser?.email,
      }).select();

      Navigator.pop(context, true); // reload home
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add course')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Describe'),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Create a course'),
                  ),
          ],
        ),
      ),
    );
  }
}
