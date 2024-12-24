import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal.health.manager/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:personal.health.manager/screens/health_tracker_screen.dart';
import 'package:personal.health.manager/screens/chat_screen.dart';
import 'package:personal.health.manager/utils/color_utils.dart';
import 'package:personal.health.manager/reusable_widgets/reusable_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
   _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Màu sắc chính cho nút bấm
  final Color buttonColor = Colors.white.withOpacity(0.8);
  final Color buttonTextColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Đảm bảo nội dung không bị che khuất
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringToColor("CB2B93"),
                hexStringToColor("9546C4"),
                hexStringToColor("5E61F4")
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Thêm padding cho nội dung
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo giữ nguyên, không thay đổi
                logoWidget("assets/health.png"),
                const SizedBox(height: 40),

                // Các nút chức năng được bọc trong Column với kiểu dáng cải tiến
                _buildHomeButton(
                  icon: Icons.fitness_center,
                  label: 'Health Tracker',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HealthTrackerScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildHomeButton(
                  icon: Icons.chat,
                  label: 'Chat For Advice',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildHomeButton(
                  icon: Icons.logout,
                  label: 'Logout',
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      print("Signed Out");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ); 
  }

  // Hàm xây dựng nút bấm cho HomeScreen
  Widget _buildHomeButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, // Đảm bảo nút rộng đủ
      height: 60, // Chiều cao nút
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28, color: buttonTextColor),
        label: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: buttonTextColor),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: buttonTextColor, backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Bo góc nút
          ),
          elevation: 5,
          side: BorderSide(color: Colors.white, width: 1), // Viền nút
        ),
      ),
    );
  }
}
