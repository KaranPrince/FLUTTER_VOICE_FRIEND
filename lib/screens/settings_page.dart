import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter_voice_friend/activities.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

const textColor = Color.fromRGBO(255, 255, 255, 1);

class SettingsPage extends StatefulWidget {
  final UserService userService;
  final Isar isar;

  const SettingsPage({
    super.key,
    required this.userService,
    required this.isar,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedLanguage;
  late bool _autoToggleRecording;
  late String _selectedSpeechToTextMethod;
  late String _selectedAudioBackend;
  late String _selectedVoice;
  late int _selectedLevel;
  late double _selectedVoiceSpeed;
  late TextEditingController _userInfoController;
  late TextEditingController _deleteController;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.userService.selectedLanguage;
    _autoToggleRecording = widget.userService.autoToggleRecording;
    _selectedSpeechToTextMethod = widget.userService.selectedSpeechToTextMethod;
    _selectedAudioBackend = widget.userService.selectedAudioBackend;
    _selectedVoice = widget.userService.selectedVoice;
    _selectedLevel = widget.userService.level;
    _selectedVoiceSpeed = widget.userService.voiceSpeed;
    _userInfoController =
        TextEditingController(text: widget.userService.userInformation);
    _deleteController = TextEditingController();
  }

  /// Builds a reusable dropdown widget.
  Widget _buildDropdown({
    required String label,
    required String currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        DropdownButton<String>(
          value: currentValue,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: Colors.blue,
          underline: Container(
            height: 2,
            color: Colors.white,
          ),
          items: items
              .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: textColor),
                        ),
                      ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Displays a warning dialog for deleting all activity data.
  void _confirmDeleteData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Warning: Irreversible Action'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You are about to permanently delete all your data and reset your progress. This action cannot be undone.'
                    '\n\nTo confirm, please type DELETE below.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deleteController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type DELETE',
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Triggers a rebuild when the text changes
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without action
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _deleteController.text == 'DELETE'
                      ? () async {
                          Navigator.pop(
                              context); // Close the dialog before action
                          await _deleteActivityData();
                        }
                      : null, // Disable button if DELETE is not typed
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete Data'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Deletes all activity data and resets the app.
  Future<void> _deleteActivityData() async {
    try {
      // Reset the Isar database
      await widget.isar.writeTxn(() async {
        await widget.isar.clear(); // Clear all collections in the database
      });
      await syncActivities(widget.isar);

      debugPrint('All activity data has been deleted.');

      // Reset the level and user information
      setState(() {
        _selectedLevel = 0;
        _userInfoController.text = '';
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userInformation', "");
      await prefs.setInt('level', 0);
      await prefs.setString('memory', "");
      await prefs.setInt('lastSessionSavedInMemory', -1);
      await prefs.setString('memoryAdultCompanion', "");
      await prefs.setInt('lastSessionSavedInMemoryAdultCompanion', -1);

      // Show confirmation after data is deleted
      _showConfirmationDialog();
    } catch (e) {
      _showErrorDialog('Failed to delete data. Please try again.');
      debugPrint('Error deleting data: $e');
    }
  }

  /// Displays a confirmation dialog after successful data deletion.
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Action Successful'),
          content: const Text(
              'Your activity data has been successfully cleared. The app will now restart to apply changes and ensure a fresh start.'),
          actions: [
            TextButton(
              onPressed: () {
                Phoenix.rebirth(context); // Restart the app
              },
              child: const Text('Restart Now'),
            ),
          ],
        );
      },
    );
  }

  /// Displays an error dialog with the provided message.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1, // Two tabs: Settings and Memories
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Settings', icon: Icon(Icons.settings)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, {
                'autoToggleRecording': _autoToggleRecording,
                'selectedLanguage': _selectedLanguage,
                'selectedSpeechToTextMethod': _selectedSpeechToTextMethod,
                'selectedAudioBackend': _selectedAudioBackend,
                'selectedVoice': _selectedVoice,
                'selectedLevel': _selectedLevel,
                'selectedVoiceSpeed': _selectedVoiceSpeed,
                'userInformation': _userInfoController.text,
              });
            },
          ),
        ),
        body: TabBarView(
          children: [
            // Settings Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdown(
                      label: 'Language',
                      currentValue: _selectedLanguage,
                      items: ['EN', 'FR', 'ES'],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedLanguage = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Auto Toggle Recording',
                        style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _autoToggleRecording,
                      onChanged: (bool value) {
                        setState(() {
                          _autoToggleRecording = value;
                        });
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Speech-to-Text Method',
                      currentValue: _selectedSpeechToTextMethod,
                      items: [Config.deepgramStt, Config.onDeviceStt],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSpeechToTextMethod = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Audio Backend',
                      currentValue: _selectedAudioBackend,
                      items: [Config.soloudBackend, Config.justAudioBackend],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedAudioBackend = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Voice',
                      currentValue: _selectedVoice,
                      items: [
                        Config.voiceAlloy,
                        Config.voiceEcho,
                        Config.voiceFable,
                        Config.voiceOnyx,
                        Config.voiceNova,
                        Config.voiceShimmer
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedVoice = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Voice Cadence', style: TextStyle(fontSize: 18)),
                    Slider(
                      value: _selectedVoiceSpeed,
                      min: 0.8,
                      max: 1.0,
                      divisions: 4,
                      label: _getLabelForSpeed(_selectedVoiceSpeed),
                      onChanged: (double value) {
                        setState(() {
                          _selectedVoiceSpeed = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Level', style: TextStyle(fontSize: 18)),
                    Slider(
                      value: _selectedLevel.toDouble(),
                      min: 0,
                      max: 9,
                      divisions: 9,
                      label: _selectedLevel.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _selectedLevel = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('User Information',
                        style: TextStyle(fontSize: 18)),
                    TextField(
                      controller: _userInfoController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your information',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Display Debug Infos (Not implemented)',
                        style: TextStyle(fontSize: 14)),
                    Switch(
                      value: Config.debug,
                      onChanged: (bool value) {
                        setState(() {
                          Config.debug = value;
                        });
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                    const SizedBox(height: 32),
                    const Text('Reset All Data',
                        style: TextStyle(fontSize: 18, color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _confirmDeleteData,
                      child: const Text('Delete All Activity Data'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getLabelForSpeed(double value) {
  // Round the value to 2 decimal places
  double roundedValue = double.parse(value.toStringAsFixed(2));

  switch (roundedValue) {
    case 0.8:
      return 'Slowest';
    case 0.85:
      return 'Slower';
    case 0.9:
      return 'Normal';
    case 0.95:
      return 'Faster';
    case 1.0:
      return 'Fastest';
    default:
      return roundedValue.toString();
  }
}
