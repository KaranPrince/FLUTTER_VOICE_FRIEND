// test/llm_chain_test.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_voice_friend/utils/llm_chain.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_voice_friend/llm_templates/summarizers/example_summarizer_user_template.dart';
import 'package:flutter_voice_friend/llm_templates/summarizers/example_summarizer_session.dart';
import 'package:flutter_voice_friend/llm_templates/activities/example_introduction_template.dart';

// Import the generated mocks
import 'llm_chain_test.mocks.dart';

// GenerateMocks annotation for Mockito
@GenerateMocks([ConversationChain, ChatOpenAI])
void main() {
  dotenv.load();
  // Initialize mock objects
  late ConversationBufferWindowMemory memory;
  late MockChatOpenAI mockLLM;
  late MockConversationChain mockChain;
  late PromptTemplate mockPromptTemplate;
  late PromptTemplate mockUserSummaryTemplate;
  late PromptTemplate mockSessionSummaryTemplate;

  setUp(() {
    memory = ConversationBufferWindowMemory(
      k: 15,
      memoryKey: "chat_history",
      aiPrefix: "AI",
      returnMessages: true,
    );

    Config.openaiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    mockLLM = MockChatOpenAI();
    mockChain = MockConversationChain();

    mockPromptTemplate = PromptTemplate.fromTemplate(templateIntroduction);
    mockUserSummaryTemplate = PromptTemplate.fromTemplate(templateSummaryUser);
    mockSessionSummaryTemplate =
        PromptTemplate.fromTemplate(templateSummarySession);
  });

  group('LLMChainLibrary Unit Tests', () {
    const initialTemplate = "Hello, {input}";
    const newTemplate = "Hi, {input}";

    test('Constructor initializes components correctly', () {
      // Arrange & Act
      final library = LLMChainLibrary(initialTemplate);

      // Assert
      expect(library.template, equals(initialTemplate));
      expect(library.memory, isA<ConversationBufferWindowMemory>());
      expect(library.promptTemplate, isA<PromptTemplate>());
      expect(library.llm, isA<ChatOpenAI>());
      expect(library.llmChain, isA<ConversationChain>());
    });

    test('Constructor initializes with injected dependencies', () {
      // Arrange & Act
      final library = LLMChainLibrary(
        initialTemplate,
        memory: memory,
        llm: mockLLM,
        llmChain: mockChain,
        promptTemplate: mockPromptTemplate,
        memoryUserSummaryTemplate: mockUserSummaryTemplate,
        memorySessionSummaryTemplate: mockSessionSummaryTemplate,
      );

      // Assert
      expect(library.template, equals(initialTemplate));
      expect(library.memory, equals(memory));
      expect(library.llm, equals(mockLLM));
      expect(library.llmChain, equals(mockChain));
      expect(library.promptTemplate, equals(mockPromptTemplate));
      expect(
          library.memoryUserSummaryTemplate, equals(mockUserSummaryTemplate));
      expect(library.memorySessionSummaryTemplate,
          equals(mockSessionSummaryTemplate));
    });

    test('setTemplate updates the template and re-initializes components', () {
      // Arrange
      final library = LLMChainLibrary(initialTemplate);

      // Act
      library.setTemplate(newTemplate);

      // Assert
      expect(library.template, equals(newTemplate));
      expect(library.promptTemplate.template, equals(newTemplate));
      // Assuming promptTemplate has a 'template' property
    });

    test('updateMemory saves context correctly', () async {
      // Arrange
      final library = LLMChainLibrary(initialTemplate);
      const input = "User input";
      const output = "AI response";

      // Act
      library.updateMemory(input, output);

      await Future.delayed(Duration(milliseconds: 200));
      Map<String, dynamic> res = await library.memory.loadMemoryVariables();

      expect(res["chat_history"][0].contentAsString, equals("User input"));
      expect(res["chat_history"][1].contentAsString, equals("AI response"));
    });

    test('clearMemory clears the memory correctly', () async {
      // Arrange
      final library = LLMChainLibrary(initialTemplate);
      const input = "User input";
      const output = "AI response";

      library.updateMemory(input, output);
      await Future.delayed(const Duration(milliseconds: 100));
      library.clearMemory();
      await Future.delayed(const Duration(milliseconds: 100));
      Map<String, dynamic> res = await library.memory.loadMemoryVariables();

      // Assert
      expect(res["chat_history"].length, equals(0));
    });
  });

  group('LLMChainLibrary Edge Case Tests', () {
    const template = "Process the following: {input}";

    test('Constructor handles empty template gracefully', () {
      // Arrange & Act
      final library = LLMChainLibrary('');

      // Assert
      expect(library.template, equals(''));
      expect(library.promptTemplate.template, equals(''));
    });

    test('setTemplate with same template does not cause issues', () {
      // Arrange
      final library = LLMChainLibrary(template);

      // Act
      library.setTemplate(template);

      // Assert
      expect(library.template, equals(template));
      expect(library.promptTemplate.template, equals(template));
      // Further assertions can be added to ensure no re-initialization errors
    });

    test('updateMemory handles empty input and output gracefully', () async {
      // Arrange
      final library = LLMChainLibrary(template);

      // Act
      library.updateMemory('', '');

      // Assert
      await Future.delayed(Duration(milliseconds: 200));
      Map<String, dynamic> res = await library.memory.loadMemoryVariables();

      expect(res["chat_history"][0].contentAsString, equals(""));
      expect(res["chat_history"][1].contentAsString, equals(""));
    });
  });
}
