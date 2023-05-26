import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:assesment/nft_component.dart';
import 'package:assesment/screens/nft_details.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  MyWidgetState createState() => MyWidgetState();
}

class MyWidgetState extends State<MainScreen> {
  List<dynamic> nfts = [];
  int page = 1;
  int perPage = 30;
  bool isLoading = false;

  Future<void> fetchData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      final url = Uri.parse(
          'https://api.coingecko.com/api/v3/nfts/list?page=$page&per_page=$perPage');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          nfts.addAll(data);
          // page++;
        });
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Add this line to fetch data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFTs List'),
      ),
      body: ListView.builder(
        itemCount: nfts.length + 1,
        itemBuilder: (context, index) {
          if (index < nfts.length) {
            final nft = nfts[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NFTDetailsPage(
                      id: nft['id'],
                    ),
                  ),
                );
              },
              child: NFTCard(
                name: nft['name'],
                id: nft['id'],
              ),
            );
          } else {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Container(); // Placeholder for empty space or end of the list
            }
          }
        },
      ),
    );
  }
}
