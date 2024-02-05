import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FollowingPage extends StatefulWidget {
  final String username;

  const FollowingPage({Key? key, required this.username}) : super(key: key);

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<dynamic> following = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    fetchFollowing(currentPage);
  }

  Future<void> fetchFollowing(int page) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/${widget.username}/following?per_page=10&page=$page'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> followingJsonList = json.decode(response.body);
      setState(() {
        following = followingJsonList;
      });
    } else {
      // Handle error
      print('Failed to load following');
    }
  }

  void nextPage() {
    setState(() {
      currentPage++;
      fetchFollowing(currentPage);
    });
  }

  void prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchFollowing(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Following'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(following[index]['avatar_url']),
                ),
                title: Text(following[index]['login']),
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
