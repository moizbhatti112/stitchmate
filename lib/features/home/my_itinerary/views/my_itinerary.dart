import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/ground_transport/services/order_service.dart';
import 'package:stitchmate/features/home/plane_transport/services/plane_order_service.dart';

class MyItinerary extends StatefulWidget {
  const MyItinerary({super.key});

  @override
  State<MyItinerary> createState() => _MyItineraryState();
}

class _MyItineraryState extends State<MyItinerary>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final PlaneOrderService _planeOrderService = PlaneOrderService();
  Stream<List<Map<String, dynamic>>>? _groundOrdersStream;
  Stream<List<Map<String, dynamic>>>? _planeOrdersStream;
  late final TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeStreams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MyItinerary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.key != oldWidget.key) {
      _initializeStreams();
    }
  }

  void _initializeStreams() {
    setState(() {
      _groundOrdersStream = _orderService.getOrdersStream();
      _planeOrdersStream = _planeOrderService.getPlaneOrdersStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text('My Itinerary'),
          backgroundColor: bgColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Ground Transport'),
              Tab(text: 'Plane Bookings'),
            ],
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeStreams,
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildGroundTransportOrders(), _buildPlaneOrders()],
        ),
      ),
    );
  }

  Widget _buildGroundTransportOrders() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _groundOrdersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;

        if (orders.isEmpty) {
          return const Center(child: Text('No ground transport orders found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ground Transport Order #${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Pickup', order['pickup']),
                    _buildInfoRow('Dropoff', order['dropoff']),
                    _buildInfoRow('Date', order['date']),
                    _buildInfoRow('Time', order['time']),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaneOrders() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _planeOrdersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;

        if (orders.isEmpty) {
          return const Center(child: Text('No plane bookings found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plane Booking #${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Departure', order['departure']),
                    _buildInfoRow('Arrival', order['arrival']),
                    _buildInfoRow('Date', order['date']),
                    _buildInfoRow('Time', order['time']),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 158, 158, 158),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
