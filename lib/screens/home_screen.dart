import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_live_score_app/models/football_match.dart';
import 'package:firebase_live_score_app/screens/add_and_update_match_screen.dart';
import 'package:firebase_live_score_app/utils/show_snackbar_message.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ///In this approach data can only come at once without refresh data does not update
  ///for auto data update we need to use Stream builder
  /*List<FootballMatch> footballMatchList = [];

  bool _isFootballMatchInProgress = false;

  @override
  void initState() {
    super.initState();
    _getFootballMatches();
  }

  Future<void> _getFootballMatches() async {
    _isFootballMatchInProgress = true;
    setState(() {});

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('football')
        .get();

    for (DocumentSnapshot doc in querySnapshot.docs) {
      footballMatchList.add(
        FootballMatch.fromJson(doc.id, doc.data() as Map<String, dynamic>),
      );
    }

    _isFootballMatchInProgress = false;
    setState(() {});
  }*/

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setUserId(
      id: FirebaseAuth.instance.currentUser?.uid,
    );
    /*NotificationService.instance.showNotification(
      id: 1,
      title: "Hello",
      body: "Welcome! to ths Live Score App",
    );*/
    FirebaseAnalytics.instance.logEvent(name: "Home Screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: Colors.white),
          ),
          IconButton(
            onPressed: _onLogoutPressed,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("football").snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == .waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text(asyncSnapshot.error.toString()));
          }

          List<FootballMatch> footballMatchList = [];

          for (DocumentSnapshot doc in asyncSnapshot.data!.docs) {
            footballMatchList.add(
              FootballMatch.fromJson(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              itemBuilder: (context, index) {
                var footballMatch = footballMatchList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddAndUpdateMatchScreen(matchId: footballMatch.id),
                      ),
                    );
                  },
                  child: Dismissible(
                    key: Key(footballMatch.id),
                    onDismissed: (_) {
                      _onDismissed(footballMatch.id);
                    },
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 8,
                          backgroundColor: footballMatch.isRunning
                              ? Colors.green
                              : Colors.grey,
                        ),
                        title: Text(
                          "${footballMatch.team1Name} vs ${footballMatch.team2Name}",
                        ),
                        subtitle: Text(
                          footballMatch.isRunning
                              ? "Match in progress..."
                              : "Winner Team: ${footballMatch.winnerTeam}",
                        ),
                        trailing: Text(
                          "${footballMatch.team1Score} - ${footballMatch.team2Score}",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemCount: footballMatchList.length,
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onTabAddNewMatch,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  void _onTabAddNewMatch() {
    /*FootballMatch footballMatch = FootballMatch(
      id: "portvscro",
      team1Name: "Portugal",
      team2Name: "Croatia",
      team1Score: 1,
      team2Score: 1,
      winnerTeam: "Draw",
      isRunning: true,
    );*/

    ///In the following approach we set a id for each document manually.
    ///So that we can use set method but it is not possible everytime
    ///But firebase has a solution.Firebase can generate a unique id everytime
    ///If we did not give any id manually.For this we can not use set method.
    ///For this we need to use add method.which is use below
    /*FirebaseFirestore.instance
        .collection('football')
        .doc(footballMatch.id)
        .set(footballMatch.toJson());*/

    ///To send the data to the server we need to convert our object to a json data
    ///For that we convert the object into json object which is in FootballMatch class

    /*FirebaseFirestore.instance
        .collection('football')
        .add(footballMatch.toJson());*/

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAndUpdateMatchScreen(matchId: ""),
      ),
    );
  }

  void _onDismissed(String docId) {
    FirebaseAnalytics.instance.logEvent(name: "Deleted match");
    FirebaseFirestore.instance.collection('football').doc(docId).delete();
  }

  Future<void> _onLogoutPressed() async {
    FirebaseCrashlytics.instance.log("on tap logout button on home screen");

    ///throw Exception("My custom exception");
    try {
      await FirebaseAuth.instance.signOut();
      showSnackBarMessage(context, "Logout success");
    } on FirebaseException catch (e) {
      showSnackBarMessage(context, e.message ?? "Something went wrong");
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }
}
