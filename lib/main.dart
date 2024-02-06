import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techsys_flutter/following.dart';
import 'package:techsys_flutter/repos.dart';
import 'dart:convert';
import 'package:techsys_flutter/user-details.dart';
import 'package:techsys_flutter/gists.dart';
import 'followers.dart';


// MaterialApp(
//   title: 'GitHub Users and Repos',
//   theme: ThemeData(
//     primarySwatch: Colors.blue,
//   ),
//   initialRoute: '/',
//   routes: {
//     '/': (context) => const UserListPage()
  
//     // Other routes...
//   },
// );
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Users and Repos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const UserListPage(),
       '/user-details': (context) { // Correct the route name here
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final username = args['username'] ; // Make sure to retrieve the username from args
      return UserDetailsPage( username: username); // Pass both the User object and username
    },
     '/repos': (context) { // Correct the route name here
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final username = args['username'] ; // Make sure to retrieve the username from args
      return ReposPage( username: username); // Pass both the User object and username
    },
     '/gists': (context) { // Correct the route name here
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final username = args['username'] ; // Make sure to retrieve the username from args
      return GistsPage( username: username); // Pass both the User object and username
    },
        '/followers': (context) { // Correct the route name here
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final username = args['username'] ; // Make sure to retrieve the username from args
      return FollowersPage( username: username); // Pass both the User object and username
    },
          '/following': (context) { // Correct the route name here
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final username = args['username'] ; // Make sure to retrieve the username from args
      return FollowingPage( username: username); // Pass both the User object and username
    },
      },
    );
  }
}

class User {
  final String login;
  final String avatarUrl;
  final String userType;

  User({
    required this.login,
    required this.avatarUrl,
    required this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      avatarUrl: json['avatar_url'],
      userType: json['type'],
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final String apiUrl = 'https://api.github.com/search/users?q=test&page=1&per_page=10';
  late List<User> users = [];
  int currentPage = 1;
  String searchQuery = 'a';
  final int perPage = 10;
  final String githubApiToken = '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';
  String errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
     final headers = {
      'Authorization': 'token $githubApiToken',
    };
    final response = await http.get(
      Uri.parse(
          'https://api.github.com/search/users?q=$searchQuery&page=$currentPage&per_page=$perPage'),
          headers: headers,
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final items = jsonData['items'];
      setState(() {
        users = items.map<User>((userJson) => User.fromJson(userJson)).toList();
        errorMessage = '';
      });
    } else {
      setState(() {
        users = []; // Clear the user list
        errorMessage = 'No users found'; // Set the error message
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query.isEmpty ? 'a' : query;
      currentPage = 1; // Reset to the first page when searching
    });
    fetchData();
  }

  void nextPage() {
    setState(() {
      currentPage++;
    });
    fetchData();
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      fetchData();
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('GitHub Users'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: handleSearch,
            decoration: InputDecoration(
              labelText: 'Search Users',
              errorText: errorMessage.isNotEmpty ? errorMessage : null,
              // suffixIcon: IconButton(
              //   // icon: Icon(Icons.clear),
              //   onPressed: () {
              //     setState(() {
              //       searchQuery = ''; // Clear the search query
              //     });
              //     fetchData(); // Initiate a new search
              //   },
              // ),
            ),
          ),

        ),
      
        Expanded(
          child: SingleChildScrollView(
            child: users.isEmpty
                ? Center(
                    child: CircularProgressIndicator(), 
                  )
                : DataTable(
                    columns: const [
                      DataColumn(label: Text('Avatar')),
                      DataColumn(label: Text('Login')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Action')), 
                    ],
                    rows: List<DataRow>.generate(
                      users.length,
                      (index) => DataRow(cells: [
                        DataCell(CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(users[index].avatarUrl),
                        )),
                        DataCell(Text(users[index].login)),
                        DataCell(Text(users[index].userType)),
                        DataCell(TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/user-details',
                              arguments: {'user': users[index], 'username': users[index].login},
                            );
                          },
                          child: Text('View'),
                        )), // Add a View button in the Action column
                      ]),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 136.0), // Add top padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: previousPage,
                child: Text('Prev'),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: nextPage,
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



}