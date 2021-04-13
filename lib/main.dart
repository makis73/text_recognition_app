import 'dart:ffi';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  final picker = ImagePicker();
  String recognizedText = '';
  String recognizedCode = '';

  bool _isImageLoaded = false;

  Future pickImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
        _isImageLoaded = true;
      });
    }
  }

  Future readText() async {
    // Construct a [FirebaseVisionImage] from a file.
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    // Creates an instance of [TextRecognizer].
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    // Detects [VisionText] from a [FirebaseVisionImage].
    VisionText readText = await recognizeText.processImage(myImage);
    print(readText.text);
    recognizedText = readText.text;
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
        }
      }
    }
    setState(() {
      recognizedText = readText.text;
    });
  }

  Future decode() async {
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(myImage);

    for (Barcode readableCode in barCodes) {
      print(readableCode.displayValue);
    }
    //setState(() {
    //  recognizedCode = barCodes[0].displayValue;
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _isImageLoaded
              ? Center(
                  child: Container(
                    width: 200.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage), fit: BoxFit.contain)),
                  ),
                )
              : Container(),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Pick an image'),
            onPressed: pickImage,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Read text'),
            onPressed: readText,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Read barcode'),
            onPressed: decode,
          ),
          SizedBox(
            height: 10,
          ),
          Text(recognizedText),
          SizedBox(
            height: 10,
          ),
          Text(recognizedCode)
        ],
      ),
    );
  }
}
