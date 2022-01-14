import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/create_announcements_screen.dart';
import '../widgets/announcement.dart';
import '/screens/creat_user_screen.dart';

class HomeScreen extends StatefulWidget {
  final int _userRole;
  final int? _userGrade;
  const HomeScreen(this._userRole, this._userGrade, {Key? key})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<QuerySnapshot<Map<String, dynamic>>> get announs {
    return widget._userRole > 0
        ? FirebaseFirestore.instance
            .collection("announcements")
            .orderBy("targetDate", descending: true)
            .orderBy("urgency")
            .get()
        : FirebaseFirestore.instance
            .collection("announcements")
            .where("targetGroups",
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy("targetDate")
            .orderBy("urgency")
            .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: NestedScrollView(
              headerSliverBuilder: (context, value) {
                return [
                  SliverAppBar(
                    title: const Text("Home Screen"),
                    floating: true,
                    pinned: true,
                    actions: [
                      PopupMenuButton<int>(
                          onSelected: (item) {
                            switch (item) {
                              case 0:
                                Navigator.of(context)
                                    .pushNamed(CreatUserScreen.routeName);
                                break;
                              case 1:
                                Navigator.of(context)
                                    .pushNamed(CreateAnnouncement.routeName);
                                break;
                              case 2:
                                FirebaseAuth.instance.signOut();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                                if (widget._userRole > 0)
                                  const PopupMenuItem(
                                      value: 0, child: Text("Add a new User")),
                                if (widget._userRole > 0)
                                  const PopupMenuItem(
                                      value: 1,
                                      child: Text("Create a new Announcement")),
                                const PopupMenuItem(
                                    value: 2, child: Text("Logout")),
                              ])
                    ],
                    bottom: TabBar(
                      tabs: [
                        Tab(
                            text: widget._userRole > 0
                                ? "Announcements for you"
                                : " Class Announcements",
                            icon: const Icon(Icons.mail)),
                        Tab(
                            text: widget._userRole > 0
                                ? "Announcements by you"
                                : "Inbox",
                            icon: widget._userRole > 0
                                ? const Icon(Icons.send)
                                : const Icon(Icons.inbox)),
                      ],
                    ),
                  )
                ];
              },
              body: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection("announcements")
                            .where("targetGroups",
                                arrayContains:
                                    widget._userGrade ?? widget._userRole)
                            .orderBy("targetDate")
                            .orderBy("urgency")
                            .get(),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              data = snapshot.data!.docs;
                          if (data.isNotEmpty) {
                            return ListView.builder(
                                padding: const EdgeInsets.all(8),
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (_, index) {
                                  return Announcement(data[index]);
                                });
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No Announcemnts are made for your group yet! Pull to refresh",
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                        }),
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          future: announs,
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                data = snapshot.data!.docs;
                            if (data.isNotEmpty) {
                              return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder: (_, index) {
                                    return Announcement(data[index]);
                                  });
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  widget._userRole > 0
                                      ? "No Announcemnts are made by you yet, Pull to refresh"
                                      : "No Announcemnts are made for you yet, Pull to refresh",
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                          },
                        ),
                        if (widget._userRole > 0)
                          FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(CreateAnnouncement.routeName);
                            },
                            child: const Icon(Icons.add),
                          )
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
