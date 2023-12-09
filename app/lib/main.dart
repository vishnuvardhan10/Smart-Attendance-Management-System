// for multiple images

import 'dart:convert';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ImageUploadScreen(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String credCheck = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Simulate teacher sign-in (replace with actual authentication logic)
    
    try {
      String endpointUrl = 'http://192.168.0.115:5000/sign_in';
      var response = await http.post(
        Uri.parse(endpointUrl),
        body: {'email': email, 'password': password},
      );
    
      if (response.statusCode == 200) {
        // Successful sign-in
        Map<String,dynamic> d = jsonDecode(response.body);
        if(d["data"] == "valid"){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ImageUploadScreen()),
          );
        } 
        else{
          credentials();
          print(credCheck);
          print('Invalid credentials 1');
        }
      } 
    } catch (error) {
      print('Error during sign-in: $error');
    }
  }

  Future<void> credentials() async {

    setState(() {
      credCheck = "Invalid Credentials";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 15),
            Text(
              credCheck,
              style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final picker = ImagePicker();
  List<File> images = [];
  Set<dynamic> present = {};
  Set<dynamic> absent = {};
  Map<String,dynamic> result = {};
  Set<String> here = {};
  Set<String> everyone = {};


  Future<void> takePicture() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }


  Future<void> pickImages() async {
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 100,
      maxWidth: 800,
    );

    setState(() {
      images = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  Future<void> markAttendance(Set<String> a, Set<String> b) async {
    List<String> names = [];
    
    setState(() {
      for(var pre in a){
        present.add(pre);
        names.add(pre);
      }
      for(var abn in everyone){
        if(!present.contains(abn)){
          absent.add(abn);
        }
        else if(absent.contains(abn)){
          absent.remove(abn);
        }
      }
    });
    String p = "";
    for(var i in names){
      p += i + " ";
    }
    String url = 'http://192.168.0.115:5000/updateAttendance';
    var response = await http.post(
      Uri.parse(url),
      body: {
        "present" : p,
        },
    );


  }

  Future<void> uploadImages() async {
    
    for (var image in images) {
      String endpointUrl = 'http://192.168.0.115:5000/upload_image';
      var request = http.MultipartRequest('POST', Uri.parse(endpointUrl));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      result = jsonDecode(response.body);
      for(var i in result["present"]){
        here.add(i);
      }
      for(var i in result["everyone"]){
        everyone.add(i);
      }

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Image upload failed with status code ${response.statusCode}');
      }
    }
    markAttendance(here,everyone);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: takePicture,
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: pickImages,
              child: const Text('Select Images from Gallery'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: uploadImages,
              child: const Text('Upload Images to Server'),
            ),
            const SizedBox(height: 10),
            Text('Selected Images: ${images.length}'),
            const SizedBox(height : 5),
            Text('Present : $present'),
            const SizedBox(height : 5),
            Text('absent : $absent'),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendancePage()),
                );
              },
              child: const Text('Attendance Info'),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  // Placeholder for displaying attendance information
  const AttendancePage({super.key});
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String s = "";
  Future<void> checkAttendance() async {
    s = "";
    try{
      String endpointUrl = "http://192.168.0.115:5000/checkAttendance";
      var response = await http.post(
        Uri.parse(endpointUrl),
        body: {"a":"b"},
      );
      if(response.statusCode == 200){
        Map<String,dynamic> d = jsonDecode(response.body);
        setState(() {
          for(var item in d.entries){
            s += item.key + ": \n";
            for(var val in item.value){
              s += "\t" + val + "\n";
            }
          }
        });
      }
      else{
        print("Unknown Error");
      }
    }
    catch(error){
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Page'),
      ),
      body: Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children : <Widget>[
              ElevatedButton(
                onPressed: checkAttendance,
                child: const Text("Check Attendance"),
              ),
              const SizedBox(height: 15,),
              Text("Attendance marked as Present : \n $s"),
            ]
        ),
      ),
    );
  }
}


// String credCheck = "";
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   Future<void> signIn() async {
//     String email = emailController.text;
//     String password = passwordController.text;

//     // Simulate teacher sign-in (replace with actual authentication logic)
    
//     try {
//       String endpointUrl = 'http://192.168.1.17:5000/sign_in';
//       var response = await http.post(
//         Uri.parse(endpointUrl),
//         body: {'email': email, 'password': password},
//       );
    
//       if (response.statusCode == 200) {
//         // Successful sign-in
//         Map<String,dynamic> d = jsonDecode(response.body);
//         if(d["data"] == "valid"){
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const ImageUploadScreen()),
//           );
//         } 
//         else{
//           credentials();
//           print(credCheck);
//           print('Invalid credentials 1');
//         }
//       } 
//     } catch (error) {
//       print('Error during sign-in: $error');
//     }
//   }