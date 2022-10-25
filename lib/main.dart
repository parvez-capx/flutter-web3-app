// ignore_for_file: avoid_print

import 'dart:collection';
// ignore: unused_import
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'dart:async';

import 'package:web3auth_flutter/web3auth_flutter.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  bool logoutVisible = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    HashMap themeMap = HashMap<String, String>();
    themeMap['primary'] = "#229954";

    final loginConfig = HashMap<String, LoginConfigItem>();
    loginConfig['jwt'] = LoginConfigItem(
        verifier: "google-x-verifier", // get it from web3auth dashboard
        typeOfLogin: TypeOfLogin.jwt,
        name: "Custom JWT Login",
        clientId: "capx-x-web3auth" // web3auth's plug and play client id
        );

    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl = Uri.parse('w3a://com.example.practice/auth');
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('com.example.practice://openlogin');
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId:
            'BKLOSPXdm5WN_6eijPsg2DhasXUV0ZCiSihcjeurL1VsJ1J52tAaE1E2AeC0E1c0Wibl6WIl4lLogkawBeafxqQ',
        network: Network.mainnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(
            dark: true, name: "Web3Auth Flutter App", theme: themeMap),
        loginConfig: loginConfig));
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> user = jsonDecode(_result);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DApp'),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              Visibility(
                visible: !logoutVisible,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Connect',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Color(0xFF0364ff)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Welcome to DApp',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Login with',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: _login(_withDappShare),
                        child: const Text('with D')),
                    ElevatedButton(
                        onPressed: _login(_withoutDappShare),
                        child: const Text('without D')),
                  ],
                ),
              ),
              Visibility(
                // ignore: sort_child_properties_last
                child: Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red[600] // This is what you need!
                              ),
                          onPressed: _logout(),
                          child: Column(
                            children: const [
                              Text('Logout'),
                            ],
                          )),
                    ),
                  ],
                ),
                visible: logoutVisible,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_result),
              )
            ],
          )),
        ),
      ),
    );
  }

  VoidCallback _login(Future<Web3AuthResponse> Function() method) {
    return () async {
      try {
        final Web3AuthResponse response = await method();
        print(response.userInfo);
        setState(() {
          _result = response.toString();
          logoutVisible = true;
        });
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  VoidCallback _logout() {
    return () async {
      try {
        setState(() {
          _result = '';
          logoutVisible = false;
        });
        await Web3AuthFlutter.logout();
      } on UserCancelledException {
        print("User cancelled.");
      } on UnKnownException {
        print("Unknown exception occurred");
      }
    };
  }

  Future<Web3AuthResponse> _withDappShare() {
    return Web3AuthFlutter.login(
        LoginParams(loginProvider: Provider.jwt, mfaLevel: MFALevel.DEFAULT));
  }

  Future<Web3AuthResponse> _withoutDappShare() {
    return Web3AuthFlutter.login(
        LoginParams(loginProvider: Provider.jwt, mfaLevel: MFALevel.MANDATORY));
  }
}
