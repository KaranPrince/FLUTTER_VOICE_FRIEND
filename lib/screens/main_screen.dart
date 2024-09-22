// lib/screens/main_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_voice_friend/widgets/playing/playing_animation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_voice_friend/services/connection_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:isar/isar.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:flutter_voice_friend/activities.dart';
import 'package:flutter_voice_friend/llm_templates/all_templates.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:flutter_voice_friend/services/audio_service.dart';
import 'package:flutter_voice_friend/services/permission_service.dart';
import 'package:flutter_voice_friend/services/speech_service.dart';
import 'package:flutter_voice_friend/services/animation_controller_service.dart';
import 'package:flutter_voice_friend/services/llm_service.dart';
import 'package:flutter_voice_friend/services/session_service.dart';
import 'package:flutter_voice_friend/services/user_service.dart';
import 'package:flutter_voice_friend/widgets/app_bar_widget.dart';
import 'package:flutter_voice_friend/screens/main_menu.dart';
import 'package:flutter_voice_friend/utils/llm_chain.dart';
import 'package:flutter_voice_friend/widgets/dialog_helper.dart';
import 'package:flutter_voice_friend/widgets/common/retry_cancel_widget.dart';
import 'package:flutter_voice_friend/widgets/common/error_dialog.dart';
import 'package:flutter_voice_friend/widgets/activity/image_of_activity.dart';
import 'package:flutter_voice_friend/widgets/listening/listening_animation.dart';
import 'package:flutter_voice_friend/widgets/audio_controls/bottom_icons_when_listening.dart';
import 'package:flutter_voice_friend/widgets/listening/listening_message.dart';
import 'package:flutter_voice_friend/widgets/common/loading_widget.dart';
import 'package:flutter_voice_friend/widgets/indicators/play_indicator.dart';
import 'package:flutter_voice_friend/widgets/audio_controls/bottom_icons_when_playing.dart';
import 'package:flutter_voice_friend/widgets/indicators/simple_loading_indicator.dart';
import 'package:flutter_voice_friend/widgets/playing/subtitle_widget.dart';

Random random = Random();
const infoColor = Color.fromRGBO(69, 0, 0, 1);
const textColor = Color.fromRGBO(255, 255, 255, 1);

class MainScreen extends StatefulWidget {
  final Isar isar;

  const MainScreen({super.key, required this.isar});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late Isar isar = widget.isar;

  Ticker? _ticker;

  String transcription = "";

  /// Indicates whether the app is still loading (true when first launched)
  bool _isLoading = true;

  /// Message to display during the loading process
  String _loadingInfo = "";

  /// Tracks if it's the first message in the conversation
  /// (controls the display of activity picture and play button)
  bool _firstMessage = true;
  bool _resetToPlayActivityScreenOnError = true;

  /// Indicates if the app is actively listening to the user's voice input
  bool _isListening = false;

  /// True if a command has been sent to the language model (LLM) and we're waiting for a response
  bool _waitingLLMResponse = false;

  /// True when the LLM has started streaming but hasn't finished the response yet
  bool _remainingLLMResponse = false;

  /// True if the user has paused the audio player
  bool _isPaused = false;

  /// Indicates if the app is in listening mode, either listening or waiting for the user to start speaking
  bool _listeningMode = false;

  /// Flag indicating the end of the current activity
  bool _endActivity = false;

  /// Flag indicating that LLM memory needs to be updated
  bool _chainMemoryNeedUpdate = false;

  late DateTime sessionStartTime;

  late SpeechService speechService;
  late AudioService audioService;
  late SessionService sessionService;
  late UserService userService;
  late LLMService llmService;
  late AnimationControllerService animationControllerService;
  late ConnectionService connectionService;

  late final LLMChainLibrary chain = LLMChainLibrary(templateIntroduction);

  StreamSubscription<double>? _intensitySubscription;

  String sessionsHistorySummary = "";

  double _audioLevel = 0.0;

  final GlobalKey<ListeningAnimationState> _animationSoundInputKey =
      GlobalKey();
  final GlobalKey<PlayingAnimationState> _animationSoundOutputKey = GlobalKey();

  Function? _functionToRetry;

  // Add StreamSubscriptions for error streams
  StreamSubscription<Exception>? _audioServiceErrorSubscription;
  StreamSubscription<Exception>? _llmServiceErrorSubscription;
  StreamSubscription<Exception>? _speechServiceErrorSubscription;
  bool _isHandlingAnError = false;

