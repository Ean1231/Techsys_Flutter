import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FollowersPage extends StatefulWidget {
  final String username;

  const FollowersPage({Key? key, required this.username}) : super(key: key);

  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<Follower> followers = [];
  int currentPage = 1; // Starting page
  String? message = "Warning";
  @override
  void initState() {
    super.initState();
    fetchFollowers(currentPage);
  }

  Future<void> fetchFollowers(int page) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/${widget.username}/followers?per_page=10&page=$page'),
    );

if (response.statusCode == 200) {
  final List<dynamic> followerJsonList = json.decode(response.body);
  if (this.mounted) {
    setState(() {
      followers = followerJsonList.map((json) => Follower.fromJson(json)).toList();
    });
  }
} else {
  if (this.mounted) {
    // Using context safely by checking if the widget is still mounted
    showDialog(
      context: context, // use context here directly
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Unable to fetch followers. Please try again later. ${response.statusCode}'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(), // Dismiss the dialog
          ),
        ],
      ),
    );
  }
}


  }

  void nextPage() {
    setState(() {
      currentPage++;
      fetchFollowers(currentPage);
    });
  }

  void prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchFollowers(currentPage);
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${widget.username}\'s Followers'),
    ),
    body: followers.isEmpty
        ? Center(
            child: CircularProgressIndicator(), // Show loader while fetching followers
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, index) {
                    final follower = followers[index];
                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(follower.avatarUrl),
                        ),
                        title: Text(
                          follower.login,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            
                      ),
                    );
                  },
                ),
              ),
              Padding(
  padding: const EdgeInsets.only(bottom: 136.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton(
        onPressed: prevPage,
        child: Text('Previous'),
      ),
      Text( 
        'Page $currentPage',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, 
        ),
      ),
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


class Follower {
  final String login;
  final String avatarUrl;

  Follower({required this.login, required this.avatarUrl});

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      login: json['login'],
      avatarUrl: json['avatar_url'],
    );
  }
}
