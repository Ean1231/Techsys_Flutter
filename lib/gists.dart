import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GistsPage extends StatefulWidget {
  final String username;

  const GistsPage({Key? key, required this.username}) : super(key: key);

  @override
  _GistsPageState createState() => _GistsPageState();
}

class _GistsPageState extends State<GistsPage> {
  List<dynamic> gists = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    fetchGists(currentPage);
  }

  Future<void> fetchGists(int page) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/${widget.username}/gists?per_page=10&page=$page'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> gistsJsonList = json.decode(response.body);
      if (mounted) {
        setState(() {
          gists = gistsJsonList;
        });
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Unable to fetch followers. Please try again later. ${response.statusCode}'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
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
      fetchGists(currentPage);
    });
  }

  void prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchGists(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Gists'),
      ),
      body: Column(
        children: [
          Expanded(
            child: gists.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: gists.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(gists[index]['description'] ?? 'No description'),
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
                  child: Text('Prev'),
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
