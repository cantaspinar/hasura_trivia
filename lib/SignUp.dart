import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hasura_trivia/Login.dart';
import 'package:hasura_trivia/main.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController name;
  TextEditingController email;
  TextEditingController password;

  final formKey = GlobalKey<FormState>();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: "");
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
          child: Center(
            child: SingleChildScrollView(
              
                        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Image(
                      image: AssetImage("images/hasura-auth.png"),
                      height: 275,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: name,
                      validator: (value) =>
                          (value.isEmpty) ? "Please Enter Name" : null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Name",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      validator: (value) =>
                          (value.isEmpty) ? "Please Enter Email" : null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "Email",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
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
                  ),
                  Container(height: 10),
                  SizedBox(
                    width: 200,
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("Sign Up",
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
                              final HttpsCallable callable =
                                  CloudFunctions.instance.getHttpsCallable(
                                functionName: 'registerUser',
                              );

                              try {
                                await callable.call(<String, dynamic>{
                                  'email': email.text,
                                  'displayName': name.text,
                                  'password': password.text
                                });

                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: email.text, password: password.text);
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
                        child: Text("Login",
                            style: TextStyle(fontSize: 16, color: Colors.black)),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
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
