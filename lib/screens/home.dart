import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:moriarty_chess_engine/screens/game.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xff1E1E1E), // Dark Grey
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenWidth/6) ,
            Text(
              'Moriarty',
              style: GoogleFonts.anonymousPro(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth/4.5,) ,
            Image.asset(
              'assets/mor2.png',
              height: 350,
              width: 400,
            ),
           SizedBox(height: screenWidth/6) ,
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'The great game is afoot..',
                  textStyle: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
            SizedBox(height: screenWidth/6) ,
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChessPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // Rectangular shape
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Shall we!!!',
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenWidth/10,)
          ],
        ),
      ),
    );
  }
}
