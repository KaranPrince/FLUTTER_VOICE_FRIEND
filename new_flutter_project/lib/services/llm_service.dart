// File: lib/services/llm_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_voice_friend/services/session_service.dart';
import 'package:flutter_voice_friend/utils/llm_chain.dart';
import 'package:flutter_voice_friend/utils/text_utils.dart';

import '../config.dart';
import '../llm_templates/all_templates.dart';
import 'user_service.dart';
import 'audio_service.dart';
import '../models/activity.dart';

class LLMService {
  String template = templateIntroduction;
  late final LLMChainLibrary llmChain;
  late final UserService userService;
  late final AudioService audioService;
  late final SessionService sessionService;

  late void Function() onRunChainListen;
  late void Function(bool) onRunChainDone;

  String? _humanInput;
  String? _aiOutput;

  StreamSubscription<String>? _llmStreamSubscription;

  final StreamController<Exception> _errorController = StreamController<Exception>.broadcast();

  Stream<Exception> get errorStream => _errorController.stream;

  void initialize(
      LLMChainLibrary llmChain, UserService userService, SessionService sessionService, AudioService audioService) {
    this.llmChain = llmChain;
    this.audioService = audioService;
    this.userService = userService;
    this.sessionService = sessionService;

    this.audioService.errorStream.listen((Exception error) {
      _errorController.add(error);
    });
  }

  void cancelOperations() {
    _llmStreamSubscription?.cancel();
    _llmStreamSubscription = null;
  }

  /// ✅ **Updated to Support New Activity**
  void updateTemplate(Activity activity) {
    switch (activity.activityId) {
      case ActivityId.introduction:
        llmChain.setTemplate(templateIntroduction);
        break;
      case ActivityId.dreamAnalyst:
        llmChain.setTemplate(templateDreamAnalyst);
        break;
      case ActivityId.myNewActivity: // ✅ New activity support
        llmChain.setTemplate(templateMyNewActivity);
        break;
      default:
        debugPrint("No specific template found for ${activity.activityId}");
        break;
    }
  }

  /// ✅ **Enhanced runChain() with better error handling**
  Future<void> runChain(String input, String sessionsHistorySummary) async {
    try {
      var streamableChain = llmChain.getChain();
      ActivityId currentActivityId = userService.currentActivity.activityId;

      String llmOutput = "";
      String allText = "";

      _humanInput = input;
      _aiOutput = "";

      String userInfo = currentActivityId == ActivityId.introduction ? "" : userService.userInformation;
      String memory = currentActivityId == ActivityId.introduction ? "" : sessionsHistorySummary;

      debugPrint("🟢 User information: $userInfo");
      debugPrint("🟢 Session History Summary: $sessionsHistorySummary");

      final chatHistory = await llmChain.memory.loadMemoryVariables();
      final promptAsString = llmChain.promptTemplate.format({
        'user_information': userInfo,
        'session_history': memory,
        'input': input,
        'language': Config.languageStringToAdd[userService.selectedLanguage],
        'chat_history': chatHistory['chat_history'], // Assuming chat history is retrieved separately
      });

      debugPrint("Generated Prompt: $promptAsString");

      _llmStreamSubscription = streamableChain.stream({
        'user_information': userInfo,
        'session_history': memory,
        'input': input,
        'language': Config.languageStringToAdd[userService.selectedLanguage]
      }).listen(
            (result) {
          llmOutput += result;
          allText += result;

          final segmented = segmentTextBySentence(llmOutput);
          final completeSentences = segmented['completeSentences'] as List<String>;
          final remainingText = segmented['remainingText'] as String;

          for (var sentence in completeSentences) {
            debugPrint("🔹 Processing sentence: $sentence");
            audioService.playTextToSpeech(sentence);
          }

          llmOutput = remainingText;
          onRunChainListen();
        },
        onError: (error) {
          debugPrint("🔴 Error: ${error.toString()}");
          _handleError(Exception('LLM runChain onError: $error'));
        },
        onDone: () {
          debugPrint("✅ Processing remaining sentence: $llmOutput");
          audioService.playTextToSpeech(llmOutput);
          _humanInput = input;
          _aiOutput = allText;
          bool containsEndTag = allText.contains("[END]");
          onRunChainDone(containsEndTag);
        },
      );
    } catch (e) {
      _handleError(Exception('LLM runChain Exception: $e'));
    }
  }

  void updateChainMemory() {
    if (_humanInput != null && _aiOutput != null) {
      llmChain.updateMemory(_humanInput!, _aiOutput!);
    } else {
      debugPrint("❌ Error: Cannot update memory, input or output is null.");
    }
  }

  /// ✅ **Centralized error handling**
  void _handleError(Exception e) {
    debugPrint('🔴 Error in LLMService: $e');
    if (!_errorController.isClosed) {
      _errorController.add(e);
    }
  }
}
