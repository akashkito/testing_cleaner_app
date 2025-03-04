// import 'package:flutter/material.dart';
// import 'storage_service.dart';

// class StoragePieChartWidget extends StatelessWidget {
//   final StorageService storageService = StorageService();

//   StoragePieChartWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: storageService.getStorageInfo(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator(); // Show loading indicator
//         }

//         if (snapshot.hasError) {
//           return Text("Error: ${snapshot.error}");
//         }

//         if (snapshot.hasData) {
//           final storageData = snapshot.data!;

//           // Prepare data for display
//           double totalStorage = storageData['total']!;
//           double availableStorage = storageData['available']!;
//           double usedStorage = storageData['used']!;
//           // double remainingStorage = totalStorage - availableStorage - usedStorage;

//           // // // Calculate percentages
//           // double totalStoragrPercentage = (totalStorage / totalStorage) * 100;
//           // double availablePercentage = (availableStorage / totalStorage) * 100;
//           // double usedPercentage = (usedStorage / totalStorage) * 100;
//           // double remainingPercentage = (remainingStorage / totalStorage) * 100;

//           // Display the storage data as text
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     "Total Storage: ${totalStorage.toStringAsFixed(2)} GB",
//                     style: TextStyle(fontSize: 17),
//                   ),
//                   Text(
//                     "Available: ${availableStorage.toStringAsFixed(2)} GB",
//                     style: TextStyle(fontSize: 17),
//                   ),
//                   Text(
//                     "Used : ${usedStorage.toStringAsFixed(2)} GB",
//                     style: TextStyle(fontSize: 17),
//                   ),
//                   // Text("Remaining : ${remainingStorage.toStringAsFixed(2)} GB"),
//                 ],
//               ),
//               // Display percentage data
//               // // Column(
//               // //   children: [
//               // //     Text("total S P: ${totalStoragrPercentage.toStringAsFixed(2)}%"),
//               // //     Text("Available S P: ${availablePercentage.toStringAsFixed(2)}%"),
//               // // Text("Used S P: ${usedPercentage.toStringAsFixed(2)}%"),
//               // // Text("Remaining S P: ${remainingPercentage.toStringAsFixed(2)}%"),

//               //   ],
//               // )
//             ],
//           );
//         }

//         return const Text("No data available");
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // Import fl_chart package
// import 'package:google_fonts/google_fonts.dart';
// import 'storage_service.dart';

// class StoragePieChartWidget extends StatelessWidget {
//   final StorageService storageService = StorageService();

//   StoragePieChartWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: storageService.getStorageInfo(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//               child: CircularProgressIndicator()); // Show loading indicator
//         }

//         if (snapshot.hasError) {
//           return Text("Error: ${snapshot.error}");
//         }

//         if (snapshot.hasData) {
//           final storageData = snapshot.data!;

//           // Prepare data for the pie chart
//           double totalStorage = storageData['total']!;
//           double availableStorage = storageData['available']!;
//           double usedStorage = storageData['used']!;
//           // double remainingStorage =
//           //     totalStorage - usedStorage - availableStorage;

