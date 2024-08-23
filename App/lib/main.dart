import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDP Camera App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RawDatagramSocket? udpSocket;
  Uint8List imgBuffer = Uint8List(0);
  Image? receivedImage;

  @override
  void initState() {
    super.initState();
    setupUDP();
  }

  void setupUDP() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 65002);
    udpSocket!.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram datagram = udpSocket!.receive()!;
        Uint8List data = datagram.data;

        if (data[0] == 0xFF && data[1] == 0xD8) {
          // If the received data starts with the JPEG start marker, reset the buffer
          imgBuffer = Uint8List(0);
        }

        imgBuffer = Uint8List.fromList([...imgBuffer, ...data]);

        if (data[data.length - 2] == 0xFF && data[data.length - 1] == 0xD9)
        {
          // If the received data ends with the JPEG end marker, update the image
          setState(()
          {
            // Display the received image
            receivedImage = Image.memory(Uint8List.fromList(imgBuffer), gaplessPlayback: true);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    udpSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UDP Camera App'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: receivedImage, // Display the received image
        ),
      ),
    );
  }
}