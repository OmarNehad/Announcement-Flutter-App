import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import '../widgets/adjust_form.dart';

class CreatUserScreen extends StatefulWidget {
  const CreatUserScreen({Key? key}) : super(key: key);
  static const routeName = '/create_user';

  @override
  _CreatUserScreenState createState() => _CreatUserScreenState();
}

class _CreatUserScreenState extends State<CreatUserScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userPass = '';
  var _userName = '';
  var _userRole = 0;
  int? _userGrade;
  late int _userMobile;
  void _createUser() async {
    UserCredential _authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      _authResult = await _auth.createUserWithEmailAndPassword(
          email: _userEmail.trim(), password: _userPass.trim());
      await _authResult.user!.updateDisplayName(_userName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_authResult.user?.uid)
          .set({
        'email': _userEmail.trim(),
        'role': _userRole,
        'mobile': _userMobile,
        'grade': _userGrade,
      });
      showDialog(
          context: context,
          builder: (BuildContext cntx) {
            return AlertDialog(
              title: const Text("Success"),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(cntx).pop();
                    },
                    child: const Text('Close')),
              ],
            );
          });
    } on FirebaseAuthException catch (e) {
      var message = 'An error occurred, pelase check the credentials!';
      if (e.message != null) {
        message = e.message!;
      }
      showDialog(
          context: context,
          builder: (BuildContext cntx) {
            return AlertDialog(
              title: const Text("Error"),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a User"),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: AdjustForm(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(label: Text("Email Adress")),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains("@")) {
                      return 'Please enter a valid Email Adress';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text("Password"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 8) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userPass = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("User Name"),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Please enter a valid User Name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userName = value!;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(label: Text("Phone Number")),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 11) {
                      return 'Please enter a valid mobile phone';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userMobile = int.parse(value!);
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _userRole,
                  items: ['Student', 'Manager', 'Teacher']
                      .mapIndexed((index, value) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _userRole = value!;
                    });
                  },
                  onSaved: (value) {
                    _userRole = value!;
                  },
                ),
                if (_userRole == 0)
                  DropdownButtonFormField<int>(
                    value: 12,
                    items: [
                      'Grade 12',
                      'Grade 11',
                      'Grade 10',
                      'Grade 09',
                      'Grade 08',
                      'Grade 07',
                      'Grade 06',
                    ].map((grade) {
                      return DropdownMenuItem<int>(
                        value: int.parse(grade.substring(grade.length - 2)),
                        child: Text(grade),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _userGrade = value!;
                      });
                    },
                    onSaved: (value) {
                      _userGrade = value!;
                    },
                  ),
                const SizedBox(
                  height: 30.0,
                ),
                if (!_isLoading)
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _createUser();
                      }
                    },
                    child: const Text("Create User"),
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
    );
  }
}
