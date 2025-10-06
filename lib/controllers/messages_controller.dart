import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jnk_app/controllers/base_controller.dart';
import 'package:jnk_app/controllers/chat_controller.dart';
import 'package:mime_type/mime_type.dart';
import 'package:flutter_twilio_chat_conversations/twilio_conversations.dart';

class MessagesController extends GetxController {
  // Controllers
  final messageInputTextController = TextEditingController();
  final listScrollController = ScrollController();

  // Reactive State
  static var isLoading = true.obs;
  var isSendingMessage = false.obs;
  var isError = false.obs;

  final limit = 20;
  late Conversation conversation;
  late ConversationClient client;
  late ChatController chatController;

  var messages = <Message>[].obs;
  var participants = <Participant>[].obs;
  var participantCount = 0.obs;
  var startingIndex = 0.obs;
  var currentlyTyping = <String>{}.obs;

  final subscriptions = <StreamSubscription>[];
  final messageMedia = <String, Uint8List>{}.obs;

  MessagesController(this.conversation, this.client, this.chatController);

  @override
  void onInit() {
    super.onInit();

    messageInputTextController.addListener(() => update());
    messageInputTextController.addListener(conversation.typing);

    startingIndex.value = conversation.lastMessageIndex ?? 0;

    subscriptions.add(
      conversation.onMessageAdded.listen((message) async {
        messages.insert(0, message);
        final messageIndex = message.messageIndex;
        if (messageIndex != null) {
          conversation.advanceLastReadMessageIndex(messageIndex);
        }

        // if (conversation.sid ==
        // BaseController.user.value?.twilioConversationSid) {
        // conversation.setAllMessagesRead();
        await client.getMyConversations();
        // }

        final newMsg = {
          'id': message.messageIndex ?? 0,
          'sid': message.sid ?? '',
          'text': message.type == MessageType.MEDIA ? '' : (message.body ?? ''),
          'time': message.dateCreated != null
              ? message.dateCreated!.toLocal().toString()
              : DateTime.now().toString(),
          'isMe': message.author == client.myIdentity,
          'isMedia': message.type == MessageType.MEDIA,
          'isLocal': false,
        };

        chatController.messages.add(newMsg);
        chatController.buildChatWidgets();
        // chatController.messages.refresh();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
        if (message.type == MessageType.MEDIA) {
          _getMedia(message);
        }
      }),
    );

    subscriptions.add(
      conversation.onMessageDeleted.listen((_) {
        loadConversation();
      }),
    );

    subscriptions.add(
      conversation.onMessageUpdated.listen((_) {
        loadConversation();
      }),
    );

    subscriptions.add(
      conversation.onTypingStarted.listen((event) {
        final identity = event.participant.identity;
        if (identity != null) {
          currentlyTyping.add(identity);
        }
      }),
    );

    subscriptions.add(
      conversation.onTypingEnded.listen((event) {
        final identity = event.participant.identity;
        if (identity != null) {
          currentlyTyping.remove(identity);
        }
      }),
    );

    subscriptions.add(
      client.onConversationUpdated.listen((_) {
        update();
      }),
    );
  }

  void loadConversation() {
    reset();
    loadMessages();
  }

  Future addUserByIdentity(String identity) async {
    await conversation.addParticipantByIdentity(identity);
    await getParticipants();
  }

  Future<void> getParticipants() async {
    final result = await conversation.getParticipantsList();
    participants.assignAll(result);
    participantCount.value = await conversation.getParticipantsCount();
    if (participants.isNotEmpty) {
      final user = await participants.first.getUser();
      print('MessagesController::getParticipants => gotUser: $user');
    }
  }

  Future<void> removeParticipant(Participant participant) async {
    await participant.remove();
    await getParticipants();
  }

  Future<bool> removeMessage(Message message) async {
    final result = await conversation.removeMessage(message);
    return result;
  }

  Future<void> setFriendlyName(String name) async {
    await conversation.setFriendlyName(name);
  }

  Future<void> setUniqueName(String name) async {
    await conversation.setUniqueName(name);
  }

  Future<void> getAttributes() async {
    final currentAttributes = conversation.attributes;
    if (currentAttributes != null) {
      switch (currentAttributes.type) {
        case AttributesType.NULL:
          print('getAttributes => NULL: ${currentAttributes.data}');
          break;
        case AttributesType.ARRAY:
          print('getAttributes => Array: ${currentAttributes.getJSONArray()}');
          break;
        case AttributesType.OBJECT:
          print(
            'getAttributes => Object: ${currentAttributes.getJSONObject()}',
          );
          break;
        case AttributesType.NUMBER:
          print('getAttributes => Number: ${currentAttributes.getNumber()}');
          break;
        case AttributesType.STRING:
          print('getAttributes => String: ${currentAttributes.getString()}');
          break;
      }
    }
  }

