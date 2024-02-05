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
      setState(() {
        gists = gistsJsonList;
      });
    } else {
      print('Failed to load gists');
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

Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${widget.username}\'s Gists'),
    ),
    body: SingleChildScrollView(
      child: DataTable(
        columns: [
          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Files', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: List.generate(
          gists.length,
          (index) => DataRow(cells: [
            DataCell(Text(gists[index]['description'] ?? 'No description')),
            DataCell(Text('${gists[index]['files'].length} Files')),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   icon: Icon(Icons.visibility),
                //   onPressed: () {
                //     // Handle view action, e.g., navigate to a detailed page
                //   },
                // ),
//               IconButton(
//   icon: Icon(Icons.code),
//   onPressed: () {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Gist Code'),
//           content: SingleChildScrollView(
//             child: Text('Display the code content here'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   },
// )

              ],
            )),
          ]),
        ),
      ),
    ),
    bottomNavigationBar: Row(
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
  );
}

}
