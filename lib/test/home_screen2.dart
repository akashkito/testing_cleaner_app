// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_cleaner_app/files/all_files.dart';
import 'package:testing_cleaner_app/media/video/videos_page.dart';
import 'package:testing_cleaner_app/system_info_page.dart';
import 'package:testing_cleaner_app/test/view_screen.dart';

import '../apps/apps_page.dart';
import '../media/audios_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        elevation: 0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
                'Logo',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Storage"),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Apps'),
              onTap: () {
                // Handle Item 1
              },
              trailing: const Text(
                "50 GB",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Photos'),
              onTap: () {
                // Handle Item 1
              },
              trailing: const Text(
                "50 GB",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Videos'),
              onTap: () {
                // Handle Item 1
              },
              trailing: const Text(
                "50 GB",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Audios'),
              onTap: () {
                // Handle Item 1
              },
              trailing: const Text(
                "50 GB",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.apps),
              title: const Text('Other Files'),
              onTap: () {
                // Handle Item 1
              },
              trailing: const Text(
                "50 GB",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('System Info'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SystemInfoPage(),
                    ));
              },
              trailing: const Text(
                "50 GB",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
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
                              blurRadius: 10,
                              offset: const Offset(0, 20),
                              spreadRadius: 1)
                        ],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        )),
                  )),

                  //App bar
                  Positioned(
                      top: 50,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 30,
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
                                      blurRadius: 20,
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
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(00, 0),
                                        spreadRadius: 1)
                                  ],
                                ),
                                // ignore: prefer_const_constructors
                                child: Icon(
                                  Icons.settings,
                                  size: 30,
                                )),
                          ],
                        ),
                      )),

                  //Storage info
                  Positioned(
                      top: 150,
                      left: 20,
                      right: 40,
                      child: Container(
                          padding: const EdgeInsets.all(10),
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
                          child: StoragePieChartWidget())),

                  //Button
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    top: 255,
                    child: Center(
                      child: Container(
                        width: 150,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(120),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: InkWell(
                          // Add InkWell for the pressed effect
                          onTap: () {
                            // Navigate to the next screen
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const ViewPage(), // Replace with your next screen
                            //   ),
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FolderAccessPage(), // Replace with your next screen
                              ),
                            );
                          },
                          splashColor: Colors.blue
                              .withOpacity(0.3), // Splash color on tap
                          borderRadius: BorderRadius.circular(120),
                          child: const Center(
                            child: Text(
                              "Quick Clean",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
                    children: <Widget>[
                      _buildGridItem(
                        context,
                        "Apps",
                        Icons.apps,
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
                                  AppsPage(), // Target page (AppsPage)
                            ),
                          );
                        },
                      ),
                      _buildGridItem(
                        context,
                        "Photos",
                        Icons.photo,
                        totalStorage,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PhotosPage()),
                        ),
                      ),
                      _buildGridItem(
                        context,
                        "Videos",
                        Icons.video_library,
                        totalStorage,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VideosPage()),
                        ),
                      ),
                      _buildGridItem(
                        context,
                        "Audios",
                        Icons.audiotrack,
                        totalStorage,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AudiosPage()),
                        ),
                      ),
                    ],
                  );
                },
              ),

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
            ),
          )

          //footer
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40, top: 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Container(
          //           padding: const EdgeInsets.all(25),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(60),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.grey.withOpacity(0.4),
          //                 blurRadius: 20,
          //                 offset: const Offset(0, 0),
          //                 spreadRadius: 1,
          //               ),
          //             ],
          //           ),
          //           child: const Icon(Icons.clean_hands_rounded)),
          //       Container(
          //           padding: const EdgeInsets.all(25),
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(60),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.grey.withOpacity(0.4),
          //                 blurRadius: 20,
          //                 offset: const Offset(0, 0),
          //                 spreadRadius: 1,
          //               ),
          //             ],
          //           ),
          //           child: const Icon(
          //             Icons.workspace_premium,
          //           )),
          //       Container(
          //         padding: const EdgeInsets.all(25),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(60),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.grey.withOpacity(0.4),
          //               blurRadius: 20,
          //               offset: const Offset(0, 0),
          //               spreadRadius: 1,
          //             ),
          //           ],
          //         ),
          //         child: const Icon(Icons.speed),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

//   Widget _buildGridItem(
//     BuildContext context,
//     String title,
//     IconData icon,
//     int totalStorage,
//     Function onTap,
//   ) {
//     return GestureDetector(
//       onTap: () => onTap(),
//       child: Card(
//         margin: EdgeInsets.all(8),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Icon(icon, size: 50),
//             SizedBox(height: 10),
//             Text(title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 5),
//             Text(
//               'Total Storage: ${totalStorage / (1024 * 1024 * 1024)} GB',
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  Widget _buildGridItem(
    BuildContext context,
    String title,
    IconData icon,
    int totalStorage,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 20),
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
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Icon(
                        icon,
                        size: 30,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Text(
                        '${(totalStorage / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Storage Info Row
              Row(
                children: [
                  Text(
                    '${(totalStorage / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB',
                    style: const TextStyle(color: Colors.grey),
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