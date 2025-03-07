// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing_cleaner_app/files/all_files.dart';
import 'package:testing_cleaner_app/liquid_swipe_page.dart';
import 'package:testing_cleaner_app/media/video/videos_page.dart';
import 'package:testing_cleaner_app/other%20files/otherfiles.dart';
import 'package:testing_cleaner_app/system_info_page.dart';
import 'package:testing_cleaner_app/test/settings_page.dart';
import 'package:testing_cleaner_app/test/view_screen.dart';

import '../apps/apps_page.dart';
import '../media/audio/audios_page.dart';
import '../media/photo/photos_page.dart';
import '../storage/storage_service.dart';
import '../storage/storage_widget.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  final StorageService storageService = StorageService();

  static const platform = MethodChannel('com.example.testing_cleaner_app');

  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final Map<dynamic, dynamic> storageInfo =
          await platform.invokeMethod('getStorageInfo');
      return Map<String, dynamic>.from(
          storageInfo); // Ensure the map is properly typed
    } on PlatformException catch (e) {
      print("Failed to get storage info: ${e.message}");
      return {};
    }
  }

  // // Simulate a task (e.g., loading data for apps)
  // Future<void> _loadApps() async {
  //   await Future.delayed(const Duration(seconds: 1)); // Simulate loading task
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        width: 280,
        elevation: 0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.only(top: 17, left: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              // ignore: sort_child_properties_last
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cleaning_services,
                        size: 25,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "KitoCleaner",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "Pro tip",
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  Container(
                    width: 220,
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ",
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  )
                ],
              ),
              duration: const Duration(milliseconds: 1000),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Storage",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            drawerlist(
                Image.asset(
                  'assets/app_icon.png',
                  width: 25,
                ),
                'Apps',
                '',
                () {}),
            drawerlist(
                Image.asset(
                  'assets/photo_icon.png',
                  width: 25,
                ),
                'Photos',
                '',
                () {}),
            drawerlist(
                Image.asset(
                  'assets/videos_icon.png',
                  width: 25,
                ),
                'Videos',
                '',
                () {}),
            drawerlist(
                Image.asset(
                  'assets/audios_icon.png',
                  width: 25,
                ),
                'Audios',
                '',
                () {}),
            const Divider(),
            drawerlist(
                Image.asset(
                  'assets/app_icon.png',
                  width: 25,
                ),
                'System Info',
                '', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SystemInfoPage(),
                  ));
            }),
            drawerlist(
                Image.asset(
                  'assets/audios_icon.png',
                  width: 25,
                ),
                'Swiper',
                '', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiquidSwipePage(),
                  ));
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            return SizedBox(
              height: 340,
              child: Stack(
                children: [
                  Positioned(
                      child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 100,
                              offset: const Offset(0, 0),
                              spreadRadius: 1)
                        ],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        )),
                  )),

                  //App bar
                  Positioned(
                      top: 40,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Open the drawer when the icon is tapped
                                Scaffold.of(context).openDrawer();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      blurRadius: 50,
                                      offset: const Offset(0, 0),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.menu_open,
                                  size: 30,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage(),
                                    ));
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                          blurRadius: 50,
                                          offset: const Offset(0, 0),
                                          spreadRadius: 1)
                                    ],
                                  ),
                                  // ignore: prefer_const_constructors
                                  child: Icon(
                                    Icons.settings,
                                    size: 30,
                                  )),
                            ),
                          ],
                        ),
                      )),

                  //Storage info
                  Positioned(
                      top: 80,
                      left: 20,
                      right: 20,
                      child: Container(
                          // padding: const EdgeInsets.all(10),
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(20),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.grey.withOpacity(0.4),
                          //       blurRadius: 10,
                          //       offset: const Offset(0, 0),
                          //       spreadRadius: 1,
                          //     ),
                          //   ],
                          // ),
                          child: const StoragePieChartWidget())),

                  //Button
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    top: 265,
                    child: Center(
                      child: Container(
                        width: 170,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 8, 108, 126),
                          borderRadius: BorderRadius.circular(120),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: InkWell(
                          // Add InkWell for the pressed effect
                          onTap: () {
                            // Navigate to the next screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ViewPage(), // Replace with your next screen
                              ),
                            );
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         FolderAccessPage(), // Replace with your next screen
                            //   ),
                            // );
                          },
                          splashColor: const Color.fromARGB(255, 86, 145, 194)
                              .withOpacity(0.3), // Splash color on tap
                          borderRadius: BorderRadius.circular(120),
                          child: Center(
                            child: Text(
                              "Quick Clean",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: FutureBuilder<Map<String, dynamic>>(
                future:
                    getStorageInfo(), // Ensure this returns a Future<Map<String, dynamic>>
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final storageInfo = snapshot.data ?? {};
                  final totalStorage = storageInfo["total"] ?? 0;

                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.all(0),
                    children: <Widget>[
                      _buildGridItem(
                        context,
                        "Apps",
                        // Icons.apps,
                        'assets/app_icon.png',
                        totalStorage,
                        () async {
                          // Show a progress indicator before navigation
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent dismissing the dialog by tapping outside
                            builder: (BuildContext context) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(), // Show progress bar
                              );
                            },
                          );

                          // Simulate a delay or data fetching here
                          await Future.delayed(const Duration(
                              milliseconds:
                                  1000)); // Simulating delay for loading

                          // Dismiss the progress dialog once the data is ready
                          Navigator.pop(context);

                          // Now navigate to the AppsPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AppsPage(), // Target page (AppsPage)
                            ),
                          );
                        },
                      ),
                      // _buildGridItem(
                      //   context,
                      //   "Apps",
                      //   'assets/app_icon.png',
                      //   totalStorage,
                      //   () async {
                      //     // Navigate to PercentIndicatorPage with a simulated loading task
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => PercentIndicatorPage(
                      //           loadingTask:
                      //               _loadApps(), // Simulate the loading task
                      //           targetPage:
                      //               AppsPage(), // Navigate to AppsPage after loading is complete
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      _buildGridItem(
                        context,
                        "Photos",
                        // Icons.photo,
                        'assets/audios_icon.png',
                        totalStorage,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PhotosPage()),
                        ),
                      ),

                      _buildGridItem(
                        context,
                        "Videos",
                        'assets/photo_icon.png',
                        totalStorage,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VideosPage()),
                        ),
                      ),

                      _buildGridItem(
                        context,
                        "Audios",
                        'assets/videos_icon.png',
                        totalStorage,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AudiosPage()),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  ListTile drawerlist(
      Image? img, String? title, String? subtxt, GestureTapCallback? ontap) {
    return ListTile(
      leading: img,
      title: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
        ),
        child: Text(
          title!,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: ontap,
      trailing: Text(
        subtxt!,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    // IconData icon,
    String img,
    int totalStorage,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Row
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        child: Image.asset(
                          img,
                          width: 30,
                          height: 30,
                        )
                        // Icon(
                        //   icon,
                        //   size: 30,
                        // ),
                        ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Text(
                        '${(totalStorage / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Title Row
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Storage Info Row
              const Row(
                children: [
                  Text(
                    'count',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// GridView.builder(
//                     physics: BouncingScrollPhysics(),
//                     scrollDirection: Axis.vertical,
//                     shrinkWrap: true,
//                     itemCount: 4,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                     ),
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(
//                             top: 10, left: 10, right: 10, bottom: 10),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 15, horizontal: 15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.4),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 20),
//                                 spreadRadius: 1,
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               //First Row
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(15),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                         color: Colors.white,
//                                         border: Border.all(
//                                             color: Colors.grey, width: 0.5),
//                                       ),
//                                       child: const Icon(
//                                         Icons.photo,
//                                         size: 30,
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 5,
//                                         horizontal: 10,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(20),
//                                         color: Colors.white,
//                                         border: Border.all(
//                                             color: Colors.grey, width: 0.5),
//                                       ),
//                                       child: const Text("50 GB"),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               const Row(
//                                 children: [
//                                   Text(
//                                     "Videos",
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Row(
//                                 children: [
//                                   Text(
//                                     "100 items",
//                                     style: TextStyle(color: Colors.grey),
//                                   )
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),