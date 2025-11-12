import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';

class AgentsChatWidget extends StatelessWidget {
  final String agentProfilePic;
  final String agentName;
  final String lastMessage;
  final String lastActive;
  final int unreadCount;
  const AgentsChatWidget({
    super.key,
    required this.agentName,
    required this.agentProfilePic,
    required this.lastMessage,
    required this.lastActive,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: AppConstants.logoBlueColor),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: agentProfilePic,
              fit: BoxFit.cover,
              width: 160, // 2 * radius
              height: 160,
              placeholder: (context, url) =>
                  Image.asset(AppConstants.profilePlaceholder),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, size: 40),
            ),
          ),
        ),
        title: Text(
          agentName,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            // Icon(Icons.done_all, size: 20.0),
            // SizedBox(width: 5.0),
            Text(
              lastMessage,
              style: TextStyle(color: AppConstants.secondaryColor),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   lastActive,
            //   style: TextStyle(color: AppConstants.secondaryColor),
            // ),
            // const SizedBox(height: 6),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
