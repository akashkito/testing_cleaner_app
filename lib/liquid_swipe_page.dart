import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:testing_cleaner_app/test/homemainscreen.dart';

class LiquidSwipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = [
      const LiquidSwipePageContent(
        heading: 'WELCOME',
        title: "to the most reliable cleaner app",
        subtitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ',
        image: 'assets/main_1.png', // Your image or icon
        backgroundColor: Color.fromARGB(
            255, 255, 255, 255), // Set the background color for this page
      ),
      const LiquidSwipePageContent(
        heading: 'STAY',
        title: "Connected",
        subtitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ',
        image: 'assets/main_2.png', // Your image or icon
        backgroundColor: Color.fromARGB(
            255, 143, 247, 233), // Set the background color for this page
      ),
      const LiquidSwipePageContent(
        heading: 'GET',
        title: "Started Now",
        subtitle:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ',
        image: 'assets/main_3.png', // Your image or icon
        isLastPage: true,
        backgroundColor: Color.fromARGB(255, 252, 255, 204), // Set the background color for this page
      ),
    ];

    return Scaffold(
      body: LiquidSwipe(
        slideIconWidget: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        pages: pages,
        fullTransitionValue: 300, // Customize transition speed
        enableSideReveal: true,
        waveType: WaveType.liquidReveal,
        enableLoop: false,
      ),
    );
  }
}

class LiquidSwipePageContent extends StatelessWidget {
  final String heading;
  final String title;
  final String subtitle;
  final String image;
  final bool isLastPage;
  final Color backgroundColor; // New backgroundColor parameter

  const LiquidSwipePageContent({
    required this.heading,
    required this.title,
    required this.subtitle,
    required this.image,
    this.isLastPage = false,
    required this.backgroundColor, // Require the background color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor, // Set the background color
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "KitoCleaner",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              const Spacer(),
              Image.asset(image), // Image or icon here
              const SizedBox(height: 20),
              Text(
                heading,
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(
                width: 300,
                child: Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              if (isLastPage)
                Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainScreen()));
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Home",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    )

                    // ElevatedButton(
                    //   style: ButtonStyle(

                    //   ),
                    //   onPressed: () {
                    //     Navigator.pushReplacement(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const MainScreen()));
                    //   },
                    //   child: ,
                    // ),
                    ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
