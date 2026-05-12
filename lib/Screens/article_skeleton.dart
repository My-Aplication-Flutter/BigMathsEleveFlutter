
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ArticleSkeleton extends StatelessWidget {
  const ArticleSkeleton({super.key});

  Widget line({double height = 12, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget paragraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(),
        line(),
        line(width: 200),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ////////////////////////////////////////////////////////////
            /// IMAGE
            ////////////////////////////////////////////////////////////
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
            ),

            const SizedBox(height: 16),

            ////////////////////////////////////////////////////////////
            /// TITRE
            ////////////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  line(height: 20),
                  line(height: 20, width: 250),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ////////////////////////////////////////////////////////////
            /// META
            ////////////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: line(width: 150),
            ),

            const SizedBox(height: 24),

            ////////////////////////////////////////////////////////////
            /// PARAGRAPHES
            ////////////////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(6, (_) => paragraph()),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}