  Attributes getMockAttributes(AttributesType type) {
    var attributes = Attributes(AttributesType.NULL, null);
    switch (type) {
      case AttributesType.NULL:
        attributes = Attributes(type, null);
        break;
      case AttributesType.STRING:
        attributes = Attributes(type, 'i am a string');
        break;
      case AttributesType.NUMBER:
        attributes = Attributes(type, 173.95.toString());
        break;
      case AttributesType.ARRAY:
        attributes = Attributes(
          type,
          jsonEncode([
            'test',
            17,
            false,
            95,
            {'key1': null, 'key17': 43.95, 'key5': []},
          ]),
        );
        break;
      case AttributesType.OBJECT:
        attributes = Attributes(
          type,
          jsonEncode({
            'key1': 73,
            'key2': null,
            'key3': [17, 1, -5, null],
            'key5': 'a string',
          }),
        );
        break;
    }
    return attributes;
  }

  Future<Attributes?> getMyAttributes() async {
    final myParticipant = await conversation.getParticipantByIdentity(
      client.myIdentity!,
    );
    final myUser = await myParticipant?.getUser();
    final currentAttributes = myUser?.attributes;

    if (currentAttributes != null) {
      print('getMyAttributes => type: ${currentAttributes.type}');
      return currentAttributes;
    }
    return null;
  }

  Future<void> swapMessageAttributes(
    Message message,
    AttributesType type,
  ) async {
    final attributes = getMockAttributes(type);
    await message.setAttributes(attributes);
  }

  Future<void> swapConversationAttributes(AttributesType type) async {
    final attributes = getMockAttributes(type);
    await conversation.setAttributes(attributes);
  }

  Future<void> swapMyAttributes(AttributesType type) async {
    final myParticipant = await conversation.getParticipantByIdentity(
      client.myIdentity!,
    );
    if (myParticipant == null) return;

    final myUser = await myParticipant.getUser();
    if (myUser == null) return;

    final attributes = getMockAttributes(type);
    await myUser.setAttributes(attributes);
  }

  Future<void> destroy() async {
    return conversation.destroy();
  }

  void reset() {
    messages.clear();
    // isLoading.value = false;
    startingIndex.value = 0;
  }

  bool hasMedia(String messageSid) {
    return messageMedia[messageSid] != null;
  }

  Uint8List? media(String messageSid) {
    return messageMedia[messageSid];
  }

  // Future _getMedia(Message message) async {
  //   print('_getMedia => message: ${message.sid}');
  //   final url = await message.getMediaUrl();
  //   if (url != null) {
  //     final uri = Uri.parse(url);
  //     final response = await http.get(uri);
  //     messageMedia[message.sid!] = response.bodyBytes;
  //     // if (chatController.messages.any((m) => m['id'] == message.messageIndex)) {
  //     //   return;
  //     // }
  //     final index = chatController.messages.indexWhere(
  //       (m) => m['id'] == message.messageIndex,
  //     );
  //     if (index != -1) {
  //       chatController.messages[index] = {
  //         'id': message.messageIndex ?? 0,
  //         'sid': message.sid ?? '',
  //         'text': url,
  //         'time': message.dateCreated != null
  //             ? message.dateCreated!.toLocal().toString()
  //             : DateTime.now().toString(),
  //         'isMe': message.author == client.myIdentity,
  //         'isMedia': true,
  //         'isLocal': isLocal,
  //       };
  //       // chatController.buildChatWidgets();
  //       chatController.messages.refresh();
  //     }
  //     print('_getMedia => url: $url');
  //   }
  // }

  Future<void> _getMedia(Message message) async {
    print('_getMedia => message: ${message.sid}');

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${message.sid}.jpg';
      final file = File(filePath);

      if (await file.exists()) {
        print('_getMedia => loaded from cache: $filePath');
        _updateMessageEntry(message, file.path, isLocal: true);
        return;
      }
      final url = await message.getMediaUrl();
      if (url == null) {
        print('_getMedia => No media URL for ${message.sid}');
        return;
      }
      print('_getMedia => downloading from: $url');
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        messageMedia[message.sid!] = Uint8List.fromList(response.data!);
        _updateMessageEntry(message, file.path, isLocal: true);
        print('_getMedia => saved to: ${file.path}');
      } else {
        print(
          '_getMedia => failed to download, status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('_getMedia => error: $e');
    }
  }

