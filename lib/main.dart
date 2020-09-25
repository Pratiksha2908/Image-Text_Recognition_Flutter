import 'dart:io';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';

// void main() {
//   runApp(
//     DevicePreview(//preview any device from any device, device orientation and dark mode, etc.
//       enabled: !kReleaseMode,
//       builder: (context) => NotesSpot(),
//     ),
//   );
// }
//
// class NotesSpot extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       locale: DevicePreview.of(context).locale,
//       builder: DevicePreview.appBuilder,
//       debugShowCheckedModeBanner: false,
//       home: ChangeNotifierProvider<ThemeNotifier>(
//         create: (_) => ThemeNotifier(),
//         child: ImageScreen(),
//       ),
//     );
//   }
// }

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChangeNotifierProvider<ThemeNotifier>(
         create: (_) => ThemeNotifier(),
         child: ImageScreen(),
        ),
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
  bool pressed = false;
  //bool showSpinner = false;

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
    FirebaseVisionImage firebaseVisionImage = FirebaseVisionImage.fromFile(_image);//_image
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(firebaseVisionImage);
    setState(() {
      recognizedText = visionText.text;
      pressed = true;
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
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(pdf.save());
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    //Printing.sharePdf(bytes: pdf.save(), filename: 'myDocument.pdf');
  }

  Future sharePdf() async {
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
    Printing.sharePdf(bytes: pdf.save(), filename: 'myDocument.pdf');
  }

  bool lightTheme = true;

  Icon _affectedByStateChange = Icon(
    Icons.wb_sunny,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {

    _thisWillAffectTheState() {
      _affectedByStateChange = Icon(Icons.wb_sunny, color: Colors.white);
    }

    _thisWillAlsoAffectTheState() {
      _affectedByStateChange = Icon(Icons.brightness_2, color: Colors.indigo.shade700);
    }

    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) {
        return MaterialApp(
          theme: theme.getTheme(),
          home: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo.png',
                    fit: BoxFit.contain,
                    height: 32,
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    'Image to PDF',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0, 
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () => {
                    if(lightTheme == true) {
                      theme.setDarkMode(),
                      lightTheme = false,
                      setState((){
                        _thisWillAffectTheState();
                      }),
                      //Colors.white,
                    } else if(lightTheme == false) {
                      theme.setLightMode(),
                      lightTheme = true,
                      setState((){
                        _thisWillAlsoAffectTheState();
                      }),
                     // Colors.indigo.shade700,
                    },
                  },
                  icon: _affectedByStateChange,
                ),
              ],
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
                                  color: Colors.blueAccent.shade200,
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
                  // showSpinner ? SpinKitFoldingCube(
                  //   color: Color(0xff6495ED),
                  //   size: 40.0,
                  // ) : SizedBox(),
                  Card(
                    elevation: 10.0,
                    margin: EdgeInsets.only(right: 80.0, left: 80.0, top: 20.0),
                    color: Colors.blueAccent.shade100,
                    child: FlatButton(
                      onPressed: getText,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, color: Colors.white,),
                          Text('Read Text', style: TextStyle(fontWeight: FontWeight.bold),),
                        ],
                      ),
                      textColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  pressed ? Center(
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.only(right: 80.0, left: 80.0, top: 20.0),
                          elevation: 10.0,
                          color: Colors.green,
                          child: FlatButton(
                            onPressed: pdfMaker,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_download,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Download PDF',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            ),
                            textColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Card(
                            elevation: 10.0,
                            color: Colors.white70,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                '$recognizedText',
                                style: TextStyle(fontSize: 17.0),
                              ),
                            ),
                          ),
                        ),
                        FlatButton(
                          child: Card(
                            elevation: 10.0,
                            margin: EdgeInsets.only(bottom: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(60.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Icon(
                                  Icons.share,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                          onPressed: sharePdf,
                        ),
                      ],
                    ),
                  ) : SizedBox(),
                ],
              ),
            ),
          ),
      );
      },
    );
  }
}
//app.apk

// Padding(
// padding: EdgeInsets.all(20.0),
// child: Center(
// child: Card(
// elevation: 10.0,
// color: Colors.white70,
// child: Padding(
// padding: const EdgeInsets.all(20.0),
// child: Text(
// '$recognizedText',
// style: TextStyle(fontSize: 30.0),
// ),
// ),
// ),
// ),
// ),
