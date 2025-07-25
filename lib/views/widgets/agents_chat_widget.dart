import 'package:flutter/material.dart';
import 'package:jnk_app/consts/app_constants.dart';

class AgentsChatWidget extends StatelessWidget {
  final String agentProfilePic;
  final String agentName;
  final String lastMessage;
  final String lastActive;
  const AgentsChatWidget({
    super.key,
    required this.agentName,
    required this.agentProfilePic,
    required this.lastMessage,
    required this.lastActive,
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
          backgroundImage: AssetImage(AppConstants.profilePlaceholder),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          agentName,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.done_all, size: 20.0),
            SizedBox(width: 5.0),
            Text(
              lastMessage,
              style: TextStyle(color: AppConstants.secondaryColor),
            ),
          ],
        ),
        trailing: Text(
          lastActive,
          style: TextStyle(color: AppConstants.secondaryColor),
        ),
      ),
    );
  }
}
