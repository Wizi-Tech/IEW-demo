class Hotel {
  final String name;
  final String price;
  final String distance;
  final int rating;
  final DateTime availableStart;
  final DateTime availableEnd;
  final String? imageUrl;

  Hotel({
    required this.name,
    required this.price,
    required this.distance,
    required this.rating,
    required this.availableStart,
    required this.availableEnd,
    this.imageUrl,
  });

  bool isAvailable(DateTime checkIn, DateTime checkOut) {
    return checkIn.isAfter(availableStart.subtract(const Duration(days: 1))) &&
        checkOut.isBefore(availableEnd.add(const Duration(days: 1)));
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      name: json['name']?.toString() ?? 'Unknown Hotel',
      price: json['price']?.toString() ?? 'Price not available',
      distance: json['distance']?.toString() ?? 'Distance unknown',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      availableStart: json['available_start'] != null 
          ? DateTime.tryParse(json['available_start'].toString()) ?? DateTime.now()
          : DateTime.now(),
      availableEnd: json['available_end'] != null 
          ? DateTime.tryParse(json['available_end'].toString()) ?? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
