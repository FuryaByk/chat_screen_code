import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flash_chat/get_messages.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late String mesaj;
  late String gonderen;
  CollectionReference mesajlar =
  FirebaseFirestore.instance.collection('mesajlar');
  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return mesajlar
        .add({
      'mesaj': mesaj, // John Doe
      'gonderen': gonderen, // Stokes and Sons
    })
        .then((value) => print("Mesaj eklendi"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  late User girisYapanKullanici;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurretnUser();
    print(girisYapanKullanici.email);
    gonderen = girisYapanKullanici.email.toString();
  }

  void getCurretnUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        girisYapanKullanici = user;
      }
    } catch (e) {
      print(e);
    }
  }

  List<QuerySnapshot> data = [];
  void getMessages() async {
    final gelen = await FirebaseFirestore.instance
        .collection('mesajlar')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc["mesaj"]);
      });
    });
    // data.addAll(gelen);
    // for(var mesaj in data){
    //   print(mesaj);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // setState(() {
                getMessages();
                // });
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mesajlar')
                    .snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData)
                  {
                    return Center(child: CircularProgressIndicator(backgroundColor: Colors.redAccent,),);
                  }
                  final gelenMesajlar=snapshot.data?.docs;
                  List<Text> mesajWidget=[];
                  for(var message in gelenMesajlar!)
                  {
                    final mesaj=message.get('mesaj');
                    final gonderen=message.get('gonderen');
                    final messageWidget=Text('$mesaj Gönderen: $gonderen');
                    mesajWidget.add(messageWidget);
                  }
                  return Column(children: mesajWidget);



                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        mesaj = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FilledButton(
                    onPressed: addUser,
                    child: Text(
                      'Gönder',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
