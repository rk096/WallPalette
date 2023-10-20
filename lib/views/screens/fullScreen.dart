import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';



class FullScreen extends StatelessWidget {
  String imgUrl;
  FullScreen({super.key, required this.imgUrl});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  Future<void> downloadAndSetWallpaper(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Downloading Started...")));
    try {
      final response = await http.get(Uri.parse(imgUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/downloaded_image.jpg';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Save the image to the gallery.
        //await GallerySaver.saveImage(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Downloaded Successfully"),
          ),
        );

        print("IMAGE DOWNLOADED");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error downloading image")));
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Occurred - $error")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Trigger the download function when the user taps on the image.
          downloadAndSetWallpaper(context);
        },
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imgUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    String url = imgUrl;
                    await GallerySaver.saveImage(url);
                    // Trigger the download function when the user taps the button.
                    downloadAndSetWallpaper(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Set the button's background color to blue.
                  ),
                  child: Text("Download Image"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
