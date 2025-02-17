import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List names = ['Apps', 'Photos', 'Videos', 'Audio', 'Other files'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 0,
              ),
              child: GridView.builder(
                  itemCount: names.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (builder, index) {
                    names = names;
                    return Stack(
                      children: [
                        //top-left container
                        Positioned(
                          top: 15,
                          left: 2,
                          child: Container(
                            height: 50,
                            width: 76,
                            decoration: const BoxDecoration(
                                // color: Color.fromARGB(255, 255, 160, 0),
                                color: Color.fromARGB(255, 13, 20, 38),
                                border: Border(
                                  bottom: BorderSide.none,
                                  left: BorderSide.none,
                                  right: BorderSide.none,
                                  top: BorderSide.none,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                )),
                          ),
                        ),

                        //top-right container
                        Positioned(
                          top: 25,
                          left: 75,
                          child: Container(
                            height: 50,
                            width: 72,
                            decoration: const BoxDecoration(
                                // color: Color.fromARGB(255, 255, 160, 0),
                                color: Color.fromARGB(255, 13, 20, 38),
                                border: Border(
                                  left: BorderSide.none,
                                  right: BorderSide.none,
                                  top: BorderSide.none,
                                  bottom: BorderSide.none,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(10),
                                )),
                          ),
                        ),

                        //center container
                        Positioned(
                          top: 40,
                          child: Container(
                            width: 150,
                            height: 90,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 20,
                            ),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              border: Border(
                                  // top: BorderSide(
                                  //   width: 1,
                                  //   color: Colors.white,
                                  // ),
                                  top: BorderSide.none),
                              // color: Color.fromARGB(255, 255, 193, 7),
                              color: Color.fromARGB(255, 13, 20, 38),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.photo_size_select_actual_rounded,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      names[index].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        // color: Color.fromARGB(255, 43, 43, 43),
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      "16gb",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        // color: Color.fromARGB(143, 19, 19, 19),
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
