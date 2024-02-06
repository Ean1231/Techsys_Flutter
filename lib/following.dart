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
     showDialog(
      context: context, // Context is used here directly
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Unable to fetch users your following. Please try again later. ${response.statusCode}'),
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
    body: following.isEmpty
        ? Center(
            child: CircularProgressIndicator(), 
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: following.length,
                  itemBuilder: (context, index) {
                    final followingUser = following[index];
                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(followingUser['avatar_url']),
                        ),
                        title: Text(
                          followingUser['login'],
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
                 padding: const EdgeInsets.all(16.0),
                child: Row(
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
              ),
            ],
          ),
  );
}

}
