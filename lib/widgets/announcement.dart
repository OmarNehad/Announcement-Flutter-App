import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:obs_clone/utils/firebase_api.dart';
import 'package:intl/intl.dart';

class Announcement extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> item;
  const Announcement(this.item, {Key? key}) : super(key: key);
  void _buildAnnouns(BuildContext cntx) {
    showDialog(
        context: cntx,
        builder: (BuildContext cntx) {
          return AlertDialog(
            title: Text(item['title']),
            content: Column(
              children: [
                Text(
                  item['message'],
                ),
                const SizedBox(
                  height: 20,
                ),
                if (item["attachedFile"] != null)
                  InkWell(
                    onTap: () async {
                      ScaffoldMessenger.of(cntx).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Downloading ${item['attachedFile']}...'),
                      ));
                      await FirebaseApi.downloadFile(FirebaseStorage.instance
                          .ref('files/' + item['attachedFile']));

                      ScaffoldMessenger.of(cntx).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text('Downloaded ${item['attachedFile']}'),
                      ));
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.download),
                        Text(item['attachedFile']),
                      ],
                    ),
                  ),
              ],
            ),
            actionsPadding: EdgeInsets.zero,
            scrollable: true,
            actions: <Widget>[
              Text(
                "Announced by ${item["username"]} at ${DateFormat.yMd().add_jm().format(item["targetDate"].toDate())}",
                style: const TextStyle(color: Colors.grey),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(cntx).pop();
                  },
                  child: const Text('OK')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            child: ListTile(
              // leading: const Align(
              //   alignment: Alignment.center,
              //   child: Text('username'),
              //
              // ,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                    "https://ui-avatars.com/api/?name=${item["username"]}&background=random",
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                }),
              ),
              title: Text('${item['title']}'),
              subtitle: Text(
                "by ${item["username"]} at ${DateFormat.yMd().add_jm().format(item["targetDate"].toDate())}",
              ),
              trailing: const Icon(Icons.navigate_next_sharp),
              onTap: () {
                _buildAnnouns(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
