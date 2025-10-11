import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime_type/mime_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';

class MessagesController extends GetxController {
  final messageInputTextController = TextEditingController();
  final listScrollController = ScrollController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  static final isLoading = true.obs;
  final isSendingMessage = false.obs;
  final isError = false.obs;

  late Conversation conversation;
  late ConversationClient client;
  late ChatController chatController;

  final messages = <Message>[].obs;
  final participants = <Participant>[].obs;
  final participantCount = 0.obs;
  final currentlyTyping = <String>{}.obs;
  final subscriptions = <StreamSubscription>[];
  final messageMedia = <String, Uint8List>{}.obs;

  MessagesController(this.conversation, this.client, this.chatController);

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
    _bindReactiveMessageSync();
    loadMessages();
  }

  /// Binds MessagesController -> ChatController in real time
  // void _bindReactiveMessageSync() {
  //   ever<List<Message>>(messages, (_) {
  //     final mapped = messages.map((msg) {
  //       return {
  //         'id': msg.messageIndex ?? 0,
  //         'sid': msg.sid ?? '',
  //         'text': msg.type == MessageType.MEDIA ? '' : (msg.body ?? ''),
  //         'time': msg.dateCreated != null
  //             ? msg.dateCreated!.toLocal().toString()
  //             : DateTime.now().toString(),
  //         'author': msg.author ?? 'Admin',
  //         'isMe': msg.author == client.myIdentity,
  //         'isMedia': msg.type == MessageType.MEDIA,
  //         'isLocal': true,
  //       };
  //     }).toList();

  //     chatController.messages.assignAll(mapped);
  //     chatController.buildChatWidgets();
  //   });
  // }

  void _bindReactiveMessageSync() {
    ever<List<Message>>(messages, (_) {
      for (final msg in messages) {
        final sid = msg.sid ?? '';
        final existingIndex = chatController.messages.indexWhere(
          (m) => m['sid'] == sid,
        );

        final newMap = {
          'id': msg.messageIndex ?? 0,
          'sid': sid,
          'text': msg.type == MessageType.MEDIA ? '' : (msg.body ?? ''),
          'time':
              msg.dateCreated?.toLocal().toString() ??
              DateTime.now().toString(),
          'author': msg.author ?? 'Admin',
          'isMe': msg.author == client.myIdentity,
          'isMedia': msg.type == MessageType.MEDIA,
          'isLocal': false,
        };

        if (existingIndex != -1) {
          // Preserve existing local media path
          if (chatController.messages[existingIndex]['isMedia'] == true &&
              chatController.messages[existingIndex]['text'] != '') {
            newMap['text'] =
                chatController.messages[existingIndex]['text'] ?? '';
            newMap['isLocal'] =
                chatController.messages[existingIndex]['isLocal'] ?? true;
          }
          chatController.messages[existingIndex] = newMap;
        } else {
          chatController.messages.add(newMap);
        }
      }

      chatController.messages.refresh();
      chatController.buildChatWidgets();
    });
  }

  /// Initializes Twilio event listeners
  void _initializeListeners() {
    // onMessageAdded
    subscriptions.add(
      conversation.onMessageAdded.listen((message) async {
        if (!messages.any((m) => m.sid == message.sid)) {
          messages.add(message);
          if (message.type == MessageType.MEDIA) {
            _getMedia(message);
          }

          // Mark as read
          final messageIndex = message.messageIndex;
          if (messageIndex != null) {
            conversation.advanceLastReadMessageIndex(messageIndex);
          }
          messages.refresh();
          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
        }
      }),
    );

    // onMessageUpdated
    subscriptions.add(
      conversation.onMessageUpdated.listen((event) async {
        final updated = event.message;
        final idx = messages.indexWhere((m) => m.sid == updated.sid);
        if (idx != -1) {
          messages[idx] = updated;
          messages.refresh();
        }
      }),
    );

    // onMessageDeleted
    subscriptions.add(
      conversation.onMessageDeleted.listen((event) async {
        messages.removeWhere((m) => m.sid == event.sid);
        messages.refresh();
      }),
    );

    // Typing events
    subscriptions.add(
      conversation.onTypingStarted.listen((event) {
        final id = event.participant.identity;
        if (id != null) currentlyTyping.add(id);
      }),
    );

    subscriptions.add(
      conversation.onTypingEnded.listen((event) {
        final id = event.participant.identity;
        if (id != null) currentlyTyping.remove(id);
      }),
    );
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    try {
      final total = await conversation.getMessagesCount() ?? 0;
      if (total == 0) {
        messages.clear();
        return;
      }

      final lastMsgs = await conversation.getLastMessages(total);

      // Only add missing messages (avoid reloading entire list)
      for (final msg in lastMsgs.reversed) {
        if (!messages.any((m) => m.sid == msg.sid)) {
          messages.add(msg);
          if (msg.type == MessageType.MEDIA) {
            await _getMedia(msg);
          }
        }
      }

      await conversation.setAllMessagesRead();
      messages.refresh();
    } catch (e) {
      print('loadMessages error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // void loadMessages() async {
  //   isLoading.value = true;
  //   final total = await conversation.getMessagesCount() ?? 0;
  //   final lastMsgs = await conversation.getLastMessages(total);
  //   messages.assignAll(lastMsgs.reversed);

  //   for (final msg in messages) {
  //     if (msg.type == MessageType.MEDIA) _getMedia(msg);
  //   }

  //   await conversation.setAllMessagesRead();
  //   isLoading.value = false;
  // }

  // void initConversation(Conversation conversation) async {
  //   this.conversation = conversation;

  //   // Ensure messages are synchronized
  //   if (conversation.synchronizationStatus !=
  //       ConversationSynchronizationStatus.ALL) {
  //     int retries = 0;
  //     while (conversation.synchronizationStatus !=
  //             ConversationSynchronizationStatus.ALL &&
  //         retries < 10) {
  //       await Future.delayed(const Duration(milliseconds: 500));
  //       retries++;
  //     }
  //   }
  //   loadMessages();
  // }

  Future<void> initConversation(Conversation newConversation) async {
    // Cancel all previous subscriptions (so old conversation streams stop flowing)
    for (final sub in subscriptions) {
      try {
        await sub.cancel();
      } catch (_) {}
    }
    subscriptions.clear();

    // Clear per-conversation state
    messages.clear();
    currentlyTyping.clear();
    messageMedia.clear();

    // Assign and reinitialize listeners for the new conversation
    conversation = newConversation;
    _initializeListeners();

    // Wait for conversation sync (same logic you already used elsewhere)
    if (conversation.synchronizationStatus !=
        ConversationSynchronizationStatus.ALL) {
      int retries = 0;
      while (conversation.synchronizationStatus !=
              ConversationSynchronizationStatus.ALL &&
          retries < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries++;
      }
    }

    // Now load messages for the new conversation
    loadMessages();
  }

  Future<void> _getMedia(Message message) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      if (files.length > 500) {
        print(
          '_getMedia => cache folder too large (${files.length} files), cleaning up...',
        );
        // Delete oldest files first
        files.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
        );
        final excess = files.length - 400; // keep 400 latest
        for (int i = 0; i < excess; i++) {
          try {
            files[i].deleteSync();
          } catch (e) {
            print('_getMedia => failed to delete cache file: $e');
          }
        }
      }

      final filePath = '${dir.path}/${message.sid}.jpg';
      final file = File(filePath);

      if (messageMedia.containsKey(message.sid)) {
        _updateMediaInChat(message, file.path);
        return;
      }

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        messageMedia[message.sid!] = bytes;
        _updateMediaInChat(message, file.path);
        return;
      }

      final url = await message.getMediaUrl();
      if (url == null) return;

      final token = await storage.read(key: 'twilio_token');
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        messageMedia[message.sid!] = Uint8List.fromList(response.data!);
        _updateMediaInChat(message, file.path);
      }
    } catch (e) {
      print('_getMedia error: $e');
    }
  }

  void _updateMediaInChat(Message message, String path) {
    final idx = chatController.messages.indexWhere(
      (m) => m['id'] == message.messageIndex,
    );
    if (idx != -1) {
      chatController.messages[idx]['text'] = path;
      chatController.messages[idx]['isLocal'] = true;
      chatController.messages.refresh();
    }
  }

  Future<void> onSendMessagePressed() async {
    final text = messageInputTextController.text.trim();
    if (text.isEmpty) return;

    isSendingMessage.value = true;
    try {
      final messageOptions = MessageOptions()..withBody(text);
      await conversation.sendMessage(messageOptions);
      messageInputTextController.clear();
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> onSendMediaMessagePressed() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final mType = mime(file.path) ?? "image/jpeg";
    final compressed = await BaseController.compressImage(file, 10);

    try {
      final messageOptions = MessageOptions()..withMedia(compressed, mType);
      await conversation.sendMessage(messageOptions);
    } catch (e) {
      print('Error sending media: $e');
    }
  }

  Future<void> deleteMessageBySid(String messageSid) async {
    try {
      // Find the message in the messages list by its SID
      final Message? msg = messages.firstWhereOrNull(
        (m) => m.sid == messageSid,
      );
      if (msg != null) {
        await conversation.removeMessage(msg); // Twilio API call
        messages.remove(msg); // Update local list immediately
        messages.refresh();
      }
    } catch (e) {
      print('Error deleting message: $e');
      isError.value = true;
      // Optionally show a UI error
    }
  }

  void scrollToBottom({bool animated = true}) {
    if (!listScrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pos = listScrollController.position.minScrollExtent;
      if (animated) {
        listScrollController.animateTo(
          pos,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        listScrollController.jumpTo(pos);
      }
    });
  }

  @override
  void onClose() {
    messageInputTextController.dispose();
    for (final sub in subscriptions) {
      sub.cancel();
    }
    subscriptions.clear();
    super.onClose();
  }
}
