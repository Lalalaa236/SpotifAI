---

# 🎵 SpotifAI

**SpotifAI** is a smart music platform that integrates music streaming with a powerful chatbot experience. The app is built with a modern **Flutter** frontend and a **Django** backend, designed to provide users with personalized, interactive, and conversational music recommendations.

---

## 🚀 Features

* 🎧 **Stream Songs & Explore Albums**
* 🤖 **AI Chatbot Integration (Gemini)**
* 🔍 **Smart Search for Artists, Albums, and Songs**
* 🔐 **Google OAuth Login**
* 📱 **Cross-Platform Flutter Frontend**
* 🌐 **Django RESTful API with PostgreSQL Database**

---

## 📁 Project Structure

```
SpotifAI/
├── backend/           # Django backend: API, chatbot, authentication
│   ├── manage.py
│   ├── .env           # environment config
│   ├── requirements.txt
│   └── ...
├── frontend/          # Flutter frontend: UI & interaction layer
│   ├── lib/
│   ├── pubspec.yaml
│   └── ...
└── README.md
```

---

## 🛠️ Getting Started

### Prerequisites

* Python 3.10+
* Flutter SDK 3.x
* PostgreSQL
* Dart SDK
* Android Studio

---

## ⚙️ Backend Setup (Django)

1. Navigate to the backend:

   ```bash
   cd backend
   ```

2. Create a virtual environment:

   ```bash
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   ```

3. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

4. Create a `.env` file and add your environment variables:

   > 📄 Example `.env` file:

   ```env
   SECRET_KEY=your_django_secret_key
   DEBUG=True
   DATABASE_ENGINE=django.db.backends.postgresql
   DATABASE_NAME=SpotifAI
   DATABASE_USER=your_db_user
   DATABASE_PASSWORD=your_db_password
   DATABASE_HOST=your_db_host
   DATABASE_PORT=1234 #example

   # Google Login
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret

   # Gemini API Key
   GEMINI_API_KEY=your_gemini_api_key
   ```

5. Run database migrations:

   ```bash
   python manage.py migrate
   ```

6. Start the development server:

   ```bash
   python manage.py runserver
   ```

---

## 📱 Frontend Setup (Flutter)

1. Navigate to the frontend:

   ```bash
   cd frontend
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

Make sure you have a device or emulator running.

---

## 🤖 Chatbot Integration (Gemini)

SpotifAI uses **Google's Gemini API** to power its chatbot, which can:

* Recommend songs, albums, and artists
* Answer general music-related questions
* Assist users in navigating the app

Ensure that your `.env` contains the `GEMINI_API_KEY` and that the Django chatbot logic correctly handles API calls to Gemini.

---

## 🔐 Google OAuth Setup

Google login is integrated using OAuth2. You'll need to:

* Register your app in the [Google Developer Console](https://console.developers.google.com/)
* Enable OAuth 2.0 APIs
* Set up your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `.env`

Make sure redirect URIs are configured correctly for both web and mobile platforms.

---

