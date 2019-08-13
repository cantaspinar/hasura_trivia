import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hasura_trivia/Play.dart';

class Result extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final FirebaseUser user;

  const Result({Key key, this.isCorrect, this.correctAnswer, this.user})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: isCorrect ? Colors.green : Colors.red,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(isCorrect ? "Correct +10 Points" : "Wrong",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Answer is: " + correctAnswer,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            SizedBox(
              width: 200,
              child: RaisedButton(
                color: Colors.deepPurple,
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Play(
                        user: user,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
