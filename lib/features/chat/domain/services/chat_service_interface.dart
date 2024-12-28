import 'package:flutter_image_compression/flutter_image_compression.dart';
import 'package:get/get.dart';
import 'package:talabatcom/api/api_client.dart';
import 'package:talabatcom/features/chat/domain/models/conversation_model.dart';

abstract class ChatServiceInterface{
  Future<ConversationsModel?> getConversationList(int offset, String type);
  Future<ConversationsModel?> searchConversationList(String name);
  Future<Response> getMessages(int offset, int? userID, String userType, int? conversationID);
  Future<Response> sendMessage(String message, List<MultipartBody> images, int? userID, String userType, int? conversationID);
  int setIndex(List<Conversation?>? conversations);
  bool checkSender(List<Conversation?>? conversations);
  int findOutConversationUnreadIndex(List<Conversation?>? conversations, int? conversationID);
  Future<XFile> compressImage(XFile file);
  List<MultipartBody> processMultipartBody(List<XFile> chatImage);
}