import 'package:flutter/material.dart';

import '../servers/auth/auth_service.dart';


class RegisterPage extends StatelessWidget{

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  //tap to go to Login page
  final void Function()? onTap;

  RegisterPage({super.key , required this.onTap});

  void register(BuildContext context) {
    // auth service instance
    final _auth= AuthService();

    // if password matches create user
    if(_passwordController.text == _confirmPasswordController.text) {
      try {
        _auth.signUpWithEmailAndPassword(
            _emailController.text, _passwordController.text);
      } on Exception catch (e) {
        showDialog(context: context, builder: (context) =>
            AlertDialog(
              title: Text(e.toString()),
            ),
        );
      }
    }
    // if password doesnt match
    else{
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Passwords do not match"),
      ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            ImageIcon(
              AssetImage("assets/logo.png"),
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20,),

            //welcome back text
            Text("Let's create a account for you!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),

            ),

            const SizedBox(height: 25,),
            //email text field
            Center(
              child: Container(
                width: 400, // fixed width for web
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25,),
            //password text field
            Center(
              child: Container(
                width: 400, // fixed width for web
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25,),
            //confirm password text field
            Center(
              child: Container(
                width: 400, // fixed width for web
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Confirm password",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),

            //register button
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary, // button color
                foregroundColor: Colors.white, // text color
                padding: const EdgeInsets.symmetric(horizontal: 115, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // rounded corners
                ),
              ),
              onPressed: () {
                register(context);
              },
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25,),
            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? "),
                GestureDetector(
                    onTap: onTap,
                    child: Text("Login now",style: TextStyle(fontWeight: FontWeight.bold),)),
              ],
            )
          ],
        ),
      ),
    );
  }


}