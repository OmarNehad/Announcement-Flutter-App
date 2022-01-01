import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:obs_clone/screens/create_announcements_screen.dart';
import 'package:obs_clone/widgets/announcement.dart';
import '/screens/creat_user_screen.dart';

class HomeScreen extends StatelessWidget {
  final int _userRole;
  final int? _userGrade;
  Future<QuerySnapshot<Map<String, dynamic>>> get announs {
    return _userRole > 0
        ? FirebaseFirestore.instance
            .collection("announcement")
            .orderBy("targetDate", descending: true)
            .get()
        : FirebaseFirestore.instance
            .collection("announcement")
            .where("targetGroups",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy("targetDate")
            .get();
  }

  const HomeScreen(this._userRole, this._userGrade, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
        ),
        actions: [
          if (_userRole > 0)
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CreatUserScreen.routeName);
              },
              icon: const Icon(Icons.supervised_user_circle_outlined),
            ),
          if (_userRole > 0)
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CreateAnnouncement.routeName);
              },
              icon: const Icon(Icons.create),
            ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection("announcement")
                  .where("targetGroups", arrayContains: _userGrade ?? _userRole)
                  .orderBy("targetDate")
                  .get(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
                    snapshot.data!.docs;
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (_, index) {
                      return Announcement(data[index]);
                    });
              }),
          const Divider(),
          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: announs,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
                    snapshot.data!.docs;
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (_, index) {
                      return Announcement(data[index]);
                    });
              }),
        ],
      ),
    );
  }
}
