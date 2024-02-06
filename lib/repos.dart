import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReposPage extends StatefulWidget {
  final String username;

  const ReposPage({Key? key, required this.username}) : super(key: key);

  @override
  _ReposPageState createState() => _ReposPageState();
}

class _ReposPageState extends State<ReposPage> {
  List<dynamic> repositories = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    fetchRepositories(currentPage);
  }

  Future<void> fetchRepositories(int page) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/${widget.username}/repos?per_page=10&page=$page'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> repositoriesJsonList = json.decode(response.body);
      setState(() {
        repositories = repositoriesJsonList;
      });
    } else {
      print('Failed to load repositories');
    }
  }

  void nextPage() {
    setState(() {
      currentPage++;
      fetchRepositories(currentPage);
    });
  }

  void prevPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchRepositories(currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Repositories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Repository')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Link')),
              ],
              rows: repositories
                  .map((repo) => DataRow(cells: [
                        DataCell(Text(repo['name'] ?? 'No name')),
                        DataCell(Text(repo['description'] ?? 'No description')),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RepoDetailsPage(
                                    username: widget.username,
                                    repoName: repo['name'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Text('View'),
                          ),
                        ),
                      ]))
                  .toList(),
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


class RepoDetailsPage extends StatefulWidget {
  final String username;
  final String repoName;

  const RepoDetailsPage({Key? key, required this.username, required this.repoName}) : super(key: key);

  @override
  _RepoDetailsPageState createState() => _RepoDetailsPageState();
}

class _RepoDetailsPageState extends State<RepoDetailsPage> {
  Map<String, dynamic> repoDetails = {};

  @override
  void initState() {
    super.initState();
    fetchRepoDetails();
  }

  Future<void> fetchRepoDetails() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/${widget.username}/${widget.repoName}'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        repoDetails = jsonData;
      });
    } else {
      print('Failed to load repository details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} / ${widget.repoName}'),
      ),
      body: repoDetails.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: screenWidth,
                height: 300, 
                child: Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repository Name: ${repoDetails['name'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Description: ${repoDetails['description'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Language: ${repoDetails['language'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Forks: ${repoDetails['forks_count'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Stars: ${repoDetails['stargazers_count'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Watchers: ${repoDetails['watchers_count'] ?? 'N/A'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
