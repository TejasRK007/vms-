import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Site'),
            Tab(text: 'Users'),
            Tab(text: 'Notifications'),
            Tab(text: 'FAQs'),
            Tab(text: 'Gadgets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          const _SiteTab(),
          const _UsersTab(),
          const _NotificationsTab(),
          const _FaqsTab(),
          const _GadgetsTab(),
        ],
      ),
    );
  }
}

class _SiteTab extends StatefulWidget {
  const _SiteTab();

  @override
  State<_SiteTab> createState() => _SiteTabState();
}

class _SiteTabState extends State<_SiteTab> {
  bool _requireApproval = true;

  @override
  void initState() {
    super.initState();
    _loadSiteSettings();
  }

  Future<void> _loadSiteSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('site')
          .get();
      if (doc.exists) {
        setState(() {
          _requireApproval = doc.data()?['requireApproval'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading site settings: $e');
    }
  }

  Future<void> _updateSetting(bool value) async {
    setState(() => _requireApproval = value);
    try {
      await FirebaseFirestore.instance
          .collection('config')
          .doc('site')
          .set({'requireApproval': value}, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving setting: $e'),
              backgroundColor: Colors.red),
        );
      }
      // Revert on error
      setState(() => _requireApproval = !_requireApproval);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Site Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Require host/admin approval before entry'),
            value: _requireApproval,
            onChanged: _updateSetting,
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _usernameController = TextEditingController();
  String _selectedRole = 'receptionist';

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateUser() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .set({'role': _selectedRole}, SetOptions(merge: true));
      _usernameController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('User saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                      labelText: 'Username (unique)',
                      prefixIcon: Icon(Icons.person)),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'receptionist', child: Text('Receptionist')),
                  DropdownMenuItem(value: 'host', child: Text('Host')),
                  DropdownMenuItem(value: 'guard', child: Text('Guard')),
                  DropdownMenuItem(value: 'visitor', child: Text('Visitor')),
                ],
                onChanged: (v) =>
                    setState(() => _selectedRole = v ?? _selectedRole),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                  onPressed: _addOrUpdateUser, child: const Text('Save')),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Existing Users'),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No users'));
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(d.id),
                      subtitle: Text('Role: ${d.data()['role'] ?? 'unknown'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(d.id)
                              .delete();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab();

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _enablePushNotifications = true;
  bool _enableLocalNotifications = true;
  bool _enableSound = true;
  bool _enableVibration = true;
  bool _notifyOnNewVisitors = true;
  bool _notifyOnApprovalStatus = true;
  bool _notifyOnCheckOut = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _enablePushNotifications = data['enablePush'] ?? true;
          _enableLocalNotifications = data['enableLocal'] ?? true;
          _enableSound = data['enableSound'] ?? true;
          _enableVibration = data['enableVibration'] ?? true;
          _notifyOnNewVisitors = data['notifyOnNewVisitors'] ?? true;
          _notifyOnApprovalStatus = data['notifyOnApprovalStatus'] ?? true;
          _notifyOnCheckOut = data['notifyOnCheckOut'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> _updateNotificationSetting(String field, bool value) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.user?.uid;
    if (userId == null) return;

    try {
      // Update local state first for immediate feedback
      setState(() {
        switch (field) {
          case 'enablePush':
            _enablePushNotifications = value;
            break;
          case 'enableLocal':
            _enableLocalNotifications = value;
            break;
          case 'enableSound':
            _enableSound = value;
            break;
          case 'enableVibration':
            _enableVibration = value;
            break;
          case 'notifyOnNewVisitors':
            _notifyOnNewVisitors = value;
            break;
          case 'notifyOnApprovalStatus':
            _notifyOnApprovalStatus = value;
            break;
          case 'notifyOnCheckOut':
            _notifyOnCheckOut = value;
            break;
        }
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({field: value}, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving setting: $e'),
              backgroundColor: Colors.red),
        );
      }
      // Revert on error
      setState(() {
        switch (field) {
          case 'enablePush':
            _enablePushNotifications = !_enablePushNotifications;
            break;
          case 'enableLocal':
            _enableLocalNotifications = !_enableLocalNotifications;
            break;
          case 'enableSound':
            _enableSound = !_enableSound;
            break;
          case 'enableVibration':
            _enableVibration = !_enableVibration;
            break;
          case 'notifyOnNewVisitors':
            _notifyOnNewVisitors = !_notifyOnNewVisitors;
            break;
          case 'notifyOnApprovalStatus':
            _notifyOnApprovalStatus = !_notifyOnApprovalStatus;
            break;
          case 'notifyOnCheckOut':
            _notifyOnCheckOut = !_notifyOnCheckOut;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notification Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('General',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Push Notifications'),
            subtitle: const Text(
                'Receive notifications when the app is in background'),
            value: _enablePushNotifications,
            onChanged: (value) =>
                _updateNotificationSetting('enablePush', value),
          ),
          SwitchListTile(
            title: const Text('Enable Local Notifications'),
            subtitle:
                const Text('Show notifications when the app is in foreground'),
            value: _enableLocalNotifications,
            onChanged: (value) =>
                _updateNotificationSetting('enableLocal', value),
          ),
          SwitchListTile(
            title: const Text('Enable Sound'),
            value: _enableSound,
            onChanged: (value) =>
                _updateNotificationSetting('enableSound', value),
          ),
          SwitchListTile(
            title: const Text('Enable Vibration'),
            value: _enableVibration,
            onChanged: (value) =>
                _updateNotificationSetting('enableVibration', value),
          ),
          const SizedBox(height: 24),
          const Text('Notification Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('New Visitor Notifications'),
            subtitle: const Text('Get notified when a new visitor registers'),
            value: _notifyOnNewVisitors,
            onChanged: (value) =>
                _updateNotificationSetting('notifyOnNewVisitors', value),
          ),
          SwitchListTile(
            title: const Text('Approval Status Notifications'),
            subtitle:
                const Text('Get notified when your visit is approved/rejected'),
            value: _notifyOnApprovalStatus,
            onChanged: (value) =>
                _updateNotificationSetting('notifyOnApprovalStatus', value),
          ),
          SwitchListTile(
            title: const Text('Check-out Notifications'),
            subtitle: const Text('Get notified when visitors check out'),
            value: _notifyOnCheckOut,
            onChanged: (value) =>
                _updateNotificationSetting('notifyOnCheckOut', value),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadNotificationSettings,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqsTab extends StatelessWidget {
  const _FaqsTab();

  @override
  Widget build(BuildContext context) {
    const faqs = [
      {
        'q': 'How to register a visitor?',
        'a': 'Use Register flow on Dashboard.'
      },
      {'q': 'How to check-out a visitor?', 'a': 'Open Check-out and confirm.'},
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = faqs[index];
        return ListTile(
          title: Text(item['q']!),
          subtitle: Text(item['a']!),
        );
      },
    );
  }
}

class _GadgetsTab extends StatelessWidget {
  const _GadgetsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gadget Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
              'No hardware configured. You can add printers, RFID, camera, and signature devices later.'),
        ],
      ),
    );
  }
}
