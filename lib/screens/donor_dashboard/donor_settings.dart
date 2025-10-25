
import 'package:blood_donation_app_full/screens/auth/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// =================== Settings Screen ===================
class DonorSettingsScreen extends ConsumerWidget {
  const DonorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection("Account", [
            _buildCard(
              context: context,
              icon: Icons.account_circle,
              title: "Account",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonorAccountScreen()),
                );
              },
            ),
          ]),

          
          _buildSection("Help & Support", [
            // _buildCard(
            //   context: context,
            //   icon: Icons.question_answer,
            //   title: "FAQs",
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const DonorFAQScreen()),
            //     );
            //   },
            // ),
            // _buildCard(
            //   context: context,
            //   icon: Icons.info_outline,
            //   title: "App Usage",
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const DonorAppUsageScreen(),
            //       ),
            //     );
            //   },
            // ),
            _buildCard(
              context: context,
              icon: Icons.support_agent,
              title: "Contact Support",
              onTap: () => _contactSupport(context),
            ),
          ]),

          _buildSection("Privacy & Legal", [
            _buildCard(
              context: context,
              icon: Icons.privacy_tip,
              title: "Privacy Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DonorPrivacyTermsScreen(isPrivacy: true),
                  ),
                );
              },
            ),
            _buildCard(
              context: context,
              icon: Icons.article,
              title: "Terms & Conditions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DonorPrivacyTermsScreen(isPrivacy: false),
                  ),
                );
              },
            ),
          ]),

          _buildSection("About", [
            _buildCard(
              context: context,
              icon: Icons.info,
              title: "About App",
              //subtitle: "Developed by Talha Shams 🧠 Flutter Developer",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonorAboutScreen()),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  // ===== Helper: Build Section =====
  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // ===== Helper: Build Card =====
  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  
  // ===== Helper: Contact Support =====
  Future<void> _contactSupport(BuildContext context) async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'talhashamsdev101@gmail.com',
      query: 'subject=App Support - Blood Donation App',
    );
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open email app")));
    }
  }
}

// =================== Account Screen ===================
class DonorAccountScreen extends StatefulWidget {
  const DonorAccountScreen({super.key});

  @override
  State<DonorAccountScreen> createState() => _DonorAccountScreenState();
}

class _DonorAccountScreenState extends State<DonorAccountScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // ----- Change password (requires old password to re-authenticate) -----
  Future<void> _changePassword() async {
    final TextEditingController oldPass = TextEditingController();
    final TextEditingController newPass = TextEditingController();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text("Change Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Enter current password",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Enter new password",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  oldPass.dispose();
                  newPass.dispose();
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        final oldP = oldPass.text.trim();
                        final newP = newPass.text.trim();

                        if (oldP.isEmpty || newP.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill both password fields"),
                            ),
                          );
                          return;
                        }
                        if (newP.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password must be at least 6 characters",
                              ),
                            ),
                          );
                          return;
                        }

                        setStateDialog(() => loading = true);

                        try {
                          // Re-authenticate
                          final cred = EmailAuthProvider.credential(
                            email: user!.email!,
                            password: oldP,
                          );
                          await user!.reauthenticateWithCredential(cred);

                          // Update password
                          await user!.updatePassword(newP);

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password updated successfully"),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String message = e.message ?? 'Error';
                          if (e.code == 'wrong-password') {
                            message = 'Current password is incorrect';
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          setStateDialog(() => loading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Change"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ----- Forgot password (send reset email) -----
  Future<void> _forgotPassword() async {
    final email = user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email found for this account")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Reset Password"),
        content: Text(
          "A password reset email will be sent to $email. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Send"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  // ----- Sign out and navigate to LoginScreen -----
  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ----- Delete account (requires re-auth + confirm) -----
  Future<void> _deleteAccount() async {
    if (user == null) return;
    final TextEditingController passwordController = TextEditingController();
    bool loading = false;

    // Step 1: Re-auth dialog to get password
    final reauthOk = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text("Confirm Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter your current password to delete your account.",
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Current password",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        final pw = passwordController.text.trim();
                        if (pw.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your password"),
                            ),
                          );
                          return;
                        }
                        setStateDialog(() => loading = true);
                        try {
                          final cred = EmailAuthProvider.credential(
                            email: user!.email!,
                            password: pw,
                          );
                          await user!.reauthenticateWithCredential(cred);
                          Navigator.pop(context, true);
                        } on FirebaseAuthException catch (e) {
                          String msg = e.message ?? 'Error';
                          if (e.code == 'wrong-password')
                            msg = 'Password is incorrect';
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                          setStateDialog(() => loading = false);
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                          setStateDialog(() => loading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Confirm"),
              ),
            ],
          );
        },
      ),
    );

    if (reauthOk != true) return;

    // Step 2: Confirm deletion
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Delete Account"),
        content: const Text(
          "This will permanently delete your account and data. This action cannot be undone. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    // Step 3: Delete Firestore doc & Firebase account
    try {
      final uid = user!.uid;
      // Delete Firestore user doc if exists
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .delete()
          .catchError((_) {});
      // Delete Firebase account
      await user!.delete();

      // sign out & navigate to login
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Error deleting account';
      // If account requires recent login, tell the user
      if (e.code == 'requires-recent-login') {
        message = 'Please re-login recently and try again.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? "No Email Found";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.redAccent),
              title: const Text("Email"),
              subtitle: Text(email),
            ),
          ),
          const SizedBox(height: 10),

          // Change password (reauth required)
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.redAccent),
              title: const Text("Change Password"),
              onTap: _changePassword,
            ),
          ),
          const SizedBox(height: 10),

          // Forgot password (send reset email)
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: Colors.redAccent,
              ),
              title: const Text("Forgot Password"),
              subtitle: Text("Send reset link to $email"),
              onTap: _forgotPassword,
            ),
          ),
          const SizedBox(height: 10),

          // Delete account
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              title: const Text("Delete Account"),
              subtitle: const Text("Permanently delete your account and data"),
              onTap: _deleteAccount,
            ),
          ),
          const SizedBox(height: 10),

          // Sign out
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Sign Out"),
              onTap: _signOut,
            ),
          ),
        ],
      ),
    );
  }
}


