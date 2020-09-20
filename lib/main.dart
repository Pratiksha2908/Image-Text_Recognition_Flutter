import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ImageScreen(),
      ),
  );
}

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {

  File _image;
  final picker = ImagePicker();
  var recognizedText = ' ';

  Future cameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future galleryImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getText() async {
    FirebaseVisionImage firebaseVisionImage =
    FirebaseVisionImage.fromFile(_image);//_image
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText =
    await textRecognizer.processImage(firebaseVisionImage);
    setState(() {
      recognizedText = visionText.text;
    });
  }

  Future pdfMaker() async {
    final pw.Document pdf = pw.Document();
    final font = await rootBundle.load("assets/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(font);
    final fontBold = await rootBundle.load("assets/OpenSans-Bold.ttf");
    final ttfBold = pw.Font.ttf(fontBold);
    final fontItalic = await rootBundle.load("assets/OpenSans-Italic.ttf");
    final ttfItalic = pw.Font.ttf(fontItalic);
    final fontBoldItalic = await rootBundle.load("assets/OpenSans-BoldItalic.ttf");
    final ttfBoldItalic = pw.Font.ttf(fontBoldItalic);

    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttfBold,
      italic: ttfItalic,
      boldItalic: ttfBoldItalic,
    );
    pdf.addPage(pw.Page(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text('$recognizedText'),//, style: pw.TextStyle(font: ttf, fontSize: 20.0)
        );
      }
    ));
    Printing.sharePdf(bytes: pdf.save(), filename: 'my-document.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes Spot',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold
          ),
        ),
        //backgroundColor: Colors.blueAccent.shade100,
        centerTitle: true,
        backgroundColor: Colors.blueAccent.shade100,
        elevation: 15.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      FlatButton(
                        onPressed: cameraImage,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.blueAccent.shade100,
                          size: 80.0,
                        ),

                      ),
                      Text('Camera',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent.shade200
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      FlatButton(
                        onPressed: galleryImage,
                        child: Icon(
                          Icons.photo,
                          color: Colors.blueAccent.shade100,
                          size: 80.0,
                        ),
                      ),
                      Text('Gallery',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent.shade200
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Card(
              elevation: 10.0,
              color: Colors.blueAccent.shade100,
              child: FlatButton(
                onPressed: getText,
                child: Text('Read Text', style: TextStyle(fontWeight: FontWeight.bold),),
                color: Colors.blueAccent.shade100,
                textColor: Colors.white,
              ),
            ),
            Container(
              child: Image(image: AssetImage("assets/scanner.gif")),
            ),
            SizedBox(
              height: 10.0,
            ),
            Card(
              elevation: 10.0,
              color: Colors.blueAccent.shade100,
              child: FlatButton(
                onPressed: pdfMaker,
                child: Text('Convert to PDF', style: TextStyle(fontWeight: FontWeight.bold),),
                color: Colors.blueAccent.shade100,
                textColor: Colors.white,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Card(
                  elevation: 10.0,
                  color: Colors.white70,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '$recognizedText',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