  @override
  void initState() {
    super.initState();

    speechService = context.read<SpeechService>();
    audioService = context.read<AudioService>();
    sessionService = context.read<SessionService>();
    llmService = context.read<LLMService>();
    userService = context.read<UserService>();
    animationControllerService = context.read<AnimationControllerService>();
    connectionService = context.read<ConnectionService>();

    // Listen to error streams (audio, llm, speech)
    _audioServiceErrorSubscription =
        audioService.errorStream.listen((Exception error) {
      debugPrint('Received error from AudioService: $error');
      if (!_firstMessage) _functionToRetry = () => runChain();
      _handleError(error, "Error detected with Audio Service");
    });

    _llmServiceErrorSubscription =
        llmService.errorStream.listen((Exception error) {
      debugPrint('Received error from LLMService: $error');
      if (!_firstMessage) _functionToRetry = () => runChain();

      _handleError(error, "Error detected with LLM Service");
    });

    _speechServiceErrorSubscription =
        speechService.errorStream.listen((Exception error) {
      debugPrint('Received error from speechService: $error');
      if (!mounted) return;
      showErrorDialog(context,
          "Whisper is having trouble listening to you. Please check your internet connection and try again.");

      _cancelListening();
    });

    connectionService.connectionStatusStream.listen((status) {
      if (status == InternetStatus.disconnected) {
        _onConnectionLost();
      } else if (status == InternetStatus.connected) {
        _onConnectionRestored();
      }
    });

    speechService.onSoundLevelChange = (level) {
      if (!mounted) return;
      setState(() {
        _animationSoundInputKey.currentState?.updateScale(level);
        _audioLevel = level;
      });
    };

    speechService.onTranscription = (text) {
      if (!mounted) return;
      setState(() {
        transcription = text;
      });
    };

    llmService.onRunChainListen = () {
      if (!mounted) return;
      setState(() {
        _waitingLLMResponse = false;
      });
    };

    llmService.onRunChainDone = (containsEndTag) {
      if (!mounted) return;
      setState(() {
        _chainMemoryNeedUpdate = true;
        _firstMessage = false;
        _remainingLLMResponse = false;
        _endActivity = containsEndTag;
        if (userService.autoToggleRecording) {
          _checkTtsAudioStatus();
        }
      });
    };

    _intensitySubscription = audioService.intensityStream.listen((intensity) {
      _animationSoundOutputKey.currentState?.updateScale(intensity);
      setState(() {});
    });

    _initialize().then((success) {
      if (!success) {
        if (!mounted) return;
        showErrorDialog(
          context,
          "Whisper couldn't start the App. Please check your internet connection and try again.",
        ).then((_) {
          if (!mounted) return;
          Phoenix.rebirth(context);
        });
        return;
      }
      setState(() {
        _isLoading = false;
      });

      audioService.setVoiceSpeed(userService.voiceSpeed);

      if (userService.level > 0) {
        if (!mounted) return;
        navigateToMainMenu(context, userService.level, isar,
            (Activity activity) {
          _updateChain(activity);
        });
      } else {
        chain.setTemplate(templateIntroduction);
        userService.currentActivity = introductionActivity;
        _restartListening();
      }
    });
  }

  void _handleError(Exception error, String humanReadableErrorMessage) {
    if (_isHandlingAnError) {
      debugPrint("Ignoring error : ${error.toString()}");
      return;
    }

    _isHandlingAnError = true;
    _chainMemoryNeedUpdate = false;

    if (!mounted) return;
    showErrorDialog(
        context, "There was an issue processing your last command...");

    connectionService.forceUpdate();

    if (_resetToPlayActivityScreenOnError) {
      _functionToRetry = null;
    }

    setState(() {
      _firstMessage = _resetToPlayActivityScreenOnError;
      _waitingLLMResponse = false;
      _remainingLLMResponse = false;
    });
  }

  void _onConnectionLost() {
    debugPrint("_onConnectionLost called !");
    setState(() {});
    // Handle additional UI changes if necessary
  }

  void _onConnectionRestored() {
    debugPrint("_onConnectionRestored called !");
    // Handle additional UI changes if necessary
  }

  void updateLoadingInfo(String info) {
    setState(() {
      _loadingInfo = info;
    });
  }

