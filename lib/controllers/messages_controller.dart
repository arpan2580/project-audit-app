import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:jnk_app/services/base_client.dart';
import 'package:jnk_app/views/dialogs/dialog_helper.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';

class MessagesController extends GetxController {
  final messageInputTextController = TextEditingController();
  final listScrollController = ScrollController();

  static final isLoading = true.obs;
  final isSendingMessage = false.obs;
  final isError = false.obs;
  RxBool isLoaded = false.obs;

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

  void _bindReactiveMessageSync() {
    ever<List<Message>>(messages, (_) {
      for (final msg in messages) {
        final sid = msg.sid ?? '';
        final existingIndex = chatController.messages.indexWhere(
          (m) => m['sid'] == sid,
        );
        var userName = getUserNameFromIdentity(msg.author);
        var profilePicUrl = getPicUrlFromIdentity(msg.author);
        final newMap = {
          'id': msg.messageIndex ?? 0,
          'sid': sid,
          'text': msg.type == MessageType.MEDIA ? '' : (msg.body ?? ''),
          'time':
              msg.dateCreated?.toLocal().toString() ??
              DateTime.now().toString(),
          'author': userName ?? 'Admin',
          'profilePic': profilePicUrl ?? '',
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

  // Initializes Twilio event listeners
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
    isLoaded.value = false;
    try {
      final total = await conversation.getMessagesCount() ?? 0;
      if (total == 0) {
        messages.clear();
        return;
      }

      final lastMsgs = await conversation.getLastMessages(total);

      // Only add missing messages
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
      isLoaded.value = true;
    } catch (e) {
      // print('loadMessages error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initConversation(Conversation newConversation) async {
    // Cancel all previous subscriptions so old conversation streams stop flowing
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
    // load messages for the new conversation
    loadMessages();
  }

  Future<void> _getMedia(Message message) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      if (files.length > 500) {
        // Delete oldest files first
        files.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
        );
        final excess = files.length - 400; // keep 400 latest
        for (int i = 0; i < excess; i++) {
          try {
            files[i].deleteSync();
          } catch (e) {
            // print('_getMedia => failed to delete cache file: $e');
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
      final token = BaseController.storeToken.read('token');
      final dioClient = dio.Dio();

      final response = await dioClient.post(
        "https://jnkundu.com/api/v1/chat/media-url/",
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'media_sid': message.media?.sid},
      );

      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        messageMedia[message.sid!] = Uint8List.fromList(response.data!);
        _updateMediaInChat(message, file.path);
      }
    } catch (e) {
      // print('_getMedia error: $e');
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
      // print('Error sending message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> onSendMediaMessagePressed() async {
    try {
      final pickedFile = await BaseController.pickImageSafely(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        DialogHelper.showLoadingDialog('Uploading image...');
        File croppedImage = await BaseController.compressImage(
          File(pickedFile.path),
          40,
        );
        final mType = mime(croppedImage.path) ?? "image/jpeg";
        final dioClient = dio.Dio();
        dioClient.interceptors.add(
          dio.LogInterceptor(requestBody: true, responseBody: true),
        );
        final formData = dio.FormData.fromMap({
          "conversation_sid": conversation.sid,
          "image_file": await dio.MultipartFile.fromFile(
            croppedImage.path,
            filename: croppedImage.path.split('/').last,
            contentType: dio.DioMediaType.parse(mType),
          ),
        });
        // response = await dioClient.post(
        //   "https://jnkundu.com/api/v1/chat/media-upload/",
        //   options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
        //   data: formData,
        // );
        await BaseClient().dioPost('/chat/media-upload/', formData);
        messages.refresh();
        DialogHelper.hideLoadingDialog();
      } else {
        return;
      }
    } catch (e, st) {
      DialogHelper.showErrorToast(description: 'Failed to send media.$e\n$st');
    }
  }

  Future<void> deleteMessageBySid(String messageSid) async {
    try {
      // Find the message in the messages list by its SID
      final Message? msg = messages.firstWhereOrNull(
        (m) => m.sid == messageSid,
      );
      if (msg != null) {
        await conversation.removeMessage(msg);
        messages.remove(msg); // Update local list immediately
        messages.refresh();
        final int chatIdx = chatController.messages.indexWhere(
          (m) => m['sid'] == messageSid,
        );
        if (chatIdx != -1) {
          chatController.messages.removeAt(chatIdx);
          chatController.messages.refresh();
        }

        chatController.buildChatWidgets();
      }
    } catch (e) {
      // print('Error deleting message: $e');
      isError.value = true;
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

  String? getUserNameFromIdentity(String? userIdentity) {
    if (userIdentity != null) {
      final parts = userIdentity.split('-');
      if (parts.length < 3) return null;
      final idPart = parts.last;
      final int? userId = int.tryParse(idPart);
      if (userId == null) return null;
      final user = BaseController.chatUsers.firstWhere(
        (u) => u?.id == userId,
        orElse: () => null,
      );
      return user?.name;
    } else {
      return null;
    }
  }

  String? getPicUrlFromIdentity(String? userIdentity) {
    if (userIdentity != null) {
      final parts = userIdentity.split('-');
      if (parts.length < 3) return null;
      final idPart = parts.last;
      final int? userId = int.tryParse(idPart);
      if (userId == null) return null;
      final user = BaseController.chatUsers.firstWhere(
        (u) => u?.id == userId,
        orElse: () => null,
      );
      return user?.avatar;
    } else {
      return null;
    }
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
