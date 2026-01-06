import 'package:flutter/material.dart';

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
            _buildProfileField('Nick', 'Nick'),
            _buildProfileField('Name', 'John Doe'),
            _buildProfileField('Email', 'mail@mail.com'),
          ],
        ),
      ),
    );
  }
}

Widget _buildProfileField(String label, String initialValue) {
  Color fillColor = const Color(0xFFE5E5E5);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LABEL
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ),

        // TEXT FORM FIELD
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextFormField(
            initialValue: initialValue,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              suffixIcon: label != 'Email'
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 30.0,
                      ), 
                      child: Icon(
                        Icons.edit_outlined,
                        size: 24,
                        color: Colors.black,
                      ),
                    )
                  : null, 
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
