import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Scores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String fetchScores = """
    subscription fetchScores {
      users(order_by: {score: desc}) {
        name
        score
      }
    }
    """;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 244, 194, 87),
          title: Text("Scores")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromARGB(255, 244, 194, 87),
        child: Subscription(
          "fetchScores",
          fetchScores,
          builder: ({
            bool loading,
            dynamic payload,
            dynamic error,
          }) {
            if (payload != null) {
              List users = payload["users"];
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(
                          padding: EdgeInsets.all(8),
                          width: double.infinity,
                          color: Colors.red,
                          child: ListTile(
                            title: Text(
                              user["name"],
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Text(user["score"].toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          )),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
