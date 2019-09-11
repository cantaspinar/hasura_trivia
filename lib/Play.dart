import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hasura_trivia/Result.dart';
import 'package:hasura_trivia/main.dart';

class Play extends StatelessWidget {
  final FirebaseUser user;

  const Play({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var consumer = GraphQLProvider.of(context);
    var client = consumer.value;
    addAnswer(
      String questionID,
      String answerID,
    ) async {
      String addAnswer = """
      mutation addAnswer(\$questionID: uuid!, \$answerID: uuid!, \$userID: String!) {
        insert_user_answers(objects: {question_id: \$questionID, answer_id: \$answerID}) {
            affected_rows
        }
      }
      """;
      final MutationOptions options = MutationOptions(
        document: addAnswer,
        variables: <String, dynamic>{
          'questionID': questionID,
          'answerID': answerID,
          'userID': user.uid,
        },
      );
      final QueryResult result = await client.mutate(options);
      if (result.hasErrors) {
        print(result.errors);
      } else {}
    }

    String getQuestion = """
    query GetQuestion(\$userID: String!) {
      unanswered_questions(args: {userid: \$userID}, limit: 1) {
        id
        question
        question_answers {
          id
          answer
          is_correct
        }
      }
    }
    """;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 244, 194, 87),
        leading: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Menu(
                  user: user,
                ),
              ),
            );
          },
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Color.fromARGB(255, 244, 194, 87),
        child: Query(
          options: QueryOptions(
            fetchPolicy: FetchPolicy.networkOnly,
            document: getQuestion,
            variables: {
              'userID': user.uid,
            },
          ),
          builder: (QueryResult result, {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.errors != null) {
              return Center(child: Text(result.errors.toString()));
            }

            if (result.loading) {
              return Center(child: CircularProgressIndicator());
            }

            List questions = result.data['unanswered_questions'];

            if (questions.isEmpty) {
              return Center(
                child: Text("You have answered all questions!",
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              );
            }

            var question = result.data['unanswered_questions'][0];
            List<Widget> answers = [];
            String correctAnswer = "";
            for (var answer in question["question_answers"]) {
              if (answer["is_correct"]) {
                correctAnswer = answer["answer"];
              }
              answers.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: RaisedButton(
                        color: Colors.red,
                        child: Text(answer["answer"],
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () async {
                          await addAnswer(question["id"], answer["id"]);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Result(
                                user: user,
                                correctAnswer: correctAnswer,
                                isCorrect: answer["is_correct"],
                              ),
                            ),
                          );
                        })),
              ));
            }
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        height: 300.0,
                        width: double.infinity,
                        color: Colors.deepPurple,
                        child: Center(
                          child: Text(
                            question["question"],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...answers
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
