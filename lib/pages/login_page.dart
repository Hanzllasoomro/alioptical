import 'package:flutter/material.dart';

import '../servers/auth/auth_service.dart';

class LoginPage extends StatelessWidget{

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //tap to go to Register page
  final void Function()? onTap;

  LoginPage({super.key , required this.onTap});

  void login(BuildContext context) async{
    //auth service
    final _auth= AuthService();

    //try login
    try{
      await _auth.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
    }
    catch(e){
      showDialog(context: context, builder: (context)=> AlertDialog(
        title: Text(e.toString()),
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
            Text("Welcome Back!",
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

            const SizedBox(height: 25),
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

            // login button
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary, // button color
                foregroundColor: Colors.white, // text color
                padding: const EdgeInsets.symmetric(horizontal: 125, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // rounded corners
                ),
              ),
              onPressed: () {
                login(context); // ⚡ call function here
              },
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25,),
            //register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an Account? "),
                GestureDetector(
                  onTap: onTap,
                  child: Text("Register now",style: TextStyle(fontWeight: FontWeight.bold),

                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}