import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ExerciceViewerPage extends StatefulWidget {
  final String title;
  final List<String> images;

  const ExerciceViewerPage({
    super.key,
    required this.title,
    required this.images,
  });

  @override
  State<ExerciceViewerPage> createState() => _ExerciceViewerPageState();
}

class _ExerciceViewerPageState extends State<ExerciceViewerPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print("IMAGES => ${widget.images}");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: widget.images.isEmpty
          ? const Center(
              child: Text(
                "Aucune image",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : Stack(
              children: [
                /// GALLERY
                PhotoViewGallery.builder(
                  itemCount: widget.images.length,
                  pageController: PageController(
                    initialPage: currentIndex,
                  ),
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  builder: (context, index) {
                    final imageUrl = widget.images[index];

                    print("IMAGE URL => $imageUrl");

                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        imageUrl,
                      ),
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: imageUrl,
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                    );
                  },
                  loadingBuilder: (context, event) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                /// COUNTER
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${currentIndex + 1} / ${widget.images.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
