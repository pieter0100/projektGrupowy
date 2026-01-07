import 'package:flutter/material.dart';
import 'package:projekt_grupowy/widgets/profile_field.dart';

class PersonalData extends StatelessWidget {
  const PersonalData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Data'),
        backgroundColor: Color(0xFFE5E5E5),
        scrolledUnderElevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 24.0),

            // PROFILE PICTURE
            Center(
              child: Text(
                "Profile picture",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // AVATAR IMAGE
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://www.krauseschocolates.com/cdn/shop/products/NUMBER_POP_LARGE-_6_7_1024x1024.jpg?v=1496260776',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // EDIT ICON
                  Positioned(
                    bottom: 0,
                    right: -15,
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // FORM FIELDS
            ProfileField(label: 'Nick:', initialValue: 'Nick'),
            ProfileField(label: 'Name:', initialValue: 'John Doe'),
            ProfileField(label: 'Email:', initialValue: 'mail@mail.com'),
          ],
        ),
      ),
    );
  }
}