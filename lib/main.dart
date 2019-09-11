import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hasura_trivia/Login.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hasura_trivia/Scores.dart';

import 'Play.dart';

void main() => runApp(AuthCheck());

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;
  String token;
  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  Future<FirebaseUser> checkCurrentUser() async {
    try {
      user = await _firebaseAuth.currentUser();
      IdTokenResult tokenResult = await user.getIdToken();
      token = tokenResult.token;
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      home: FutureBuilder<FirebaseUser>(
        future: checkCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Scaffold(
                body: Container(
                  color: Color.fromARGB(255, 244, 194, 87),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            case ConnectionState.done:
              if (snapshot.data != null)
                return MainApp(
                  token: token,
                  user: user,
                );
              return Login();
          }
          return null;
        },
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  final FirebaseUser user;
  final token;

  const MainApp({Key key, this.token, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      uri: '<your-hasura-endpoint>',
    );

    final WebSocketLink websocketLink = WebSocketLink(
      url: '<your-hasura-endpoint>',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer ' + token,
    );

    final Link link = authLink.concat(httpLink as Link).concat(websocketLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: link,
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.red),
        home: Menu(
          user: user,
        ),
      ),
    );
  }
}

class Menu extends StatelessWidget {
  final FirebaseUser user;

  const Menu({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        color: Color.fromARGB(255, 244, 194, 87),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage("images/hasura-community.png"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                "Hasura Trivia",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 200,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      user.displayName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        splashColor: Colors.white,
                        highlightColor: Colors.transparent,
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          print("Logout");
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                      ),
                    )
                  ]),
            ),
            SizedBox(
              width: 200,
              child: RaisedButton(
                color: Colors.red,
                child: Text("Play",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
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
            ),
            SizedBox(
              width: 200,
              child: RaisedButton(
                color: Colors.red,
                child: Text(
                  "Scores",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scores()),
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
