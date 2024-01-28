// home_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_capteur_texte/process_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translator/translator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = "";
  File? image;
  late ImagePicker imagePicker;
  late TextRecognizer textRecognizer;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  Future<void> GalleryImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      image = File(xFile.path);

      setState(() {
        image;
        // Faire l'étiquetage des images_ extraire l'image de l'image
        TextExtrait();
      });
    }
  }

  Future<void> CaptureImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (xFile != null) {
      image = File(xFile.path);

      setState(() {
        image;
        // Faire l'étiquetage des images_ extraire l'image de l'image
        TextExtrait();
      });
    }
  }

  Future<void> TextExtrait() async {
    try {
      final inputImage = InputImage.fromFilePath(image!.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      result = recognizedText.text;

      
      // Détecter la langue du système
      String systemLocale = Platform.localeName.split('_').first;

      // Traduire le texte extrait dans la langue du système
      final translator = GoogleTranslator();
      var translation = await translator.translate(result, to: systemLocale);

      setState(() {
        result = translation.text!;
      });

      navigateToProcessPage(context, image!, result);
    } catch (e) {
      print("Erreur lors de la reconnaissance de texte : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application de capteur de texte'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenue sur Capteur de texte!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Choisissez un onglet',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 5),
            IconButton(
              onPressed: GalleryImage,
              icon: Icon(Icons.photo,
                  size: 40,
                  color: const Color.fromARGB(255, 255, 184, 184)),
            ),
            IconButton(
              onPressed: CaptureImage,
              icon: Icon(
                Icons.camera,
                size: 40,
                color: Color.fromARGB(255, 252, 177, 177),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToProcessPage(
      BuildContext context, File image, String extractedText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProcessPage(image: image, extractedText: extractedText),
      ),
    );
  }
}
