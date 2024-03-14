// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Home extends StatefulWidget {
  final String username;

  const Home({Key? key, required this.username}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<StepCount> _stepCountStream;
  late String _steps = "";
  late String _password = "";

  @override
  void initState() {
    print("initState");
    super.initState();
    initPlatformState();
    _fetchUserProfile();
  }

  void onStepCount(StepCount event) {
    print("onStepCount");
    print(event);
    setState(() {
      _steps = event.steps.toString();
      _updateFirestore();
    });
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count';
    });
  }

  void initPlatformState() {
    print("initPlatformState");
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  void _updateFirestore() {
    print("_updateFirestore");
    FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.username)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .update({'steps': _steps})
            .then((value) => print('Steps updated in Firestore'))
            .catchError((error) => print('Failed to update steps: $error'));
      } else {
        print('No document found for username: ${widget.username}');
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((error) => print('Failed to update steps: $error'));
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final userData = userDocs.docs.first.data();
        setState(() {
          _password = userData['password'] ?? 'N/A';
          _steps = userData['steps'].toString();
        });
      } else {
        print('No user found with username: ${widget.username}');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  // Future<void> _changePassword(String newPassword) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(widget.username)
  //         .update({'password': newPassword});
  //     setState(() {
  //       _password = newPassword;
  //     });
  //   } catch (error) {
  //     print('Error changing password: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Pedometer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_selectedIndex == 0)
                CircularPercentIndicator(
                  animation: true,
                  animationDuration: 1000,
                  radius: screenWidth * 0.25,
                  lineWidth: 10.0,
                  percent: double.parse(_steps)/5000.0,
                  // header: const Text("Steps Count"),
                  center: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Image(
                        image: const AssetImage("assets/images/footsteps.png"),
                        width: screenWidth * 0.25,
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Text(
                        _steps,
                        style: TextStyle(
                            color: Colors.black, fontSize: screenWidth * 0.05),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey,
                  progressColor: Colors.redAccent,
                ),
              if (_selectedIndex == 1)
                SizedBox(
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Image(
                        image: const AssetImage("assets/images/podium.png"),
                        height: screenHeight * 0.2,
                        width: screenWidth,
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      SizedBox(
                        height: screenHeight,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final users = snapshot.data!.docs;
                            users.sort(
                                (a, b) => b['steps'].compareTo(a['steps']));

                            return ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    child: Text("${index + 1}"),
                                  ),
                                  title: Text(
                                    user['username'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Steps: ${user['steps']}'),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              if (_selectedIndex == 2)
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username: ${widget.username}',
                        style: TextStyle(
                            fontSize: screenWidth * 0.05, color: Colors.black),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Text(
                        'Password: $_password',
                        style: TextStyle(
                            fontSize: screenWidth * 0.05, color: Colors.black),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Text(
                        'Steps Count: $_steps',
                        style: TextStyle(
                            fontSize: screenWidth * 0.05, color: Colors.black),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop((context) {
                            });
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.075),
                          ))
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    ));
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