//           // Calculate percentages
//           double availablePercentage = (availableStorage / totalStorage) * 100;
//           double usedPercentage = (usedStorage / totalStorage) * 100;
//           // double remainingPercentage = (remainingStorage / totalStorage) * 100;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Pie Chart displaying the storage usage
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(40),
//                           child: SizedBox(
//                             height: 10,
//                             width: 15,
//                             child: PieChart(
//                               PieChartData(
//                                 sections: [
//                                   PieChartSectionData(
//                                     // title: availablePercentage.toString(),
//                                     titleStyle:
//                                         const TextStyle(color: Colors.white),
//                                     value: usedPercentage,
//                                     color:
//                                         const Color.fromARGB(255, 54, 54, 54),
//                                     showTitle: false,
//                                     radius: 18,
//                                   ),
//                                   PieChartSectionData(
//                                     value: availablePercentage,
//                                     color: const Color.fromARGB(
//                                         255, 134, 134, 134),
//                                     showTitle: false,
//                                     radius: 20,
//                                   ),
//                                 ],
//                                 borderData: FlBorderData(show: false),
//                                 sectionsSpace:
//                                     0, // Optional space between the sections
//                                 centerSpaceRadius:
//                                     30, // Optional radius in the center (to create a donut chart effect)
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Indicators for Used and Available storage
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Used Storage Indicator
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.circle,
//                                   size: 12,
//                                   color: Color.fromARGB(255, 54, 54, 54),
//                                 ),
//                                 const SizedBox(
//                                   width: 5,
//                                 ),
//                                 Text(
//                                   'Used Storage',
//                                   style: GoogleFonts.monda(fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(width: 8),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 17.0, right: 17,),
//                                   child: Text(
//                                     "${usedStorage.toStringAsFixed(2)} GB",
//                                     style: GoogleFonts.monda(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.circle,
//                                   size: 12,
//                                   color: Color.fromARGB(255, 134, 134, 134),
//                                 ),
//                                 const SizedBox(
//                                   width: 5,
//                                 ),
//                                 Text(
//                                   'Available Storage',
//                                   style: GoogleFonts.monda(fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(width: 8),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 17.0, right: 17),
//                                   child: Text(
//                                     "${availableStorage.toStringAsFixed(2)} GB",
//                                     style: GoogleFonts.monda(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     // Storage details as text
//                     // Padding(
//                     //   padding: const EdgeInsets.all(16.0),
//                     //   child: Column(
//                     //     crossAxisAlignment: CrossAxisAlignment.start,
//                     //     children: [
//                     //       Text(
//                     //         "Total Storage: ${totalStorage.toStringAsFixed(2)} GB",
//                     //         style: TextStyle(fontSize: 10),
//                     //       ),
//                     //       Text(
//                     //         "Available: ${availableStorage.toStringAsFixed(2)} GB",
//                     //         style: TextStyle(fontSize: 10),
//                     //       ),
//                     //       Text(
//                     //         "Used: ${usedStorage.toStringAsFixed(2)} GB",
//                     //         style: TextStyle(fontSize: 10),
//                     //       ),
//                     //       // Text(
//                     //       //   "Remaining: ${remainingStorage.toStringAsFixed(2)} GB",
//                     //       //   style: TextStyle(fontSize: 10),
//                     //       // ),
//                     //     ],
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         }

//         return const Center(child: Text("No data available"));
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart package
import 'package:google_fonts/google_fonts.dart';
import 'storage_service.dart';
import 'dart:async'; // Import for Timer

class StoragePieChartWidget extends StatefulWidget {
  const StoragePieChartWidget({super.key});

  @override
  _StoragePieChartWidgetState createState() => _StoragePieChartWidgetState();
}

class _StoragePieChartWidgetState extends State<StoragePieChartWidget> {
  final StorageService storageService = StorageService();

  // StreamController to manage the periodic data fetching
  final StreamController<Map<String, dynamic>> _storageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  void initState() {
    super.initState();

    // Start emitting data every second
    _startDataStream();
  }

  @override
  void dispose() {
    // Close the stream when the widget is disposed
    _storageStreamController.close();
    super.dispose();
  }

  void _startDataStream() {
    // ignore: prefer_const_constructors
    Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final storageData = await storageService.getStorageInfo();
        _storageStreamController.sink.add(storageData); // Emit data to stream
      } catch (e) {
        _storageStreamController.sink.addError(e); // Handle errors
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _storageStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: CircularProgressIndicator(),
              )); // Show loading indicator
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.hasData) {
          final storageData = snapshot.data!;

          // Prepare data for the pie chart
          double totalStorage = storageData['total']!;
          double availableStorage = storageData['available']!;
          double usedStorage = storageData['used']!;

          // Calculate percentages
          double availablePercentage = (availableStorage / totalStorage) * 100;
          double usedPercentage = (usedStorage / totalStorage) * 100;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pie Chart displaying the storage usage
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: SizedBox(
                            height: 10,
                            width: 15,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: usedPercentage,
                                    color:
                                        const Color.fromARGB(255, 54, 54, 54),
                                    showTitle: false,
                                    radius: 18,
                                  ),
                                  PieChartSectionData(
                                    value: availablePercentage,
                                    color: const Color.fromARGB(
                                        255, 134, 134, 134),
                                    showTitle: false,
                                    radius: 20,
                                  ),
                                ],
                                borderData: FlBorderData(show: false),
                                sectionsSpace:
                                    0, // Optional space between the sections
                                centerSpaceRadius:
                                    25, // Optional radius in the center (to create a donut chart effect)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Indicators for Used and Available storage
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Used Storage Indicator
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Color.fromARGB(255, 54, 54, 54),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Used Storage',
                                  style: GoogleFonts.monda(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 17.0, right: 17),
                                  child: Text(
                                    "${usedStorage.toStringAsFixed(2)} GB",
                                    style: GoogleFonts.monda(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Color.fromARGB(255, 134, 134, 134),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Available Storage',
                                  style: GoogleFonts.monda(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 17.0, right: 17),
                                  child: Text(
                                    "${availableStorage.toStringAsFixed(2)} GB",
                                    style: GoogleFonts.monda(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return const Center(child: Text("No data available"));
      },
    );
  }
}
