import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Announcement extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> item;
  const Announcement(this.item, {Key? key}) : super(key: key);

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // height: _expanded
      //     ? min(/*widget.order.products.length*/ 2 * 20.0 + 110, 200)
      //     : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              // leading: const Align(
              //   alignment: Alignment.center,
              //   child: Text('username'),
              // ),
              leading: Text(widget.item['username']),
              title: Text('${widget.item['title']}'),
              subtitle: Text(
                  "Announced at ${widget.item['targetDate'].toDate().day}-${widget.item['targetDate'].toDate().month}-${widget.item['targetDate'].toDate().year} at ${widget.item['targetDate'].toDate().hour}:${widget.item['targetDate'].toDate().minute}"),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded
                    ? min(/*widget.message.length*/ 2 * 20.0 + 10, 100)
                    : 0,
                child: Text(
                  widget.item['message'],
                ))
          ],
        ),
      ),
    );
  }
}
