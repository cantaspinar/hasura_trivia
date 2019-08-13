import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hasura_trivia/SignUp.dart';
import 'package:hasura_trivia/main.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email;
  TextEditingController password;

  final formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: "");
    password = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
          height: double.infinity,
          color: Color.fromARGB(255, 244, 194, 87),
          padding: EdgeInsets.all(8),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("images/hasura-firebase.png"),
                    height: 300,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
                    validator: (value) =>
                        (value.isEmpty) ? "Please Enter Email" : null,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email",
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    controller: password,
                    validator: (value) =>
                        (value.isEmpty) ? "Please Enter Password" : null,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.security),
                      labelText: "Password",
                    ),
                  ),
                  Container(height: 10),
                  SizedBox(
                    width: 200,
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Login",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      onPressed: !loading
                          ? () async {
                              if (!formKey.currentState.validate()) {
                                return;
                              }
                              setState(() {
                                loading = true;
                              });

                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AuthCheck()),
                                );
                              } catch (e) {
                                setState(() {
                                  loading = false;
                                });
                                print(e);
                              }
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: FlatButton(
                        child: Text("Sign Up",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
