import 'package:flutter/material.dart';
import 'storage_service.dart';

class StoragePieChartWidget extends StatelessWidget {
  final StorageService storageService = StorageService();

  StoragePieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: storageService.getStorageInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        }

        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        if (snapshot.hasData) {
          final storageData = snapshot.data!;

          // Prepare data for display
          double totalStorage = storageData['total']!;
          double availableStorage = storageData['available']!;
          double usedStorage = storageData['used']!;
          // double remainingStorage = totalStorage - availableStorage - usedStorage;

          // // // Calculate percentages
          // double totalStoragrPercentage = (totalStorage / totalStorage) * 100;
          // double availablePercentage = (availableStorage / totalStorage) * 100;
          // double usedPercentage = (usedStorage / totalStorage) * 100;
          // double remainingPercentage = (remainingStorage / totalStorage) * 100;

          // Display the storage data as text
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Total Storage: ${totalStorage.toStringAsFixed(2)} GB",
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    "Available: ${availableStorage.toStringAsFixed(2)} GB",
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    "Used : ${usedStorage.toStringAsFixed(2)} GB",
                    style: TextStyle(fontSize: 17),
                  ),
                  // Text("Remaining : ${remainingStorage.toStringAsFixed(2)} GB"),
                ],
              ),
              // Display percentage data
              // // Column(
              // //   children: [
              // //     Text("total S P: ${totalStoragrPercentage.toStringAsFixed(2)}%"),
              // //     Text("Available S P: ${availablePercentage.toStringAsFixed(2)}%"),
              // // Text("Used S P: ${usedPercentage.toStringAsFixed(2)}%"),
              // // Text("Remaining S P: ${remainingPercentage.toStringAsFixed(2)}%"),

              //   ],
              // )
            ],
          );
        }

        return const Text("No data available");
      },
    );
  }
}
