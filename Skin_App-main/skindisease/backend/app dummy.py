
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    var res = await ApiService.getHistory();
    setState(() {
      history = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History")),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          var item = history[index];

          return ListTile(
            title: Text(item["disease"]),
            subtitle: Text("Confidence: ${item["confidence"]}"),
          );
        },
      ),
    );
  }
}