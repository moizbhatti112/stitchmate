import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/mybutton.dart';

class JetWelcome extends StatelessWidget {
  const JetWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    double responsiveFont(double fontSize) {
      return size.width * (fontSize / 390); // Adjusting according to iPhone 14 width
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/plane.png',height: size.height*0.3,width: double.infinity,fit: BoxFit.cover,),
              SizedBox(height: size.height * 0.05),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height*0.04,),
                  Text(
                    'Private Jet Services',
                    style: TextStyle(
                      fontSize: responsiveFont(20),
                      fontFamily: 'PP Neue Montreal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  // Generate three different feature items
                  _buildFeatureItem(size, responsiveFont, 0),
                  _buildFeatureItem(size, responsiveFont, 1),
                  _buildFeatureItem(size, responsiveFont, 2),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
            Divider(color: grey),
            SizedBox(height: size.height * 0.05),
            MyButton(
              text: 'Continue',
              onPressed: () {
                Navigator.pushNamed(context, '/jetbooking');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(Size size, double Function(double) responsiveFont, int index) {
    // Define different titles and descriptions based on the index
    final List<Map<String, String>> features = [
      {
        'title': 'Fly with ultimate luxury ',
        'description': 'Enjoy seamless travel aboard our exclusive private jets, tailored for comfort and discretion.'
      },
      {
        'title': 'Personalized flight experience',
        'description': 'Custom itineraries, gourmet catering, and dedicated concierge service for all your travel needs.'
      },
      {
        'title': 'Global access and flexibility',
        'description': 'Access to over 5,000 airports worldwide with no queues, flexible departure times, and simplified check-in.'
      },
    ];

    // Get the correct feature based on index
    final feature = features[index];
    
    // Check if title needs to be split
    List<String> titleLines = _splitTextIntoLines(feature['title']!);
    
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset('assets/icons/tick.svg'),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display first line of title
                Text(
                  titleLines[0],
                  style: TextStyle(
                    fontSize: responsiveFont(16),
                    fontFamily: 'PP Neue Montreal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Display second line of title if exists
                if (titleLines.length > 1)
                  Text(
                    titleLines[1],
                    style: TextStyle(
                      fontSize: responsiveFont(16),
                      fontFamily: 'PP Neue Montreal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                SizedBox(height: size.height * 0.01),
                Text(
                  feature['description']!,
                  style: TextStyle(
                    fontSize: responsiveFont(14),
                    fontFamily: 'PP Neue Montreal',
                    fontWeight: FontWeight.w500,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to split text that might be too long
  List<String> _splitTextIntoLines(String text) {
    // This is a simple split logic - if text is longer than 30 chars, try to split at a space
    if (text.length > 30) {
      final middleIndex = text.length ~/ 2;
      int splitIndex = text.indexOf(' ', middleIndex);
      
      if (splitIndex == -1 || splitIndex == text.length - 1) {
        // If no space found or it's at the end, just return the whole text
        return [text];
      }
      
      return [
        text.substring(0, splitIndex),
        text.substring(splitIndex + 1),
      ];
    }
    
    return [text];
  }
}