import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as material show Text;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';

import 'device_identity_service.dart';
import 'firebase_options.dart';
import 'startup/connection_probe.dart';
import 'startup/connection_probe_factory.dart';
import 'ticket_image_cropper.dart';
import 'ticket_image_picker_service.dart';
import 'theme/tm_tokens.dart';

part 'app/app_core.dart';
part 'app/auth_flow.dart';
part 'app/editable_text.dart';
part 'app/home_shell.dart';
part 'app/local_persistence.dart';
part 'app/tickets_flow.dart';

const _ticketmasterSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.black,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarDividerColor: Colors.transparent,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarContrastEnforced: false,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(_ticketmasterSystemUiStyle);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Android Google Sign-In needs the "Web client (auto created for Google
  // Sign-In)" id as the serverClientId. In google-services.json this is the
  // oauth_client entry with client_type 3 (the plugin emits
  // `default_web_client_id` from it); it is supplied explicitly here for
  // reliability. Value: Firebase console → Auth → Sign-in method → Google →
  // Web client ID.
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '876939743947-6ulpldpnou4uuteid7vlnlribqihge8f.apps.googleusercontent.com',
  );
  await _TicketmasterCloudStore.instance.initialize();
  runApp(const TicketmasterApp());
}
