import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/models/activity.dart';
import 'package:flutter_voice_friend/services/llm_service.dart';
import 'package:flutter_voice_friend/utils/llm_chain.dart';
import 'package:flutter_voice_friend/services/user_service.dart';
import 'package:flutter_voice_friend/services/audio_service.dart';
import 'package:flutter_voice_friend/services/session_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:langchain/langchain.dart';

import 'llm_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<RunnableSequence>(),
  MockSpec<LLMChainLibrary>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<UserService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AudioService>(),
  MockSpec<SessionService>()
])
void main() {
  group('LLMService Tests', () {
    late LLMService llmService;
    late MockLLMChainLibrary mockLLMChain;
    late MockUserService mockUserService;
    late MockAudioService mockAudioService;
    late MockSessionService mockSessionService;
    late MockRunnableSequence<Object, String> mockRunnableSequence;
    late StreamController<String> llmStreamController;
    late StreamController<Exception> audioErrorStreamController;

    final activity = Activity(
      activityId: ActivityId.introduction,
      name: 'Introduction',
      description: 'Introduction activity',
      requiredLevel: 0,
      displayOrder: 0,
      category: ActivityCategory.dreamActivities,
      duration: 5,
      imagePath: 'assets/activities/default_image.webp',
    );

    setUp(() {
      mockLLMChain = MockLLMChainLibrary();
      mockUserService = MockUserService();
      mockAudioService = MockAudioService();
      mockSessionService = MockSessionService();
      mockRunnableSequence = MockRunnableSequence<Object, String>();
      llmStreamController = StreamController<String>();
      audioErrorStreamController = StreamController<Exception>();

      // Stub the errorStream getter
      when(mockAudioService.errorStream)
          .thenAnswer((_) => audioErrorStreamController.stream);

      when(mockUserService.currentActivity).thenReturn(activity);

      llmService = LLMService();
      llmService.initialize(
        mockLLMChain,
        mockUserService,
        mockSessionService,
        mockAudioService,
      );
    });

    tearDown(() {
      llmStreamController.close();
      audioErrorStreamController.close();
    });

    test('Should handle runChain execution', () async {
      // Set up mocks and expectations
      when(mockLLMChain.getChain()).thenReturn(mockRunnableSequence);
      when(mockRunnableSequence.stream(any))
          .thenAnswer((_) => llmStreamController.stream);

      llmService.onRunChainListen = () {
        // Add assertions if needed
      };

      llmService.onRunChainDone = (containsEndTag) {
        expect(containsEndTag, isFalse);
      };

      // Start the runChain
      await llmService.runChain('Hello', '');
      // Start the runChain

      // Simulate the LLM chain emitting data
      llmStreamController.add('This is a test response.');
      llmStreamController.close();

      // Wait for the stream to complete
      //await llmStreamController.done;

      // Verify that methods are called
      //verify(mockLLMChain.getChain()).called(1);
      //verify(mockRunnableSequence.stream(any)).called(1);
    });

    // Add tests for error handling, updating memory, and other scenarios
  });
}
