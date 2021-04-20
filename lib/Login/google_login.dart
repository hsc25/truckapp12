import 'dart:async';
import 'dart:io' show Platform;

import 'package:Fluttergram/Login/create_account.dart';
import 'package:Fluttergram/Login/login.dart';
import 'package:Fluttergram/Login/navigation_page.dart';
import 'package:Fluttergram/main.dart'; //for current user
import 'package:Fluttergram/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class GoogleLoginPage extends StatefulWidget {
  @override
  State createState() => _GoogleLogin();
}

class _GoogleLogin extends State<GoogleLoginPage> {
/*  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return googlelogin();
  }*/

  googlelogin() async {
    BuildContext context;
    await _ensureLoggedIn(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  bool triedSilentLogin = false;
  bool setupNotifications = false;

  @override
  Widget build(BuildContext context) {
    googlelogin(); //This function is inside of build that's why signinng each time.
    if (triedSilentLogin == false) {
      silentLogin(context);
    }
    if (setupNotifications == false && currentUserModel != null) {
      setUpNotifications();
    }
    return (googleSignIn.currentUser == null || currentUserModel == null)
        ? HomePage()
        : Navigation();
  }

  Future<Null> _ensureLoggedIn(BuildContext context) async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      user = await googleSignIn.signInSilently();
    }
    if (user == null) {
      await googleSignIn.signIn();
      await tryCreateUserRecord(context);
    }

    if (await auth.currentUser() == null) {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await auth.signInWithCredential(credential);
    }
  }

  Future<Null> _silentLogin(BuildContext context) async {
    GoogleSignInAccount user = googleSignIn.currentUser;

    if (user == null) {
      user = await googleSignIn.signInSilently();
      await tryCreateUserRecord(context);
    }

    if (await auth.currentUser() == null && user != null) {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
    }
  }

  void silentLogin(BuildContext context) async {
    await _silentLogin(context);
    setState(() {
      triedSilentLogin = true;
    });
  }

  void setUpNotifications() {
    _setUpNotifications();
    setState(() {
      setupNotifications = true;
    });
  }

  Future<Null> _setUpNotifications() async {
    if (Platform.isAndroid) {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
        },
      );

      _firebaseMessaging.getToken().then((token) {
        print("Firebase Messaging Token: " + token);

        Firestore.instance
            .collection("insta_users")
            .document(currentUserModel.id)
            .updateData({"androidNotificationToken": token});
      });
    }
  }
}

//creating user record in firebase
Future<void> tryCreateUserRecord(BuildContext context) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    return null;
  }
  DocumentSnapshot userRecord = await ref.document(user.id).get();
  if (userRecord.data == null) {
    // no user record exists, time to create

    String userName = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Center(
                child: Scaffold(
                    appBar: AppBar(
                      leading: Container(),
                      title: Text('Fill out missing data',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white,
                    ),
                    body: ListView(
                      children: <Widget>[
                        Container(
                          child: CreateAccount(),
                        ),
                      ],
                    )),
              )),
    );

    if (userName != null || userName.length != 0) {
      ref.document(user.id).setData({
        "id": user.id,
        "username": userName,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "followers": {},
        "following": {
          user.id: true
        }, // add current user so they can see their own posts in feed,
      });
    }
    userRecord = await ref.document(user.id).get();
  }
  currentUserModel = User.fromDocument(userRecord);
  return null;
}
