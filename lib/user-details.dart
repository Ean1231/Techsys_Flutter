import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:techsys_flutter/main.dart';

class UserDetailsPage extends StatefulWidget {
  final String username;
  // final User user; // Assuming User is a defined class elsewhere in your code

  UserDetailsPage({Key? key, required this.username}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late Map<String, dynamic> userDetails = {};
  
  @override
  void initState() {
    super.initState();
    fetchUserDetails(); // Fetch user details when the widget is initialized
  }
Future<void> fetchUserDetails() async {
  final apiUrl = 'https://api.github.com/users/${widget.username}';
  print('Fetching: $apiUrl'); // Log the URL

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        userDetails = jsonData;
      });
    } else {
      print('Error loading user details: ${response.statusCode}');
      throw Exception('Failed to load user details with status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception caught: $e');
    // Handle the exception or show an error message
  }
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('User Details: ${widget.username}'),
      
    ),
    body: userDetails.isNotEmpty
        ? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userDetails['avatar_url']),
                      ),
                      title: Text(userDetails['login'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(userDetails['type']),
                    ),
                  ),
                  SizedBox(height: 10),
                  infoTile(context, 'Followers', userDetails['followers'], Icons.group, '/followers'),
                  infoTile(context, 'Following', userDetails['following'], Icons.person_outline, '/following'),
                  infoTile(context, 'Gists', userDetails['public_gists'], Icons.description, '/gists'),
                  infoTile(context, 'Repos', userDetails['public_repos'], Icons.storage, '/repos'),
                ],
              ),
            ),
          )
        : Center(child: CircularProgressIndicator()),
  );
}

Widget infoTile(BuildContext context, String title, dynamic value, IconData icon, String route) {
  return Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text('$title: $value'),
      onTap: () {
        Navigator.pushNamed(context, route, arguments: {'username': widget.username});
      },
    ),
  );
}

}
