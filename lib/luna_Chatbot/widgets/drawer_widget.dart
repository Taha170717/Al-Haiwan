import 'package:flutter/material.dart';

class LunaDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  const LunaDrawer({super.key, required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.of(context).pop();
                onNewChat();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Luna'),
              onTap: () {
                Navigator.of(context).pop();
                showAboutDialog(
                  context: context,
                  applicationName: 'Luna',
                  applicationVersion: '0.1',
                  children: const [Text('Luna — Animal Health Care Assistant')],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
