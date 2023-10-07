import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pagination Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> users = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers(0, 10);
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.slingacademy.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<void> fetchUsers(int offset, int limit) async {
    try {
      final response = await dio.get(
        '/v1/sample-data/users',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          users = response.data["users"];
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      fetchUsers(currentPage * 10, 10);
    }
  }

  void nextPage() {
    currentPage++;
    fetchUsers(currentPage * 10, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => previousPage(),
            icon: const Icon(Icons.chevron_left),
          ),
          Text((currentPage + 1).toString()),
          IconButton(
            onPressed: () => nextPage(),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['profile_picture']),
              ),
              title: Text(
                user['first_name'] + " " + user["last_name"],
                style: const TextStyle(fontSize: 24),
              ),
              subtitle: Text(user['email']),
            ),
          );
        },
      ),
    );
  }
}
