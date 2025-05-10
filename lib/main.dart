import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'test.dart';

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
          title: 'ALU ESP Interface',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'WinkyRough',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme:
                ThemeData.dark().textTheme.apply(fontFamily: 'Winky Rough'),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.deepPurple[900],
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MyHomePage(title: 'ALU ESP Interface'),
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

String _serverUrl = 'http://192.168.1.69:3000/write';
String _pingUrl = 'http://192.168.1.69:3000/read';
String _result = ' ';

class _MyHomePageState extends State<MyHomePage> {
  String _a = '0000'; // 4-bit binary A
  String _b = '0000'; // 4-bit binary B
  String _s3 = '0'; // 1-bit binary S3
  String _s2 = '0'; // 1-bit binary S2
  String _s1 = '0'; // 1-bit binary S1
  String _s0 = '0'; // 1-bit binary S0
  String _cin = '0'; // 1-bit binary Cin

  late TextEditingController _aBinaryController;
  late TextEditingController _aDecimalController;
  late TextEditingController _bBinaryController;
  late TextEditingController _bDecimalController;
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _pingUrlController = TextEditingController();
  bool _hapticEnabled = true; // New setting for haptic feedback

  @override
  void initState() {
    super.initState();
    _aBinaryController = TextEditingController(text: _a);
    _aDecimalController =
        TextEditingController(text: int.parse(_a, radix: 2).toString());
    _bBinaryController = TextEditingController(text: _b);
    _bDecimalController =
        TextEditingController(text: int.parse(_b, radix: 2).toString());
    _serverUrlController.text = _serverUrl;
    _pingUrlController.text = _pingUrl;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _aBinaryController.dispose();
    _aDecimalController.dispose();
    _bBinaryController.dispose();
    _bDecimalController.dispose();
    super.dispose();
  }

