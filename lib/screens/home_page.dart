import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'travel_input_page.dart';
import 'check_weather_page.dart';
import 'best_time_page.dart';
import 'explore.dart';
import 'login_page.dart';
import 'profile_page.dart'; // Import ProfilePage to navigate to the profile page

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text(
              'Logout',
              style: TextStyle(color: const Color.fromARGB(255, 6, 5, 5)),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelInputPage(),
                      ),
                    );
                  },
                  child: Text('Travel Suggestor'),
                  style: _buttonStyle(),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckWeatherPage(),
                      ),
                    );
                  },
                  child: Text('Check Weather'),
                  style: _buttonStyle(),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BestTimeToTravelPage(),
                      ),
                    );
                  },
                  child: Text('Best Time to Travel'),
                  style: _buttonStyle(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExplorePage()),
                    );
                  },
                  child: Text('Explore'),
                  style: _buttonStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.lightBlueAccent,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      textStyle: TextStyle(color: Colors.white, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
