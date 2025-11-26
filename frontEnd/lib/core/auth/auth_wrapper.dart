// lib/core/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firebase_service.dart';

/// Wrapper widget that handles authentication state
/// Automatically signs in anonymously if no user is authenticated
class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ensureAuthenticated();
  }

  Future<void> _ensureAuthenticated() async {
    try {
      await FirebaseService.instance.ensureAuthenticated();
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticating) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Authenticating...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Authentication Error'),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isAuthenticating = true;
                    _error = null;
                  });
                  _ensureAuthenticated();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Listen to auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseService.instance.auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated, show the app
        return widget.child;
      },
    );
  }
}