  Future<bool> _initialize() async {
    try {
      WakelockPlus.enable();

      updateLoadingInfo("Requesting microphone permission");
      await PermissionService.requestMicrophonePermission();
      debugPrint("Microphone permission has been granted");

      updateLoadingInfo("Loading User Information");
      await userService.loadUserInformation();
      debugPrint("User information has been loaded");

      updateLoadingInfo("Initializing Audio Service");
      await audioService.initPlayer();
      audioService.initialize(userService.selectedAudioBackend,
          userService.selectedVoice, userService.voiceSpeed);
      debugPrint("Audio Service has been initialized");

      updateLoadingInfo("Initializing Speech Service");
      await speechService.initialize(userService.selectedSpeechToTextMethod);
      debugPrint("Speech Service has been initialized");

      updateLoadingInfo("Initializing LLM Service");
      llmService.initialize(chain, userService, sessionService, audioService);
      debugPrint("LLM Service has been initialized");

      updateLoadingInfo("Initializing Controllers");
      animationControllerService.initialize(this);
      _ticker = createTicker(_onTick);
      _ticker!.start();
      debugPrint("Controllers have been initialized");

      return true;
    } catch (e) {
      debugPrint('Initialization error: $e');
      setState(() {
        _isLoading = true;
      });
      return false;
    }
  }

  @override
  void dispose() {
    _intensitySubscription?.cancel();
    connectionService.stopMonitoring();
    _ticker?.stop();
    _ticker?.dispose();
    animationControllerService.dispose();
    WakelockPlus.disable();

    // Cancel error stream subscriptions
    _audioServiceErrorSubscription?.cancel();
    _llmServiceErrorSubscription?.cancel();
    _speechServiceErrorSubscription?.cancel();

    super.dispose();
  }

  void _toggleListening(bool isPressed) {
    debugPrint("_toggleListening");
    if (isPressed) {
      _startListening();
    } else {
      _stopListeningWithDelay();
    }
  }

  void _stopListeningWithDelay() {
    debugPrint("_stopListeningWithDelay");
    animationControllerService.buttonAnimationController.reverse();
    animationControllerService.listeningAnimationController.reverse();

    Future.delayed(const Duration(milliseconds: 800), () {
      debugPrint(
          "_stopListeningWithDelay: Trigger _stopListening after 800ms delay");
      _stopListening(); // Ensure this always happens
    });
  }

  Future<void> _startListening() async {
    debugPrint("_startListening");

    setState(() {
      _isListening = true;
      transcription = "";
    });

    audioService.deinitPlayer();

    speechService.startListening(
        userService.selectedSpeechToTextMethod, userService.selectedLanguage);

    animationControllerService.animationController.repeat(reverse: true);
  }

  void _cancelListening() {
    debugPrint("_cancelListening");
    speechService.stopListening(userService.selectedSpeechToTextMethod);

    animationControllerService.animationController.stop();
    animationControllerService.animationController.reset();

    setState(() {
      _isListening = false;
    });
  }

