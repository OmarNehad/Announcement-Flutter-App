import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import '../utils/date_form_field.dart';
import '../widgets/adjust_form.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/firebase_api.dart';
import 'package:path/path.dart';

class CreateAnnouncement extends StatefulWidget {
  const CreateAnnouncement({Key? key}) : super(key: key);
  static const routeName = '/create-announcement';
  @override
  State<CreateAnnouncement> createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  final _formKey = GlobalKey<FormState>();
  var _message = '';
  var _title = '';
  late DateTime _targetDate = DateTime.now();
  List _targetGroups = [];
  List _targetUsers = [];
  var _urgency = 2;
  var _isLoading = false;
  UploadTask? task;
  File? file;

  void _createAnouncment() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
      final _donwloadUrl = await uploadFile();

      await FirebaseFirestore.instance.collection('announcements').add({
        'title': _title,
        'message': _message,
        'targetGroups': [..._targetGroups, ..._targetUsers],
        'creationTime': DateTime.now(),
        'targetDate': _targetDate,
        'userId': user.uid,
        'username': user.displayName,
        'urgency': _urgency,
        'attachedFile': _donwloadUrl,
      });
      showDialog(
          context: this.context,
          builder: (BuildContext cntx) {
            return AlertDialog(
              title: const Text("Success"),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(cntx).pop();
                      Navigator.of(cntx).pop();
                    },
                    child: const Text('Close')),
              ],
            );
          });
    } on Exception catch (e) {
      var message = 'An error occurred';

      message = e.toString();

      showDialog(
          context: this.context,
          builder: (BuildContext cntx) {
            return AlertDialog(
              title: const Icon(Icons.done),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(cntx).pop();
                    },
                    child: const Text('Close')),
              ],
            );
          });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add an anouncment"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Create a new Announcment",
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          Expanded(
            child: AdjustForm(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Title"),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 10) {
                          return "Please enter no less than 8";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Message"),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 10) {
                          return "Please enter no less than 8";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _message = value!;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    MultiSelectFormField(
                      title: const Text("Groups List"),
                      chipBackGroundColor:
                          Theme.of(context).colorScheme.primary,
                      chipLabelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      dialogTextStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      checkBoxActiveColor:
                          Theme.of(context).colorScheme.primary,
                      checkBoxCheckColor: Colors.white,
                      validator: (value) {
                        if (_targetGroups.isEmpty && _targetUsers.isEmpty) {
                          return 'Please select one or more Group/Users';
                        }
                        return null;
                      },
                      dataSource: [
                        'Teachers',
                        'Managers',
                        'Grade 06',
                        'Grade 07',
                        'Grade 08',
                        'Grade 09',
                        'Grade 10',
                        'Grade 11',
                        'Grade 12',
                      ].mapIndexed((index, grade) {
                        return {
                          "display": grade,
                          "value": grade.contains("Grade")
                              ? int.parse(grade.substring(grade.length - 2))
                              : index + 2
                        };
                      }).toList(),
                      textField: 'display',
                      valueField: 'value',
                      okButtonLabel: 'OK',
                      cancelButtonLabel: 'CANCEL',
                      hintWidget: const Text('Please choose one or more'),
                      initialValue: _targetGroups,
                      onSaved: (value) {
                        _targetGroups = [...value];
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .where("role", isGreaterThan: 0)
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

                          return MultiSelectFormField(
                            title: const Text("Students List"),
                            chipBackGroundColor:
                                Theme.of(context).colorScheme.primary,
                            chipLabelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            dialogTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            checkBoxActiveColor:
                                Theme.of(context).colorScheme.primary,
                            checkBoxCheckColor: Colors.white,
                            initialValue: _targetUsers,
                            validator: (value) {
                              if (_targetGroups.isEmpty &&
                                  _targetUsers.isEmpty) {
                                return 'Please select one or more Group/Users';
                              }
                              return null;
                            },
                            dataSource: data.mapIndexed((index, grade) {
                              return {
                                "display": data[index]['email'],
                                "value": data[index].id,
                              };
                            }).toList(),
                            textField: 'display',
                            valueField: 'value',
                            okButtonLabel: 'OK',
                            cancelButtonLabel: 'CANCEL',
                            hintWidget: const Text('Please choose one or more'),
                            onSaved: (value) {
                              _targetUsers = [...value];
                            },
                          );
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    DateTimeFormField(
                      lastDate: DateTime.now().add(const Duration(days: 120)),
                      validator: (value) {
                        if (!_targetDate.isAfter(DateTime.now())) {
                          return 'Please select a Date in the future';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _targetDate = value!;
                      },
                    ),
                    DropdownButtonFormField<int>(
                      value: _urgency,
                      items: ['Urgent', 'Important', 'Normal']
                          .mapIndexed((index, value) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _urgency = value!;
                      },
                      onSaved: (value) {
                        _urgency = value!;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          onPressed: selectFile,
                          icon: const Icon(
                            Icons.attach_file,
                          ),
                        ),
                        task != null ? buildUploadStatus(task!) : Container(),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _createAnouncment();
                          }
                        },
                        child: const Text("Create Announcment"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey[900],
                        ),
                      ),
                    if (_isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    setState(() => file = File(result.files.single.path!));
  }

  Future<String?> uploadFile() async {
    if (file == null) return null;
    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return "failed";

    final snapshot = await task!.whenComplete(() {});
    return snapshot.ref.name;
    //final urlDownload = await snapshot.ref.getDownloadURL();
    //return urlDownload;
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
}
