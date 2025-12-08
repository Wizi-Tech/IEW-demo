import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/hotel_card.dart';
import '../models/hotel.dart';
import 'add_hotel_screen.dart';

class SelectHotelScreen extends StatefulWidget {
  const SelectHotelScreen({super.key});

  @override
  State<SelectHotelScreen> createState() => _SelectHotelScreenState();
}

class _SelectHotelScreenState extends State<SelectHotelScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;

  List<Hotel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    try {
      final response = await Supabase.instance.client.from('Hotel').select();

      setState(() {
        _hotels =
            (response as List).map((json) => Hotel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading hotels: $e")),
        );
      }
    }
  }

  List<Hotel> get _filteredHotels {
    if (_checkIn == null || _checkOut == null) {
      return _hotels;
    }
    return _hotels.where((hotel) {
      return hotel.isAvailable(_checkIn!, _checkOut!);
    }).toList();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? DateTime.now())
          : (_checkOut ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
            _checkOut = null;
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  Widget _buildDateBox(String label, bool isActive, VoidCallback? clearFn) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.black : Colors.grey.shade300,
          width: isActive ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 18, color: isActive ? Colors.black : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isActive)
            GestureDetector(
              onTap: clearFn,
              child: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.tune, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Hotel"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          // DATE FILTERS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: _buildDateBox(
                      _checkIn != null
                          ? DateFormat('dd MMM yyyy').format(_checkIn!)
                          : "Check-in",
                      _checkIn != null,
                      () => setState(() => _checkIn = null),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: _buildDateBox(
                      _checkOut != null
                          ? DateFormat('dd MMM yyyy').format(_checkOut!)
                          : "Check-out",
                      _checkOut != null,
                      () => setState(() => _checkOut = null),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterIcon(),
              ],
            ),
          ),

          // HOTEL LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHotels.isEmpty
                    ? const Center(child: Text("No hotels available"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredHotels.length,
                        itemBuilder: (context, index) {
                          final h = _filteredHotels[index];
                          return HotelCard(
                            name: h.name,
                            price: h.price,
                            distance: h.distance,
                            rating: h.rating,
                            imageUrl: h.imageUrl,
                            country: h.country ?? "Unknown Country",
                            city: h.city ?? "Unknown City",
                            address: h.address ?? "No Address",
                            capacity: h.capacity ?? 0,
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHotelScreen()),
          );
          if (added == true) _fetchHotels();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
