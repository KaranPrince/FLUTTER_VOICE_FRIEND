import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_voice_friend/config.dart';
import 'package:flutter_voice_friend/llm_templates/summarizers/example_summarizer_user_template.dart';
import 'package:flutter_voice_friend/llm_templates/summarizers/example_summarizer_session.dart';

class LLMChainLibrary {
  late ConversationBufferWindowMemory memory;
  late PromptTemplate promptTemplate;
  late PromptTemplate memoryUserSummaryTemplate;
  late PromptTemplate memorySessionSummaryTemplate;
  late PromptTemplate memoryAllSessionSummaryTemplate;
  late ChatOpenAI llm;
  late ConversationChain llmChain;
  String template;

  LLMChainLibrary(this.template) {
    _initializeComponents(template);
  }

  void _initializeComponents(String template) {
    memory = ConversationBufferWindowMemory(
      k: 15,
      memoryKey: "chat_history",
      aiPrefix: "AI",
      returnMessages: true,
    );
    promptTemplate = PromptTemplate.fromTemplate(template);
    memoryUserSummaryTemplate =
        PromptTemplate.fromTemplate(templateSummaryUser);
    memorySessionSummaryTemplate =
        PromptTemplate.fromTemplate(templateSummarySession);
    llm = ChatOpenAI(
      apiKey: Config.openaiApiKey,
      defaultOptions: const ChatOpenAIOptions(model: 'gpt-4o-mini'),
    );
    llmChain = ConversationChain(
      llm: llm,
      memory: memory,
      prompt: promptTemplate,
    );
  }

  void setTemplate(String newTemplate) {
    template = newTemplate;
    _initializeComponents(newTemplate);
  }

  RunnableSequence<Object, String> getChain() {
    final chain = Runnable.fromMap({
      'language': Runnable.passthrough(),
      'input': Runnable.passthrough(),
      'user_information': Runnable.passthrough(),
      'session_history': Runnable.passthrough(),
      'chat_history': Runnable.mapInput(
        (_) async {
          final m = await memory.loadMemoryVariables();
          return m['chat_history'];
        },
      ),
    }).pipe(promptTemplate).pipe(llm).pipe(const StringOutputParser());

    return chain;
  }

  RunnableSequence<Object, String> getSummarizeUserChain() {
    debugPrint("Getting Summarize User Chain");

    final chain = Runnable.fromMap({
      'chat_history': Runnable.mapInput(
        (_) async {
          final m = await memory.loadMemoryVariables();
          return m['chat_history'];
        },
      ),
    })
        .pipe(memoryUserSummaryTemplate)
        .pipe(llm)
        .pipe(const StringOutputParser());

    return chain;
  }

  RunnableSequence<Object, String> getSummarizeSessionChain() {
    debugPrint("Getting Summarize Session Chain");

    final chain = Runnable.fromMap({
      'chat_history': Runnable.mapInput(
        (_) async {
          final m = await memory.loadMemoryVariables();
          return m['chat_history'];
        },
      ),
    })
        .pipe(memorySessionSummaryTemplate)
        .pipe(llm)
        .pipe(const StringOutputParser());
    return chain;
  }

  RunnableSequence<Object, String> getSummarizeAllSessionsChain() {
    debugPrint("Getting Summarize All Session Chain");

    final chain = Runnable.fromMap({
      'memory': Runnable.passthrough(),
      'conversations': Runnable.passthrough(),
    })
        .pipe(memoryAllSessionSummaryTemplate)
        .pipe(llm)
        .pipe(const StringOutputParser());

    return chain;
  }

  void updateMemory(input, output) {
    debugPrint("Updating chat Memory");
    memory.saveContext(
      inputValues: {'input': input},
      outputValues: {'output': output},
    );
  }

  void clearMemory() {
    debugPrint("Clearing chat Memory");
    memory.chatHistory.clear();
    memory.clear();
  }
}