  Widget _buildBinaryRow(String label, List<String> values,
      Function(int, String) onChanged, Function(String) updateBinary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold)), // Increased font size
        SizedBox(height: 12), // Increased spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(values.length, (i) {
            return GestureDetector(
              onTap: () {
                final nv = values[i] == '0' ? '1' : '0';
                onChanged(i, nv);
                updateBinary(values.join());
              },
              child: Padding(
                padding:
                    const EdgeInsets.all(8.0), // Added padding for touch target
                child: Icon(
                  values[i] == '1' ? Icons.circle : Icons.circle_outlined,
                  color: values[i] == '1' ? Colors.pink : Colors.pink.shade300,
                  size: 64, // Doubled the size from 32 to 64
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBinaryInput(
      String label, String value, Function(String) onChanged) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold)), // Increased font size
        SizedBox(height: 12), // Increased spacing
        GestureDetector(
          onTap: () => onChanged(value == '0' ? '1' : '0'),
          child: Icon(
            value == '1' ? Icons.toggle_on : Icons.toggle_off,
            color: Colors.pink,
            size: 80, // Doubled the size from 40 to 80
          ),
        ),
      ],
    );
  }

  void _submitData() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestPage(
          a: _a,
          b: _b,
          s3: _s3,
          s2: _s2,
          s1: _s1,
          s0: _s0,
          cin: _cin,
          serverUrl: _serverUrl,
          pingUrl: _pingUrl,
        ),
      ),
    );
  }

  void _toggleTheme() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }

  List<String> _aBits = ['0', '0', '0', '0'];
  List<String> _bBits = ['0', '0', '0', '0'];

  void _updateUrls() {
    setState(() {
      _serverUrl = _serverUrlController.text;
      _pingUrl = _pingUrlController.text;
    });
    Navigator.pop(context); // Close the drawer
    _showSnackBar('URLs updated successfully');
  }

  final Map<String, Map<String, dynamic>> _options = {
    "A": {
      "description": "",
      "selectors": [0, 0, 0, 0, 0]
    },
    "A+1": {
      "description": "",
      "selectors": [0, 0, 0, 0, 1]
    },
    "A+B": {
      "description": "",
      "selectors": [0, 0, 0, 1, 0]
    },
    "A+B+1": {
      "description": "",
      "selectors": [0, 0, 0, 1, 1]
    },
    "A-B-1": {
      "description": "",
      "selectors": [0, 0, 1, 0, 0]
    },
    "A-B": {
      "description": "",
      "selectors": [0, 0, 1, 0, 1]
    },
    "A-1": {
      "description": "",
      "selectors": [0, 0, 1, 1, 0]
    },
    "A ": {
      "description": "",
      "selectors": [0, 0, 1, 1, 1]
    },
    "A AND B": {
      "description": "",
      "selectors": [0, 1, 0, 0, 0]
    },
    "A OR B": {
      "description": "",
      "selectors": [0, 1, 0, 1, 0]
    },
    "A XOR B": {
      "description": "",
      "selectors": [0, 1, 1, 0, 0]
    },
    "NOT A": {
      "description": "",
      "selectors": [0, 1, 1, 1, 0]
    },
    "Shr A": {
      "description": "",
      "selectors": [1, 0, 0, 0, 0]
    },
    "Shl A": {
      "description": "",
      "selectors": [1, 1, 0, 0, 0]
    },
  };

  String? _selectedOption;

  void _updateSelectors(List<int> selectors) {
    setState(() {
      _s3 = selectors[0].toString();
      _s2 = selectors[1].toString();
      _s1 = selectors[2].toString();
      _s0 = selectors[3].toString();
      _cin = selectors[4].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDark, child) {
                return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
              },
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade100, Colors.pink.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text('Sara Medhat'),
                accountEmail: Text('SaraMedhat@gmail.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.pink, size: 36),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text('Home', style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                hoverColor: Colors.pink.shade200,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.history, color: Colors.white),
                title: Text('History', style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                hoverColor: Colors.pink.shade200,
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('History feature coming soon!');
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.white),
                title: Text('About App', style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                hoverColor: Colors.pink.shade200,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'ALU CALC',
                    applicationVersion: '1.0.3',
                    applicationIcon: Icon(Icons.computer, color: Colors.pink),
                    children: [Text('A Mobile Interface to the ALU.')],
                  );
                },
              ),
              Divider(color: Colors.white70),
              ExpansionTile(
                title:
                    Text('Appearance', style: TextStyle(color: Colors.white)),
                iconColor: Colors.white,
                childrenPadding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SwitchListTile(
                    title: Text('Dark Mode',
                        style: TextStyle(color: Colors.white)),
                    value: isDarkModeNotifier.value,
                    activeColor: Colors.white,
                    onChanged: (val) => setState(() {
                      isDarkModeNotifier.value = val;
                    }),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _serverUrlController,
                  decoration: InputDecoration(
                    labelText: 'Server URL',
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _pingUrlController,
                  decoration: InputDecoration(
                    labelText: 'Ping URL',
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pinkAccent, Colors.pink],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _updateUrls,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Save URLs',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              ExpansionTile(
                title: Text('Advanced Settings',
                    style: TextStyle(color: Colors.white)),
                iconColor: Colors.white,
                childrenPadding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SwitchListTile(
                    title: Text('Haptic Feedback',
                        style: TextStyle(color: Colors.white)),
                    value: _hapticEnabled,
                    activeColor: Colors.white,
                    onChanged: (val) => setState(() => _hapticEnabled = val),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Center(
                child: Text('Version 1.0.0',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Operations section now placed at the top

              SizedBox(height: 16),
              // SizedBox(height: 32), // Increased spacing between sections

              // Binary input section
              Text('selectors S3, S2, S1, S0 and Cin ',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBinaryInput(
                      'S3', _s3, (value) => setState(() => _s3 = value)),
                  SizedBox(width: 12),
                  _buildBinaryInput(
                      'S2', _s2, (value) => setState(() => _s2 = value)),
                  SizedBox(width: 12),
                  _buildBinaryInput(
                      'S1', _s1, (value) => setState(() => _s1 = value)),
                  SizedBox(width: 12),
                  _buildBinaryInput(
                      'S0', _s0, (value) => setState(() => _s0 = value)),
                  SizedBox(width: 12),
                  _buildBinaryInput(
                      'Cin', _cin, (value) => setState(() => _cin = value)),
                ],
              ),
              SizedBox(height: 32), // Increased spacing

              // Binary input values
              _buildBinaryRow(
                'A',
                _aBits,
                (index, value) => setState(() {
                  _aBits[index] = value;
                  _a = _aBits.join();
                }),
                (binary) => setState(() => _a = binary),
              ),
              SizedBox(height: 24),
              _buildBinaryRow(
                'B',
                _bBits,
                (index, value) => setState(() {
                  _bBits[index] = value;
                  _b = _bBits.join();
                }),
                (binary) => setState(() => _b = binary),
              ),
              SizedBox(height: 30),
              Text('Operations',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink)),
              Wrap(
                spacing: 16.0, // Further increased spacing
                runSpacing: 12.0, // Further increased run spacing
                children: _options.entries.map((entry) {
                  return ChoiceChip(
                    label: Text(entry.key,
                        style: TextStyle(fontSize: 18)), // Increased font size
                    selected: _selectedOption == entry.key,
                    onSelected: (selected) {
                      setState(() {
                        _selectedOption = selected ? entry.key : null;
                        if (selected)
                          _updateSelectors(entry.value['selectors']);
                      });
                    },
                    selectedColor: Colors.pink,
                    backgroundColor: Colors.pink[50],
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8), // Added padding
                    labelStyle: TextStyle(
                      color: _selectedOption == entry.key
                          ? Colors.white
                          : Colors.pink[800],
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),// Added extra space for the floating button
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitData,
        icon: Icon(Icons.send,
            color: Colors.white, size: 28), // Increased icon size
        label: Text('Submit',
            style: TextStyle(
                color: Colors.white, fontSize: 20)), // Increased text size
        backgroundColor: Colors.pink,
        extendedPadding: EdgeInsets.symmetric(
            horizontal: 32, vertical: 16), // Increased padding
      ),
    );
  }
}
