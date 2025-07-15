# 🖌️ AI Voice-Enabled Collaborative Drawing App (Flutter)

This Flutter app is an interactive, real-time drawing canvas that allows users to draw shapes, collaborate via WebSockets, and use **voice commands** to control drawing tools or automatically render shapes like circles and rectangles. It combines Flutter drawing mechanics, Google Speech-to-Text, and Text-to-Speech (TTS) for a voice-assisted experience.

---

## 🚀 Features

### 🎨 Drawing Tools

* Brush
* Eraser
* Line
* Rectangle
* Circle
* Color picker
* Adjustable stroke thickness

### 🔄 Canvas Management

* Undo / Redo functionality
* Clear canvas (via code or extendable via voice command)
* Real-time sync using WebSocket (client stream support)

### 🎙️ Voice Assistant

* Uses **Google Speech-to-Text API** to recognize spoken commands.
* Uses **Flutter TTS** to speak back the interpreted command.
* Commands Supported:

  * "Draw a circle"
  * "Draw a rectangle"
  * "Use eraser"
  * "Line tool"
  * "Red", "Black", "Yellow" (color change)

### 📦 Animations

* Footer animation using Lottie

---

## 🧑‍💻 Tech Stack

* **Flutter** for UI and gestures
* **Google Speech-to-Text API** (Cloud-based voice recognition)
* **Flutter TTS** for speech output
* **WebSocket** for real-time data broadcasting
* **Lottie** for dynamic visual animations

---

## 🔧 Setup Instructions

### 1. Clone the Repo

```bash
git clone https://github.com/your-username/ai-draw-app.git
cd ai-draw-app
```

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Google Speech-to-Text Setup

* Go to [Google Cloud Console](https://console.cloud.google.com/)
* Create a new project
* Enable **Speech-to-Text API**
* Go to **APIs & Services → Credentials**
* Create an **API Key**
* Replace `YOUR_GOOGLE_API_KEY` in `voice_service.dart`

```dart
Uri.parse('https://speech.googleapis.com/v1/speech:recognize?key=YOUR_GOOGLE_API_KEY')
```

> ✅ First 60 minutes/month are free under Google Cloud Free Tier.

### 4. Permissions

Add the following to your Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 📱 How to Use

1. Run the app
2. Use the **FAB menu** to open drawing tools
3. Tap the 🎤 **Voice Command** and say things like:

   * "Draw a circle"
   * "Draw a rectangle"
   * "Use eraser"
   * "Color red"
4. Watch the canvas respond!

---

## 🤖 Future Enhancements

* Offline voice command using Whisper or Vosk
* Save and share canvas
* Collaborative multi-user sessions
* AI-based doodle correction or suggestions

---

## 📄 License

MIT License. Free to use and modify.


https://github.com/user-attachments/assets/a630acdc-e2a8-495d-a082-63f331698f8d

.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