  void _updateMessageEntry(
    Message message,
    String path, {
    bool isLocal = false,
  }) {
    final index = chatController.messages.indexWhere(
      (m) => m['id'] == message.messageIndex,
    );

    if (index != -1) {
      chatController.messages[index] = {
        'id': message.messageIndex ?? 0,
        'sid': message.sid ?? '',
        'text': path, // cached file path
        'time': message.dateCreated != null
            ? message.dateCreated!.toLocal().toString()
            : DateTime.now().toString(),
        'isMe': message.author == client.myIdentity,
        'isMedia': true,
        'isLocal': isLocal,
      };

      chatController.messages.refresh();
    }
  }

  void refetchAfterError() {
    loadConversation();
  }

  void loadMessages() async {
    isLoading.value = true;

    final numberOfMessages = await conversation.getMessagesCount();
    if (numberOfMessages != null) {
      final nextMessages = await conversation.getLastMessages(numberOfMessages);

      messages.assignAll(nextMessages.reversed);
      for (var message in messages) {
        if (message.type == MessageType.MEDIA) {
          _getMedia(message);
        }
      }
      chatController.messages.clear();
      for (var msg in messages) {
        if (msg.type == MessageType.MEDIA) {
          // Don’t add blank placeholder — wait for media to finish loading

          chatController.messages.add({
            'id': msg.messageIndex ?? 0,
            'sid': msg.sid ?? '',
            'text': msg.body ?? '',
            'time': msg.dateCreated != null
                ? msg.dateCreated!.toLocal().toString()
                : DateTime.now().toString(),
            'isMe': msg.author == client.myIdentity,
            'isMedia': true,
            'isLocal': false,
          });
          _getMedia(msg);
        } else {
          chatController.messages.add({
            'id': msg.messageIndex ?? 0,
            'sid': msg.sid ?? '',
            'text': msg.body ?? '',
            'time': msg.dateCreated != null
                ? msg.dateCreated!.toLocal().toString()
                : DateTime.now().toString(),
            'isMe': msg.author == client.myIdentity,
            'isMedia': false,
            'isLocal': false,
          });
        }
      }
      chatController.filteredMessages;
      print("MESSAGES: ${chatController.messages}");
      chatController.buildChatWidgets();
      // chatController.messages.refresh();
    }

    await conversation.setAllMessagesRead();
    isLoading.value = false;
  }

  void onSendMessagePressed() async {
    if (messageInputTextController.text.isEmpty) return;

    isSendingMessage.value = true;

    Message? message;
    try {
      final attributesData = <String, dynamic>{
        'name': 'test',
        'arbitraryNumber': -13,
      };
      final attributes = Attributes(
        AttributesType.OBJECT,
        jsonEncode(attributesData),
      );
      final messageOptions = MessageOptions()
        ..withBody(messageInputTextController.text)
        ..withAttributes(attributes);
      message = await conversation.sendMessage(messageOptions);
      Future.delayed(const Duration(milliseconds: 100), () {
        // scrollToBottom(animated: true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom(animated: true);
        });
      });
    } catch (e) {
      print('Failed to send message Error: $e');
    }

    isSendingMessage.value = false;

    if (message != null) {
      messageInputTextController.clear();
    }
  }

  Future onSendMediaMessagePressed() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    final mimeType = mime(image?.path);
    if (image != null && mimeType != null) {
      final File fileImage = File(image.path);
      File croppedImage = await BaseController.compressImage(fileImage, 10);
      final path = croppedImage.path;
      int sizeInBytes = await croppedImage.length();
      double sizeInKb = sizeInBytes / 1024;
      double sizeInMb = sizeInKb / 1024;
      print('File size in KB: ${sizeInKb.toStringAsFixed(2)} KB');
      print('File size in MB: ${sizeInMb.toStringAsFixed(2)} MB');

      final messageOptions = MessageOptions()..withMedia(File(path), mimeType);
      await conversation.sendMessage(messageOptions);
    }
  }

  @override
  void onClose() {
    messageInputTextController.removeListener(() => update());
    messageInputTextController.removeListener(conversation.typing);
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.onClose();
  }

  void scrollToBottom({bool animated = true}) {
    if (!listScrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = listScrollController.position.minScrollExtent;
      if (animated) {
        listScrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        listScrollController.jumpTo(position);
      }
    });
  }
}
