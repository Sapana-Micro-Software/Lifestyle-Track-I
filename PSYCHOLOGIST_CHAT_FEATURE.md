# Psychologist Chatbot Feature

## Overview

A comprehensive AI psychologist chatbot feature using Natural Language framework and Vision framework for personalized mental health support.

## Features Implemented

### 1. Natural Language Framework Integration ✅
- **Sentiment Analysis**: Real-time sentiment analysis of user messages
- **Named Entity Recognition**: Extracts people, places, events, triggers, emotions
- **Intent Classification**: Identifies user intent (question, statement, crisis, etc.)
- **Language Detection**: Supports English language recognition
- **Emotion Detection**: Identifies 11 different emotions (joy, sadness, anger, fear, anxiety, stress, hope, gratitude, etc.)

### 2. Vision Framework Integration ✅
- **Facial Expression Analysis**: Analyzes facial expressions from images
- **Emotional State Detection**: Determines positive, negative, neutral, or mixed emotional states
- **Real-time Camera Support**: Can analyze images from camera in real-time
- **Photo Library Integration**: Users can share photos from their library

### 3. Multiple Therapy Approaches ✅
- **CBT (Cognitive Behavioral Therapy)**: Focuses on thought patterns
- **Person-Centered Therapy**: Emphasizes empathy and unconditional positive regard
- **Solution-Focused Therapy**: Focuses on solutions rather than problems
- **Mindfulness-Based Therapy**: Emphasizes present-moment awareness
- **DBT (Dialectical Behavior Therapy)**: Combines CBT with mindfulness
- **Gestalt Therapy**: Focuses on present experience
- **Psychodynamic Therapy**: Explores unconscious patterns
- **Existential Therapy**: Explores meaning and purpose
- **Narrative Therapy**: Helps reframe personal stories
- **Acceptance and Commitment Therapy**: Focuses on acceptance and values

### 4. Personalization Engine ✅
- **Health Data Integration**: Uses EmotionalHealth, MentalHealth, and Journal data
- **Conversation History**: Remembers past conversations and patterns
- **Trigger Tracking**: Tracks emotional triggers and their frequency
- **Coping Strategy Effectiveness**: Monitors which strategies work best
- **Emotional Pattern Recognition**: Identifies recurring emotional patterns
- **Contextual Insights**: Provides insights based on multiple data sources

### 5. Crisis Detection and Escalation ✅
- **Automatic Crisis Detection**: Detects crisis keywords and high-risk sentiment
- **Risk Level Assessment**: Categorizes risk as Low, Moderate, High, or Critical
- **Immediate Alerts**: Shows crisis alert banner and notification
- **Emergency Services Integration**: Quick access to crisis hotlines and emergency services
- **Safety Protocols**: Provides immediate support resources

### 6. Human-like Conversation ✅
- **Natural Responses**: Generates empathetic, human-like responses
- **Contextual Questions**: Asks relevant follow-up questions
- **Adaptive Communication**: Adjusts communication style based on user's emotional state
- **Therapy Technique Indicators**: Shows which therapy approach is being used
- **Sentiment Indicators**: Visual feedback on emotional state

### 7. Progress Tracking ✅
- **Session Summaries**: Automatic generation of session summaries
- **Progress Metrics**: Tracks sentiment trends, engagement, session frequency
- **Goal Tracking**: Monitors therapy goals and milestones
- **Emotional Pattern Analysis**: Identifies improvement areas and strengths
- **Historical Analysis**: Compares current state with past sessions

### 8. Daily Check-ins ✅
- **Automatic Reminders**: Prompts for check-ins if inactive for 2+ days
- **Personalized Greetings**: Varied, natural greeting messages
- **Engagement Tracking**: Monitors user engagement over time

### 9. Privacy and Security ✅
- **Local Storage**: Conversations stored locally using UserDefaults
- **Encrypted Data**: All sensitive data is encrypted
- **No Cloud Sync**: All processing happens on-device
- **HIPAA Considerations**: Designed with privacy in mind

### 10. Cross-Platform Support ✅
- **iOS**: Full support with PhotosUI and camera
- **macOS**: Full support with file picker
- **iPadOS**: Optimized for larger screens
- **All Apple Platforms**: Works across the entire Apple ecosystem

## User Interface

### Access Points
1. **Quick Actions**: "Chat" button in Home Dashboard
2. **Tools Tab**: "Psychologist Chat" tool card
3. **Emotional Health Section**: Direct access from emotional health views

### Chat Interface Features
- **Message Bubbles**: Distinct styling for user vs. psychologist messages
- **Sentiment Indicators**: Visual emoji indicators for emotional state
- **Therapy Technique Labels**: Shows which approach is being used
- **Image Analysis Results**: Displays emotional state from image analysis
- **Progress Button**: Quick access to progress tracking
- **Crisis Alert Banner**: Prominent alert when crisis detected

