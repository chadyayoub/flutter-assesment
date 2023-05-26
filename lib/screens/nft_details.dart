import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NFTDetailsPage extends StatefulWidget {
  final String id;

  const NFTDetailsPage({required this.id, super.key});

  @override
  _NFTDetailsPageState createState() => _NFTDetailsPageState();
}

class _NFTDetailsPageState extends State<NFTDetailsPage> {
  dynamic nftData;
  bool isLoading = false;
  String comment = '';
  List<String> comments = [];

  @override
  void initState() {
    super.initState();
    fetchNFTData();
  }

  Future<void> fetchNFTData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://api.coingecko.com/api/v3/nfts/${widget.id}');
    final response = await http.get(url);

    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        nftData = data;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void addComment() {
    if (comment.isNotEmpty) {
      setState(() {
        comments.add(comment);
        comment = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nftData == null ? '' : nftData['name']),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : nftData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        nftData['image']['small'],
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Name: ${nftData['name']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'ID: ${nftData['id']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            comment = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Enter a comment',
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: addComment,
                        child: const Text('Add Comment'),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Comments:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (comments.isEmpty) const Text('No comments yet.'),
                      Column(
                        children: comments.map((comment) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(comment),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('Failed to fetch NFT data.')),
    );
  }
}
