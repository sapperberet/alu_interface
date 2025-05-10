import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestPage extends StatefulWidget {
  final String a;
  final String b;
  final String s3;
  final String s2;
  final String s1;
  final String s0;
  final String cin;
  final String serverUrl;
  final String pingUrl;
  const TestPage({
    Key? key,
    required this.a,
    required this.b,
    required this.s3,
    required this.s2,
    required this.s1,
    required this.s0,
    required this.cin,
    required this.serverUrl,
    required this.pingUrl,
  }) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _status = 'Sending Data...';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _sendAndFetch();
  }

  Future<void> _sendAndFetch() async {
    final msg =
        '${widget.b}${widget.a}${widget.cin}${widget.s3}${widget.s2}${widget.s1}${widget.s0}000';
    try {
      final uri =
          Uri.parse(widget.serverUrl).replace(queryParameters: {'msg': msg});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() => _status = 'Waiting for result...');
      } else {
        setState(() => _status = 'Failed to send: ${response.statusCode}');
        return;
      }
      await Future.delayed(Duration(seconds: 2));
      final pingResp = await http.get(Uri.parse(widget.pingUrl));
      if (pingResp.statusCode == 200) {
        setState(() {
          _status = 'Result:';
          _result = pingResp.body;
        });
      } else {
        setState(() => _status = 'Failed to fetch: ${pingResp.statusCode}');
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selected values display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSelectionChip(widget.a, theme.colorScheme.primary),
                  _buildSelectionChip(widget.b, theme.colorScheme.secondary),
                ],
              ),
              SizedBox(height: 32),
              // Status display
              Text(_status,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              // Progress indicator or result
              if (_result.isEmpty && !_status.startsWith('Error'))
                CircularProgressIndicator(color: Colors.pink),
              if (_result.isNotEmpty) ...
                [
                  SizedBox(height: 16),
                  Text(_result, style: TextStyle(fontSize: 16, color: Colors.pink)),
                ],
              Spacer(),
              // Action buttons
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionChip(String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: color, size: 16),
          SizedBox(width: 8),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