### Progress View Features
- **Progress Metrics**: Average sentiment, session frequency, engagement score
- **Trend Indicators**: Visual indicators for improving/declining/stable trends
- **Goals Display**: Visual progress bars for therapy goals
- **Emotional Patterns**: List of identified patterns
- **Session History**: Summary of past sessions

## Technical Implementation

### Models
- `ChatMessage`: Individual messages with sentiment, entities, intent, image analysis
- `ConversationSession`: Complete conversation sessions with summaries
- `PsychologistUserProfile`: User profile with history, patterns, goals, progress
- `SentimentAnalysis`: Comprehensive sentiment and emotion analysis
- `ImageEmotionalAnalysis`: Vision framework analysis results

### Managers
- `PsychologistChatbotManager`: Main chatbot manager with NLP and Vision integration
- `PsychologistProgressTracker`: Progress analysis and tracking

### Views
- `PsychologistChatView`: Main chat interface
- `PsychologistProgressView`: Progress tracking and analytics
- `MessageBubble`: Individual message display component

## Integration Points

1. **Health Data**: Integrates with `EmotionalHealth`, `MentalHealth`, `Journal` models
2. **Journal Entries**: Automatically saves conversations to journal
3. **Emotional Health**: Updates emotional health data based on conversations
4. **Progress Tracking**: Links to overall health progress

## Usage

### Starting a Session
```swift
// Automatically starts when view appears
chatbotManager.startNewSession()
```

### Sending a Message
```swift
await chatbotManager.processUserMessage("I'm feeling anxious today", image: selectedImage)
```

### Ending a Session
```swift
chatbotManager.endCurrentSession()
```

### Accessing Progress
```swift
let metrics = progressTracker.analyzeProgress(profile: chatbotManager.userProfile)
```

## Response Generation

The chatbot uses sophisticated response generation that:
- Adapts therapy approach based on user's emotional state
- Provides personalized insights from health data
- Asks contextual follow-up questions
- Detects and responds to crisis situations
- Maintains conversation context across messages

## Example Conversations

### CBT Approach
**User**: "I'm always worried about work"
**Chatbot**: "I hear you. It sounds like you're experiencing some difficult thoughts or feelings. Can you help me understand what thoughts are going through your mind right now? Sometimes our thoughts can influence how we feel, and exploring them together might be helpful."

### Person-Centered Approach
**User**: "I feel like no one understands me"
**Chatbot**: "Thank you for trusting me with that. It sounds like this is really important to you, and I want you to know that your feelings are valid. Can you tell me more about what this experience has been like for you?"

### Crisis Response
**User**: "I want to end it all"
**Chatbot**: "I'm very concerned about what you've shared. Your safety is the most important thing right now. Please reach out to a crisis helpline immediately: National Suicide Prevention Lifeline: 988 (US) or your local emergency services. You don't have to go through this alone - there are people who want to help you right now."

## Future Enhancements

See `PSYCHOLOGIST_CHAT_ENHANCEMENTS.md` for comprehensive list of recommended features.

### High-Priority Additions:
1. **Voice Input/Output**: Speech-to-text and text-to-speech for natural conversations
2. **Guided Meditation & Breathing**: Immediate stress relief tools integrated with existing meditation exercises
3. **Mood Journaling Prompts**: Structured reflection prompts saved to Journal
4. **Sleep-Emotion Correlation**: Analyze sleep patterns with emotional state using existing SleepAnalysis
5. **Exercise Recommendations**: Suggest exercises based on mood using existing Exercise models
6. **Therapy Homework**: Assign CBT thought records, mindfulness practices, behavioral experiments
7. **Resource Library**: Articles, videos, worksheets on mental health topics
8. **Session Export**: PDF export for sharing with real therapists
9. **Check-in Reminders**: Daily/weekly reminders using NotificationManager
10. **Biometric Integration**: Heart rate, stress levels from Apple Watch via HealthKitManager

### Medium-Priority:
- Music therapy suggestions
- Gratitude exercises
- Cognitive exercises
- Relapse prevention tracking
- Emergency contacts management
- Coping strategy library
- Therapy session scheduling
- Mood tracking visualization
- Medication tracking integration
- Social connection tracking

### Lower-Priority:
- Multi-language support
- Accessibility features
- Offline mode
- Group therapy support
- Therapist handoff
- Family/friend sharing
- Advanced analytics
- Crisis resources integration

## Privacy and Ethics

- All data processed on-device
- No data sent to external servers
- User controls all data
- Transparent about AI nature
- Clear crisis escalation protocols
- Regular privacy audits recommended

## Testing

The feature has been tested for:
- ✅ Natural language processing accuracy
- ✅ Vision framework image analysis
- ✅ Crisis detection reliability
- ✅ Response quality and appropriateness
- ✅ Cross-platform compatibility
- ✅ Performance and responsiveness

## Support

For questions or issues:
- Check conversation history in Progress view
- Review session summaries
- Access crisis resources immediately if needed
- Contact support for technical issues
