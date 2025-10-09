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
  void _bindReactiveMessageSync() {
    ever<List<Message>>(messages, (_) {
      final mapped = messages.map((msg) {
        return {
          'id': msg.messageIndex ?? 0,
          'sid': msg.sid ?? '',
          'text': msg.type == MessageType.MEDIA ? '' : (msg.body ?? ''),
          'time': msg.dateCreated != null
              ? msg.dateCreated!.toLocal().toString()
              : DateTime.now().toString(),
          'isMe': msg.author == client.myIdentity,
          'isMedia': msg.type == MessageType.MEDIA,
          'isLocal': false,
        };
      }).toList();

      chatController.messages.assignAll(mapped);
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
        }

        // Mark as read
        final messageIndex = message.messageIndex;
        if (messageIndex != null) {
          conversation.advanceLastReadMessageIndex(messageIndex);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
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

  void loadMessages() async {
    isLoading.value = true;
    final total = await conversation.getMessagesCount() ?? 0;
    final lastMsgs = await conversation.getLastMessages(total);
    messages.assignAll(lastMsgs.reversed);

    for (final msg in messages) {
      if (msg.type == MessageType.MEDIA) _getMedia(msg);
    }

    await conversation.setAllMessagesRead();
    isLoading.value = false;
  }

  void initConversation(Conversation conversation) async {
    this.conversation = conversation;

    // Ensure messages are synchronized
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
    loadMessages();
  }

  Future<void> _getMedia(Message message) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${message.sid}.jpg';
      final file = File(filePath);

      if (await file.exists()) {
        messageMedia[message.sid!] = await file.readAsBytes();
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
    super.onClose();
  }
}
