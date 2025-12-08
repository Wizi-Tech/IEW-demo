import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final String name;
  final String price;
  final String distance;
  final int rating;
  final String? imageUrl;
  final String country;
  final String city;
  final String address;
  final int capacity;

  const HotelCard({
    super.key,
    required this.name,
    required this.price,
    required this.distance,
    required this.rating,
    this.imageUrl,
    required this.country,
    required this.city,
    required this.address,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------
          // HOTEL IMAGE
          // ----------------------
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Center(
                    child: Text(
                      "No Image",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // ----------------------
          // NAME + RATING
          // ----------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 18,
                    color: index < rating
                        ? const Color(0xFF1C274C)
                        : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ----------------------
          // PRICE
          // ----------------------
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          // ----------------------
          // DISTANCE
          // ----------------------
          Text(
            distance,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          // ----------------------
          // LOCATION DETAILS (Updated Order)
          // ----------------------
          Text(
            address, // 1. Address
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            city, // 2. City
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            country, // 3. Country
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            "Capacity: $capacity",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          // ----------------------
          // SELECT BUTTON
          // ----------------------
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("Select"),
            ),
          ),
        ],
      ),
    );
  }
}