// =================== About Screen ===================
class DonorAboutScreen extends StatelessWidget {
  const DonorAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Blood Donation App",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 10),
            Text(
             '''  

The Blood Donation App is a community-driven platform designed to bridge the gap between blood donors and those in need.  
Our mission is to make finding and donating blood simple, fast, and reliable.

Built with ❤ using Flutter and Firebase.  
Together, we can save lives — one donation at a time.

Developed by: Talha Shams
''',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== FAQs, App Usage, Privacy Terms (remain same) ===================
// class DonorFAQScreen extends StatelessWidget {
//   const DonorFAQScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final faqs = [
//       {
//         "q": "How to request blood?",
//         "a":
//             "Go to the Request tab and fill the form with all required details.",
//       },
//       {
//         "q": "How to become a donor?",
//         "a": "Sign up as a donor and make sure your profile is active.",
//       },
//       {
//         "q": "How to contact support?",
//         "a": "Use the Contact Support option in the Settings screen.",
//       },
//     ];

//     return Scaffold(
//       appBar: AppBar(title: const Text("FAQs")),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: faqs.length,
//         itemBuilder: (context, index) => Card(
//           color: Theme.of(context).cardColor,
//           child: ListTile(
//             title: Text(faqs[index]["q"]!),
//             subtitle: Text(faqs[index]["a"]!),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DonorAppUsageScreen extends StatelessWidget {
//   const DonorAppUsageScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("How to Use App")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Text(
//           "1️⃣ Sign up and select your role.\n\n"
//           "2️⃣ Donors can manage availability and view nearby requests.\n\n"
//           "3️⃣ Users can request blood with full details.\n\n"
//           "4️⃣ Hospitals can post urgent requests.\n\n"
//           "5️⃣ Use Settings for theme, password, and support options.",
//           style: const TextStyle(fontSize: 16, height: 1.5),
//         ),
//       ),
//     );
//   }
// }

class DonorPrivacyTermsScreen extends StatelessWidget {
  final bool isPrivacy;
  const DonorPrivacyTermsScreen({super.key, required this.isPrivacy});

  @override
  Widget build(BuildContext context) {
    final title = isPrivacy ? "Privacy Policy" : "Terms & Conditions";
    final text = isPrivacy
        ? '''
Privacy Policy  

Thank you for using our Blood Donation App (“we”, “our”, or “us”).
Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information.

1. Information We Collect  
• Personal Information: Name, email, phone number, city, blood group, and account type (donor or user).  
• Usage Data: General app usage data to improve experience.  

2. How We Use Your Information  
• To display your donor or user profile.  
• To manage blood requests and donations.  
• To improve app functionality and communication.

3. Data Security  
Your data is securely stored using Firebase. However, we recommend keeping your login credentials private.

4. Sharing of Information  
We do not sell or share your data with third parties. Only essential info (like name, city, and blood group) may appear to connect donors and recipients.

5. Your Rights  
You can update or delete your information anytime from your profile.

6. Contact Us  
📧 talhashamsdev101@gmail.com
        '''
        : '''
Terms & Conditions  

Welcome to our Blood Donation App. By using this app, you agree to the following terms:

1. User Responsibilities  
• Provide accurate personal information.  
• Donors must ensure they are medically fit to donate.  
• Users must not post fake or misleading requests.

2. App Usage  
• The app is for humanitarian purposes only.  
• Any commercial or abusive use is strictly prohibited.

3. Data & Privacy  
Your data is used only to connect donors and recipients. Please review our Privacy Policy for details.

4. Liability  
We serve as a platform only. We are not responsible for actions or outcomes after contact between users.

5. Account Termination  
We may suspend or remove accounts involved in fake or unethical activity.

6. Updates to Terms  
These terms may change over time. Continued use means you accept updated terms.

Thank you for using our app to help save lives!
        ''';

    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(text, style: const TextStyle(fontSize: 16,
                height: 1.6,
                color: Colors.white,)),
        ),
      ),
    );
  }
}
