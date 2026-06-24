import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_live_score_app/models/football_match.dart';
import 'package:firebase_live_score_app/screens/home_screen.dart';
import 'package:firebase_live_score_app/utils/show_snackbar_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNewMatch extends StatefulWidget {
  final String matchId;

  const AddNewMatch({super.key, required this.matchId});

  @override
  State<AddNewMatch> createState() => _AddNewMatchState();
}

class _AddNewMatchState extends State<AddNewMatch> {
  final TextEditingController _team1NameTEController = TextEditingController();
  final TextEditingController _team2NameTEController = TextEditingController();
  final TextEditingController _team1ScoreTEController = TextEditingController();
  final TextEditingController _team2ScoreTEController = TextEditingController();
  final TextEditingController _winnerTeamTEController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? selectedIsRunning;
  bool isAddedInProgress = false;
  late bool hasMatchId;

  @override
  void initState() {
    super.initState();
    hasMatchId = widget.matchId.isNotEmpty;
    if (hasMatchId) {
      _getMatchDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(hasMatchId ? "Update Match" : "Add Match"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12,
            children: [
              Text(
                hasMatchId ? "Update Match Details" : "Create a New Match",
                style: GoogleFonts.roboto(fontSize: 20),
              ),

              ///Team1 Name
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _team1NameTEController,
                decoration: InputDecoration(
                  hintText: "Enter Team1 Name",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Must enter team1 name";
                  }
                  return null;
                },
              ),

              ///Team2 Name
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _team2NameTEController,
                decoration: InputDecoration(
                  hintText: "Enter Team2 Name",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Must enter team2 name";
                  }
                  return null;
                },
              ),

              ///Team1 Score
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _team1ScoreTEController,
                decoration: InputDecoration(
                  hintText: "Enter Team1 Score",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Must enter team1 score";
                  }

                  if (int.tryParse(value) == null) {
                    return "Enter valid number";
                  }

                  return null;
                },
              ),

              ///Team2 Score
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _team2ScoreTEController,
                decoration: InputDecoration(
                  hintText: "Enter Team2 Score",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Must enter team2 score";
                  }

                  if (int.tryParse(value) == null) {
                    return "Enter valid number";
                  }

                  return null;
                },
              ),

              ///Winning Team
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _winnerTeamTEController,
                decoration: InputDecoration(
                  hintText: "Enter winner Name",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              ///IsRunningStatus
              DropdownButtonFormField<bool>(
                initialValue: selectedIsRunning,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: true, child: Text('Running')),
                  DropdownMenuItem(value: false, child: Text('Finished')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedIsRunning = value;
                  });
                },
              ),

              Visibility(
                visible: isAddedInProgress == false,
                replacement: Center(child: CircularProgressIndicator()),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: hasMatchId ? _onTapMatchUpdate : _onTapAddMatch,
                  child: Text(
                    hasMatchId ? "Save Changes" : "Create Match",
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTapAddMatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedIsRunning == null) {
      showSnackBarMessage(context, "Please select match status");
      return;
    }

    setState(() {
      isAddedInProgress = true;
    });

    String team1Name = _team1NameTEController.text.trim();
    String team2Name = _team2NameTEController.text.trim();
    int team1Score = int.tryParse(_team1ScoreTEController.text.trim()) ?? 0;
    int team2Score = int.tryParse(_team2ScoreTEController.text.trim()) ?? 0;
    String? winnerTeam = _winnerTeamTEController.text.trim().isEmpty
        ? ""
        : _winnerTeamTEController.text.trim();

    FootballMatch footballMatch = FootballMatch(
      id: "${team1Name.substring(0, 3)}vs${team2Name.substring(0, 3)}${DateTime.now().millisecondsSinceEpoch.toString()}",
      team1Name: team1Name,
      team2Name: team2Name,
      team1Score: team1Score,
      team2Score: team2Score,
      winnerTeam: winnerTeam,
      isRunning: selectedIsRunning ?? true,
    );
    try {
      await FirebaseFirestore.instance
          .collection('football')
          .doc(footballMatch.id)
          .set(footballMatch.toJson());

      showSnackBarMessage(context, "Match added Successful");
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      showSnackBarMessage(context, e.message ?? "Something Went wrong");
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isAddedInProgress = false;
      });
    }
  }

  Future<void> _onTapMatchUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedIsRunning == null) {
      showSnackBarMessage(context, "Please select match status");
      return;
    }

    setState(() {
      isAddedInProgress = true;
    });

    String team1Name = _team1NameTEController.text.trim();
    String team2Name = _team2NameTEController.text.trim();
    int team1Score = int.tryParse(_team1ScoreTEController.text.trim()) ?? 0;
    int team2Score = int.tryParse(_team2ScoreTEController.text.trim()) ?? 0;
    String? winnerTeam = _winnerTeamTEController.text.trim().isEmpty
        ? ""
        : _winnerTeamTEController.text.trim();

    FootballMatch footballMatch = FootballMatch(
      id: widget.matchId,
      team1Name: team1Name,
      team2Name: team2Name,
      team1Score: team1Score,
      team2Score: team2Score,
      winnerTeam: winnerTeam,
      isRunning: selectedIsRunning ?? true,
    );
    try {
      await FirebaseFirestore.instance
          .collection('football')
          .doc(footballMatch.id)
          .update(footballMatch.toJson());

      showSnackBarMessage(context, "Match Updated Successful");
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      showSnackBarMessage(context, e.message ?? "Something Went wrong");
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isAddedInProgress = false;
      });
    }
  }

  Future<void> _getMatchDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('football')
          .doc(widget.matchId)
          .get();

      if (snapshot.exists) {
        FootballMatch footballMatch = FootballMatch.fromJson(
          snapshot.id,
          snapshot.data()!,
        );

        _team1NameTEController.text = footballMatch.team1Name;
        _team2NameTEController.text = footballMatch.team2Name;
        _team1ScoreTEController.text = footballMatch.team1Score.toString();
        _team2ScoreTEController.text = footballMatch.team2Score.toString();
        _winnerTeamTEController.text = footballMatch.winnerTeam ?? "";

        setState(() {
          selectedIsRunning = footballMatch.isRunning;
        });
      }
    } on FirebaseException catch (e) {
      debugPrint(e.message);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  void onSelectedTapIsRunning(bool? isRunning) {
    setState(() {
      selectedIsRunning = isRunning;
    });
  }

  @override
  void dispose() {
    _team1NameTEController.dispose();
    _team2NameTEController.dispose();
    _team1ScoreTEController.dispose();
    _team2ScoreTEController.dispose();
    _winnerTeamTEController.dispose();
    super.dispose();
  }
}
