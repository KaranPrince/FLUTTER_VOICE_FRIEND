# FlutterVoiceFriend

**FlutterVoiceFriend** is an open-source Flutter application designed to help developers build interactive, voice-driven chatbot experiences using a combination of cutting-edge speech-to-text (STT) and text-to-speech (TTS) technologies. The app leverages Langchain, OpenAI for natural language processing and TTS, as well as both on-device and cloud-based speech recognition (including Deepgram) to offer flexible voice interaction capabilities.

Whether you’re developing a virtual assistant, a conversational AI tool, or an educational voice companion, FlutterVoiceFriend provides a solid foundation for building customizable, voice-based applications.

## Key Features:

1. **Voice-to-Voice Chatbot:**
   - FlutterVoiceFriend allows for seamless voice-driven conversations using advanced STT and TTS technology. Users can speak to the app, and it will respond through natural voice output.

2. **Multiple Speech Recognition Options:**
   - Support for both on-device and cloud-based STT technologies ensures that the app can handle voice inputs in diverse environments with varying device capabilities.

3. **Flexible and Modular:**
   - The app can be easily customized to fit a variety of use cases, such as virtual assistants, conversational bots, educational apps, or entertainment platforms.
   - Developers can modify chatbot flows, responses, and behaviors to tailor the experience to their specific needs.

4. **Built with Flutter:**
   - Developed using the Flutter SDK, ensuring compatibility across iOS, Android, and Web platform. The app provides a smooth user experience with a single codebase.

5. **Natural Language Processing with Langchain & OpenAI:**
   - Integrates OpenAI’s powerful models for generating natural, coherent conversations.
   - Use Langchain for complex conversational flows, enabling the bot to handle more nuanced dialogues.

6. **Customizable Voice Responses:**
   - Tweak the TTS engine to match the personality of your chatbot. Choose from multiple voices and languages to create a personalized user experience.

7. **Speech-to-Text Flexibility:**
   - Includes on-device STT options for faster, offline processing and cloud-based STT (e.g., Deepgram) for more accurate speech recognition in online environments.

## Use Cases:

- **Virtual Assistants**: Create smart voice-activated virtual assistants to help with tasks, reminders, or general information.
- **Educational Apps**: Build conversational companions that guide users through learning experiences with voice feedback.
- **Entertainment and Games**: Develop interactive story-driven apps where users communicate with characters using voice input.
- **Healthcare and Wellness**: Create voice companions for health tracking, emotional support, or fitness guidance.

## Example of App develop using this framework

"FlutterVoiceFriend" was initially developed for an interactive and engaging app designed to help children explore their emotions and cultivate mindfulness through guided meditation and self-reflection exercises. The Friend in Me guides kids through various activities that are both meditative and reflective in nature. The goal is to teach children self-compassion, mindfulness, and emotional awareness through fun, simple, and engaging exercises.

- **iOS (iPhone or iPad):**  
  Download the app from the [App Store](https://apps.apple.com/us/app/the-friend-in-me/id6605936938).

## Technological Stack:

- **Flutter SDK**: Cross-platform development for iOS, Android and Web.
- **Speech Recognition**: Integrates on-device and cloud-based STT (e.g., `speech_to_text` and `deepgram_speech_to_text`).
- **Audio Backend**: Can use either SoLoud library and just_audio plugging.
- **Text-to-Speech**: Powered by OpenAI for natural voice output.
- **Large Language Model Processing**: Utilizes Langchain and OpenAI model to handle complex conversational flows.

## Limitations

As of the current version, there are several features and enhancements that are planned but not yet implemented. Please take note of the following limitations:

### Platform Compatibility
- **iOS and Android Only:** The app is currently only compatible with iOS and Android devices. Support for web is available in a branch but requires special configuration Linux, Windows, and Mac platforms are not yet implemented.

### Community Engagement
- **User Feedback:** There is no built-in mechanism for gathering user feedback within the app.

### Documentation
- **Developer Documentation:** Comprehensive documentation for developers is not yet available.
- **Code Comments:** Key parts of the codebase still need adequate comments.

### Features
- **Background Sounds:** Background music or nature sounds during meditation activities are not yet implemented.
- **User Authentication:** User sign-in functionality is not available.
- **Offline Mode:** The app does not currently support offline functionality.
- **User Data Analytics:** Anonymous usage analytics are not implemented.

### Modularity and Code Structure
- **Separation of Concerns:** The app’s business logic is not fully separated from UI components.

### Performance
- **Error Logging:** Robust error logging and monitoring tools are not yet in place.

### Testing
- **Unit and Integration Tests:** Comprehensive unit tests and integration tests are not yet implemented.
- **CI/CD:** Continuous integration and deployment pipelines are not set up.

## Getting Started

### Prerequisites

- Flutter SDK >= 3.4.4
- Dart >= 3.4.4

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jbpassot/flutter_voice_friend.git
   cd flutter_voice_friend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code with build_runner (required for Isar):**
   ```bash
   dart run build_runner build
   ```

4. **Add API Keys:**
   - Rename `.env.example` to `.env`.
   - Add your OpenAI and Deepgram API keys to the `.env` file.

5. **Run the app:**
   ```bash
   flutter run
   ```

### Configuration

The app uses various external services like OpenAI for text generation and Deepgram for speech-to-text. Make sure to configure these in the `.env` file.

```env
OPENAI_API_KEY=your_openai_api_key
DEEPGRAM_API_KEY=your_deepgram_api_key
```

## Contribution

We welcome contributions! Please check the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to contribute.

## License

This project is licensed under the **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License**. See the [LICENSE](LICENSE) file for details.

## Contact

If you have any questions or feedback, feel free to open an issue or contact us at [jbpassot+fluttervoice@gmail.com].

