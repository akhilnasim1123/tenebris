import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 40, left: 0),
        padding: EdgeInsets.all(18),
        height: MediaQuery.of(context).size.height,
        // child: SingleChildScrollView(
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  BootstrapIcons.gear_wide_connected,
                                  color: Color(0xFFB1B1B1),
                                ),

                                iconSize: 25,
                                padding: EdgeInsets.all(3),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            spacing: 10,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 0,
                                children: [
                                  Text(
                                    'Welcome, AKHIL',

                                    style: GoogleFonts.medievalSharp(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB1B1B1),
                                    ),
                                  ),
                                  Text(
                                    'chief',
                                    style: GoogleFonts.medievalSharp(
                                      color: Color(0xFFB1B1B1),
                                    ),
                                  ),
                                ],
                              ),

                              Container(
                                alignment: Alignment.center,
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/profile.jpeg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Okay You Spend',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB1B1B1),
                            ),
                          ),
                          Row(
                            // spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(Icons.currency_rupee, size: 16),
                              Text(
                                '112358',
                                style: GoogleFonts.medievalSharp(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  // color: Color(0xFFB1B1B1)
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.info_outline, size: 16),
                              ),
                            ],
                          ),
                          Text(
                            'Updates Yerstarday',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(height: 10),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10.0,
                                  ), // Optional: Customize border radius
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 5.0,
                                ), // Optional: Padding inside button
                              ),
                              backgroundColor: WidgetStateProperty.all(
                                Color(0xffB1B1B1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 16, color: Colors.black),
                                Text(
                                  'Add Expense',
                                  style: GoogleFonts.medievalSharp(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              GridView.count(
                crossAxisCount:
                    (MediaQuery.of(context).size.width > 600) ? 5 : 4,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 1,
                childAspectRatio: 0.95,
                children: [Card(), Card(), Card(), Card()],
              ),
              Card(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  height: 50, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
