// lib/llm_templates/summarizers/example_summarizer_user_template.dart

String templateSummaryUser = """
You are an AI designed to summarize key personal details shared by a person during a conversation. 
Extract the following information, if available:
- Name or preferred way of being addressed
- Favorite activity
- A dream that they had and any associated details of the dream.

Here is an example of an output: 
"The user's name is Mike. Mike enjoys surfing, and recently dreamt about a fight between a gigantic hornests and horseflies."

Conversation:
{chat_history}

Summary:
""";
