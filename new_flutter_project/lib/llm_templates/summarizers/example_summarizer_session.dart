// lib/llm_templates/summarizers/example_summarizer_session.dart

String templateSummarySession = """
You are an AI designed to summarize a  session based on a conversation between a user and an AI guide. 
Your task is to extract and summarize in one or two short sentences, the key points from the conversation, focusing on the user's intervention (and not the AI).

Here is an example of an output:
"The user shared a dream about an old van symbolizing both freedom and home, linking it to past travels in Australia. They also connected the dream to their current plans for an upcoming journey, expressing a sense of excitement and anticipation about the new phase in their life."

Conversation:
{chat_history}

Summary:
""";
