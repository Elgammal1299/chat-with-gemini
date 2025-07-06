# Chat Feature - Refactored Architecture

## Overview

The chat feature has been refactored to follow a clean architecture pattern with separated concerns. The monolithic `ChatCubit` has been broken down into specialized manager classes that handle specific responsibilities.

## Architecture

### Core Components

#### 1. ChatCubit
- **Purpose**: Main orchestrator that coordinates between different managers
- **Responsibilities**: 
  - State management and UI updates
  - Coordinating operations between managers
  - Emitting BLoC states
- **Dependencies**: All manager classes + ChatAIService

#### 2. ConversationManager
- **Purpose**: Handles all conversation-related operations
- **Responsibilities**:
  - CRUD operations for conversations
  - Loading and caching conversation list
  - Conversation validation and existence checks
- **Dependencies**: HiveService for persistence

#### 3. MessageManager
- **Purpose**: Handles all message-related operations
- **Responsibilities**:
  - CRUD operations for messages
  - Loading messages for specific conversations
  - Message persistence and retrieval
- **Dependencies**: HiveService for persistence

#### 4. ImageManager
- **Purpose**: Handles all image-related operations
- **Responsibilities**:
  - Image picking from camera/gallery
  - Image processing and validation
  - Image state management
- **Dependencies**: NativeServices for platform-specific operations

#### 5. ChatStateManager
- **Purpose**: Manages chat state and conversation state
- **Responsibilities**:
  - Current conversation tracking
  - Message state management
  - State validation and transitions
- **Dependencies**: None (pure state management)

#### 6. ChatAIService
- **Purpose**: Handles AI chat operations
- **Responsibilities**:
  - Communication with AI service
  - Message sending and response handling
  - Chat session management
- **Dependencies**: ChatRepo

## Benefits of Refactoring

### 1. Single Responsibility Principle
Each manager class has a single, well-defined responsibility:
- `ConversationManager` → Conversation operations
- `MessageManager` → Message operations
- `ImageManager` → Image operations
- `ChatStateManager` → State management
- `ChatAIService` → AI communication

### 2. Improved Testability
- Each manager can be tested independently
- Mock dependencies easily
- Isolated unit tests for each concern

### 3. Better Maintainability
- Clear separation of concerns
- Easier to locate and fix issues
- Reduced coupling between components

### 4. Enhanced Reusability
- Managers can be reused in other parts of the app
- Easy to extend functionality
- Modular design

### 5. Cleaner Code
- Reduced complexity in ChatCubit
- Better organized and readable code
- Easier to understand and modify

## Usage Examples

### Loading Conversations
```dart
// ChatCubit orchestrates the operation
await loadConversations();
// Internally calls: _conversationManager.loadConversations()
```

### Sending a Message
```dart
// ChatCubit coordinates between managers
await sendMessage("Hello");
// 1. _stateManager checks/creates conversation
// 2. _chatRepo sends message to AI
// 3. _stateManager adds messages
// 4. _messageManager persists messages
// 5. _imageManager clears image
```

### Picking an Image
```dart
// ImageManager handles the operation
await pickImageFromCamera();
// Returns File? and updates internal state
```

## State Management

The refactored architecture maintains the same state management pattern:
- `ChatInitial` - Initial state
- `ChatLoading` - Loading state
- `ChatSuccess` - Success with messages
- `ChatError` - Error state
- `SendingMessage` - Message sending state
- `MessageSent` - Message sent successfully
- `ImagePicker` - Image selected
- `ImageRemoved` - Image removed
- `ConversationsLoaded` - Conversations loaded

## Backward Compatibility

The refactored `ChatCubit` maintains backward compatibility through getter methods:
- `chatMessages` → `_stateManager.chatMessages`
- `conversations` → `_conversationManager.conversations`
- `selectedImage` → `_imageManager.selectedImage`
- `currentConversationId` → `_stateManager.currentConversationId`

## Debugging

Each manager provides debug methods:
```dart
// Debug all managers
debugHiveStatus();

// Debug specific managers
_conversationManager.debugStatus();
_messageManager.debugStatus();
_imageManager.debugStatus();
_stateManager.debugStatus();
```

## Future Enhancements

The refactored architecture makes it easy to add new features:

1. **Message Encryption**: Add to `MessageManager`
2. **Image Compression**: Add to `ImageManager`
3. **Conversation Backup**: Add to `ConversationManager`
4. **Offline Support**: Add to `ChatAIService`
5. **Message Search**: Add to `MessageManager`

## File Structure

```
lib/feature/chat/
├── data/
│   ├── manager/
│   │   ├── conversation_manager.dart
│   │   ├── message_manager.dart
│   │   ├── image_manager.dart
│   │   └── chat_state_manager.dart
│   ├── service/
│   │   └── chat_ai_service.dart
│   ├── model/
│   │   ├── conversation_model.dart
│   │   └── message_model.dart
│   └── repo/
│       └── chat_repo.dart
└── ui/
    └── view_model/
        └── chat_cubit/
            ├── chat_cubit.dart
            └── chat_state.dart
``` 