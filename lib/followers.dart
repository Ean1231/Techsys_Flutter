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
      setState(() {
        followers = followerJsonList.map((json) => Follower.fromJson(json)).toList();
      });
    } else {
      // Handle error
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
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) => Card(
              elevation: 3, // Add elevation for a card-like appearance
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add margin for spacing
              child: ListTile(
                contentPadding: EdgeInsets.all(16), // Add padding for content
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(followers[index].avatarUrl),
                ),
                title: Text(
                  followers[index].login,
                  style: TextStyle(
                    fontSize: 18, // Adjust font size
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: prevPage,
              child: Text('Previous'),
            ),
            ElevatedButton(
              onPressed: nextPage,
              child: Text('Next'),
            ),
          ],
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
