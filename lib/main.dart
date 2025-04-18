import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Binary Input Interface',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'WinkyRough',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Winky Rough'),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blueGrey[900],
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MyHomePage(title: 'Binary Input Interface'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _a = '0000'; // 4-bit binary A
  String _b = '0000'; // 4-bit binary B
  String _s3 = '0';   // 1-bit binary S3
  String _s2 = '0';   // 1-bit binary S2
  String _s1 = '0';   // 1-bit binary S1
  String _s0 = '0';   // 1-bit binary S0
  String _cin = '0';  // 1-bit binary Cin

  late TextEditingController _aBinaryController;
  late TextEditingController _aDecimalController;
  late TextEditingController _bBinaryController;
  late TextEditingController _bDecimalController;

  @override
  void initState() {
    super.initState();
    _aBinaryController = TextEditingController(text: _a);
    _aDecimalController = TextEditingController(text: int.parse(_a, radix: 2).toString());
    _bBinaryController = TextEditingController(text: _b);
    _bDecimalController = TextEditingController(text: int.parse(_b, radix: 2).toString());
  }

  @override
  void dispose() {
    _aBinaryController.dispose();
    _aDecimalController.dispose();
    _bBinaryController.dispose();
    _bDecimalController.dispose();
    super.dispose();
  }

  Widget _buildInputRow(String label, TextEditingController binaryController, TextEditingController decimalController, Function(String) onBinaryChanged, Function(String) onDecimalChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: binaryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Binary (4 bits)',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[01]{0,4}$')), // Allow only 0 or 1, up to 4 digits
                ],
                onChanged: (binaryInput) {
                  if (binaryInput.length <= 4 && RegExp(r'^[01]*$').hasMatch(binaryInput)) {
                    onBinaryChanged(binaryInput);
                    if (binaryInput.isNotEmpty && binaryInput.length == 4) {
                      int decimal = int.parse(binaryInput, radix: 2);
                      decimalController.text = decimal.toString();
                    } else {
                      decimalController.text = '';
                    }
                  }
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: decimalController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Decimal (0-15)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]{0,2}$')), // Allow only digits, up to 2 digits
                ],
                onChanged: (decimalInput) {
                  if (decimalInput.isNotEmpty) {
                    int? decimal = int.tryParse(decimalInput);
                    if (decimal != null && decimal >= 0 && decimal <= 15) {
                      String binary = _decimalToBinary(decimal, 4);
                      binaryController.text = binary;
                      onDecimalChanged(decimalInput);
                    } else {
                      binaryController.text = '';
                    }
                  } else {
                    binaryController.text = '';
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _decimalToBinary(int decimal, int bits) {
    return decimal.toRadixString(2).padLeft(bits, '0');
  }

  Widget _buildBinaryInput(String label, String value, Function(String) onChanged) {
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: label,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[01]$')), // Allow only 0 or 1
        ],
        onChanged: (input) {
          if (input == '0' || input == '1') {
            onChanged(input);
          }
        },
      ),
    );
  }


  //TODO
  // void _submitData() async {
  //   final String esp8266Url = 'http://<ESP8266_IP_ADDRESS>/submit';
  //   final Map<String, String> data = {
  //     'A': _a,
  //     'B': _b,
  //     'S3': _s3,
  //     'S2': _s2,
  //     'S1': _s1,
  //     'S0': _s0,
  //     'Cin': _cin,
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(esp8266Url),
  //       body: data,
  //     );
  //     if (response.statusCode == 200) {
  //       print('Data sent successfully: ${response.body}');
  //     } else {
  //       print('Failed to send data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error sending data: $e');
  //   }
  // }
  void _submitData() async {
    final String serverUrl = 'http://192.168.1.69:3000/log';
    final Map<String, String> data = {
      'msg': '$_a$_b$_s3$_s2$_s1$_s0$_cin',
    };

    try {
      final uri = Uri.parse(serverUrl).replace(queryParameters: data);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  void _toggleTheme() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInputRow(
              'Enter 4-bit Binary A:',
              _aBinaryController,
              _aDecimalController,
                  (value) => setState(() => _a = value),
                  (value) => setState(() => _a = _decimalToBinary(int.tryParse(value) ?? 0, 4)),
            ),
            SizedBox(height: 16),
            _buildInputRow(
              'Enter 4-bit Binary B:',
              _bBinaryController,
              _bDecimalController,
                  (value) => setState(() => _b = value),
                  (value) => setState(() => _b = _decimalToBinary(int.tryParse(value) ?? 0, 4)),
            ),
            SizedBox(height: 16),
            Text('Enter 5-bit Binary (S3, S2, S1, S0, Cin):'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBinaryInput('S3', _s3, (value) => setState(() => _s3 = value)),
                SizedBox(width: 8),
                _buildBinaryInput('S2', _s2, (value) => setState(() => _s2 = value)),
                SizedBox(width: 8),
                _buildBinaryInput('S1', _s1, (value) => setState(() => _s1 = value)),
                SizedBox(width: 8),
                _buildBinaryInput('S0', _s0, (value) => setState(() => _s0 = value)),
                SizedBox(width: 8),
                _buildBinaryInput('Cin', _cin, (value) => setState(() => _cin = value)),
              ],
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blueAccent,
                ),
                child: Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTheme,
        child: ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, child) {
            return Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

