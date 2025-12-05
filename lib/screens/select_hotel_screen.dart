import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/hotel_card.dart';
import '../models/hotel.dart';

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
      final data = response as List<dynamic>;

      setState(() {
        _hotels = data.map((json) => Hotel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching hotels: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading hotels: $e')),
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
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = DateTime(2030);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? now)
          : (_checkOut ?? _checkIn?.add(const Duration(days: 1)) ?? now),
      firstDate: isCheckIn ? firstDate : (_checkIn ?? firstDate),
      lastDate: lastDate,
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

  // ---------------------------------------------------------
  // ---------------- DATE FILTER BOX ------------------------
  // ---------------------------------------------------------
  Widget _buildDateFilter(BuildContext context, String label,
      {bool isActive = false, VoidCallback? onClear}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.black : Colors.grey.shade300,
          width: isActive ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: isActive ? Colors.black : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          if (isActive && onClear != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // ---------------- FILTER ICON BOX ------------------------
  // ---------------------------------------------------------
  Widget _buildFilterIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.tune,
        size: 20,
        color: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Select Hotel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // ---------------- FILTERS ----------------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: _buildDateFilter(
                      context,
                      _checkIn != null
                          ? DateFormat('dd MMM yyyy').format(_checkIn!)
                          : 'Check-in',
                      isActive: _checkIn != null,
                      onClear: () {
                        setState(() {
                          _checkIn = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: _buildDateFilter(
                      context,
                      _checkOut != null
                          ? DateFormat('dd MMM yyyy').format(_checkOut!)
                          : 'Check-out',
                      isActive: _checkOut != null,
                      onClear: () {
                        setState(() {
                          _checkOut = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterIcon(),
              ],
            ),
          ),
          // ---------------- HOTEL LIST ----------------
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHotels.isEmpty
                    ? const Center(child: Text('No hotels available for selected dates'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _filteredHotels[index];
                          return HotelCard(
                            name: hotel.name,
                            price: hotel.price,
                            distance: hotel.distance,
                            rating: hotel.rating,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