  Future<void> _stopListening() async {
    debugPrint("_stopListening");
    await speechService.stopListening(userService.selectedSpeechToTextMethod);
    await audioService.initPlayer();

    animationControllerService.animationController.stop();
    animationControllerService.animationController.reset();

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isListening = false;
      });
    });
    if (transcription.trim().length > 1) {
      runChain();
    }
  }

  Future<void> runSummarizeUserChain() async {
    debugPrint("Calling runSummarizeUserChain");
    setState(() {
      _isLoading = true;
      _loadingInfo = "Saving User Information";
    });
    userService.userInformation =
        await chain.getSummarizeUserChain().invoke({});

    setState(() {
      _isLoading = false;
      _loadingInfo = "";
    });
  }

  Future<String> runSummarizeSessionChain() async {
    debugPrint("Calling runSummarizeSessionChain");
    setState(() {
      _isLoading = true;
      _loadingInfo = "Saving your session";
    });
    String summary = await chain.getSummarizeSessionChain().invoke({});

    setState(() {
      _isLoading = false;
      _loadingInfo = "";
    });

    return summary;
  }

  Future<void> runChain() async {
    _isHandlingAnError = false;
    final currentTranscription = transcription;
    debugPrint("Calling runChain with transcription $transcription");

    audioService.stop();

    setState(() {
      _waitingLLMResponse = true;
      _remainingLLMResponse = true;
    });
    llmService.runChain(currentTranscription, sessionsHistorySummary);
  }

  void _checkTtsAudioStatus() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!audioService.hasAudioToPlay()) {
        timer.cancel();
        _toggleListening(true);
        animationControllerService.buttonAnimationController.forward();
        animationControllerService.listeningAnimationController.forward();
      }
    });
  }

  void _onTick(Duration elapsed) {
    if (_listeningMode && _chainMemoryNeedUpdate) {
      llmService.updateChainMemory();
      _chainMemoryNeedUpdate = false;
      _resetToPlayActivityScreenOnError = false;
      _isPaused = false;
    }
    if (_listeningMode && _endActivity) {
      debugPrint("End activity detected");
      _ticker!.stop();
      audioService.stop();
      _processEndActivity().then((value) {
        debugPrint("Activity processed successfully.");
      }).catchError((error) {
        debugPrint("Error in processEndActivity: $error");
      }).whenComplete(() {
        _ticker!.start(); // Ensure the ticker is restarted in any case
      });
    }
  }

  Future<void> _processEndActivity() async {
    if (userService.currentActivity.activityId == ActivityId.introduction) {
      await showIntroductionActivityCompletionDialog(context);

      if (userService.level == userService.currentActivity.requiredLevel) {
        await sessionService.updateActivity(userService.currentActivity);
        userService.level++;
      }

      await runSummarizeUserChain();
      await userService.saveUserInformation();

      _restartListening();
      if (!mounted) return;
      await navigateToMainMenu(context, userService.level, isar,
          (Activity activity) {
        _updateChain(activity);
      });
    } else {
      var memory = await chain.memory.loadMemoryVariables();
      if (memory['chat_history'].length > 2) {
        // Only save the session if there was an interaction with the user
        var conversationLog = memory['chat_history'].toString();
        var sessionSummary = await runSummarizeSessionChain();
        await sessionService.saveSession(conversationLog, sessionSummary,
            sessionStartTime, userService.currentActivity);
      } else {
        await sessionService.updateActivity(userService.currentActivity);
      }

      if (userService.level == userService.currentActivity.requiredLevel) {
        userService.level++;
        await userService.saveUserInformation();
      }
      if (!mounted) return;
      final value = await showActivityCompletionDialog(context);
      _restartListening();

      if (value == true) {
        // Logic to navigate to the main menu and handle result
        if (!mounted) return;
        await navigateToMainMenu(context, userService.level, isar,
            (Activity activity) {
          _updateChain(activity);
        });
      }
    }
  }

  void _endActivityPressed() async {
    debugPrint("End Activity Pressed");

    if (userService.currentActivity.activityId == ActivityId.introduction) {
      _restartListening();
    } else {
      _endActivity = true;
    }
  }

  void _restartListening() {
    debugPrint("_restartListening");

    // Reset Audio Player
    audioService.initPlayer();

    if (userService.currentActivity.activityId != ActivityId.introduction) {
      sessionService
          .generateUserActivitySummary(userService.currentActivity)
          .then((data) {
        sessionsHistorySummary = data;
        debugPrint(sessionsHistorySummary);
      });
    }

    transcription = "";
    audioService.stop();
    _firstMessage = true;
    _resetToPlayActivityScreenOnError = true;
    _endActivity = false;
    chain.clearMemory();
    sessionStartTime = DateTime.now();
  }

  void _updateChain(Activity activity) {
    if (activity.activityId != userService.currentActivity.activityId) {
      // Use activityId for comparisons
      llmService.updateTemplate(activity);
    }

    userService.currentActivity = activity;
    _restartListening();
  }

  void _handleSettingsResult(Map<String, dynamic> result) async {
    if ((result['selectedSpeechToTextMethod'] ??
            userService.selectedSpeechToTextMethod) !=
        userService.selectedSpeechToTextMethod) {
      await speechService
          .updateSpeechToTextMethod(result['selectedSpeechToTextMethod']);
    }
    userService.updateUserInfo(result);
    audioService.initialize(userService.selectedAudioBackend,
        userService.selectedVoice, userService.voiceSpeed);
  }

  Widget _buildPlayIcon() {
    return PlayIndicatorWidget(
        animationControllerService: animationControllerService,
        isListening: _isListening,
        title: userService.currentActivity.name,
        textColor: textColor,
        onPress: () {
          animationControllerService.buttonAnimationController.reverse();
          animationControllerService.listeningAnimationController.reverse();
          animationControllerService.animationController.reverse();

          Future.delayed(const Duration(milliseconds: 500), () {
            animationControllerService.animationController.stop();
            animationControllerService.animationController.reset();

            setState(() {
              _isListening = false;
            });
          });

          runChain();
        });
  }

  Widget _buildBottomIconsWhenPlaying() {
    return BottomIconsWhenPlaying(
      isPlaying: audioService.isPlaying(),
      isPaused: _isPaused,
      remainingLLMResponse: _remainingLLMResponse,
      onPause: () {
        if (_isPaused) return;
        setState(() {
          audioService.toggleAutoPause();
          _isPaused = true;
        });
      },
      onStop: () {
        if (_remainingLLMResponse) return;
        audioService.stop();
        setState(() {
          _isPaused = false;
        });
      },
      onRepeat: () {
        audioService.repeat();
      },
      onNext: () {
        audioService.next();
        if (audioService.lastAudioToPlay()) {
          setState(() {
            _isPaused = false;
          });
        }
      },
      onResume: () {
        audioService.toggleAutoPause();
        setState(() {
          _isPaused = false;
        });
      },
      lastAudioToPlay: audioService.lastAudioToPlay(),
    );
  }

  Widget _buildBottomIconsWhenListening() {
    return BottomIconsWhenListening(
      isListening: _isListening,
      animationControllerService: animationControllerService,
      onCancelListening: _cancelListening,
      onStopListening: _stopListeningWithDelay,
      onToggleListening: _toggleListening,
      onRestartListening: _endActivityPressed,
      firstMessage: _firstMessage,
    );
  }

  Widget _buildRetryCancelWidget() {
    return RetryCancelWidget(
      onRetry: () {
        if (_functionToRetry != null) {
          _isHandlingAnError = false;
          _functionToRetry!();
          _functionToRetry = null;
        }
      },
      onCancel: () {
        setState(() {
          _functionToRetry = null;
          _isHandlingAnError = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double subtitleSize =
        MediaQuery.of(context).size.shortestSide > 600 ? 40 : 24;

    final showLostConnectionMessage = !connectionService.hasInternet &&
        (!_isListening &&
            !audioService.hasAudioToPlay() &&
            !audioService.isPlaying());

    _listeningMode = (!audioService.isPlaying() &&
        !_remainingLLMResponse &&
        !audioService.hasAudioToPlay());

    Widget bodyWidget;

    if (_isLoading) {
      bodyWidget = Center(child: LoadingWidget(loadingInfo: _loadingInfo));
    } else if (showLostConnectionMessage) {
      bodyWidget = const Center(
        child: LoadingWidget(
          fontSize: 16,
          loadingInfo:
              "Oops! It looks like Whisper has lost connection to the internet. Don't worry, Whisper will be back to help as soon as you're online!",
        ),
      );
    } else if (_functionToRetry != null) {
      bodyWidget = _buildRetryCancelWidget();
    } else {
      bodyWidget = Stack(
        children: <Widget>[
          ListeningMessage(
            listeningMode: _listeningMode,
            firstMessage: _firstMessage,
            isListening: _isListening,
            transcription: transcription,
            audioLevel: _audioLevel,
            textColor: textColor,
          ),
          if (_isListening)
            Positioned(
              top: 50,
              left: width * 0.1,
              right: width * 0.1,
              child: Center(
                child: FadeTransition(
                  opacity: animationControllerService.listeningAnimation,
                  child: ListeningAnimation(
                    key: _animationSoundInputKey,
                    width: width,
                  ),
                ),
              ),
            ),
          if (!_isListening)
            SubtitleWidget(
              width: width,
              subtitleSize: subtitleSize,
              subtitles: audioService.getSubtitles(),
              textColor: textColor,
            ),
          if (audioService.isPlaying()) ...[
            Positioned(
              top: 200,
              left: width * 0.1,
              right: width * 0.1,
              child: Center(
                child: PlayingAnimation(
                  key: _animationSoundOutputKey,
                  width: width,
                ),
              ),
            ),
          ],
          Center(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_listeningMode && _firstMessage)
                        ImageOfActivity(
                            imagePath: userService.currentActivity.imagePath),
                      if (!_isListening && _waitingLLMResponse)
                        const SimpleLoadingCircle(),
                      if (_listeningMode && _firstMessage) _buildPlayIcon(),
                    ],
                  ),
                ),
                if (_listeningMode && !_firstMessage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildBottomIconsWhenListening(),
                  ),
                if (audioService.isPlaying() || audioService.hasAudioToPlay())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildBottomIconsWhenPlaying(),
                  ),
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBarWidget(
          currentActivity: userService.currentActivity,
          buildSettingButton: !_isListening,
          buildMainMenuButton: _listeningMode && _firstMessage,
          level: userService.level,
          isar: isar,
          userService: userService,
          onActivityChanged: _updateChain,
          onSettingChanged: _handleSettingsResult),
      body: bodyWidget,
    );
  }
}
