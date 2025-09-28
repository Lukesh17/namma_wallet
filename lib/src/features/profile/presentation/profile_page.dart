import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/profile/data/sample_contributors_data.dart';
import 'package:url_launcher/url_launcher.dart';

// ----------------- Model -----------------
class Contributor {
  final String name;
  final String avatarUrl;
  final String profileUrl;
  Contributor({
    required this.name,
    required this.avatarUrl,
    required this.profileUrl,
  });
  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      name: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      profileUrl: json['html_url'] as String,
    );
  }
}
// ----------------- Profile Page -----------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  List<Contributor> contributors = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      contributors = await _fetchContributors();
      setState(() {});
    });
  }
  Future<List<Contributor>> _fetchContributors() async {
    final response = await http.get(
      Uri.parse(
          'https://api.github.com/repos/Namma-Flutter/namma_wallet/contributors'),
    );
    var body = json.decode(response.body) as List;
    return body
        .map((json) => Contributor.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Contributors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: contributors.length,
                itemBuilder: (context, index) {
                  final contributor = contributors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(contributor.avatarUrl),
                        radius: 24,
                      ),
                      title: Text(contributor.name),
                      subtitle: Text(contributor.profileUrl),
                      onTap: () async {
                        final uri = Uri.parse(contributor.profileUrl);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(AppRoute.dbViewer.name);
        },
        label: const Text('View DB'),
        icon: const Icon(Icons.storage),
      ),
    );
  }
}