import 'package:flutter/material.dart';
import 'login.dart'; // Add this import

void main() {
  runApp(const UniRidesHomeApp());
}

class UniRidesHomeApp extends StatelessWidget {
  const UniRidesHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni-Rides Dashboard',
      theme: ThemeData(
        primaryColor: const Color(0xFF4F46E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final int _selectedTabIndex = 0;
  int _requestsTabIndex = 0; // 0 for received, 1 for sent
  final bool _isProfileMenuOpen = false;
  final bool _isMobileMenuOpen = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> _upcomingRides = [];
  List<Map<String, dynamic>> _myRides = [];
  List<Map<String, dynamic>> _receivedRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];

  late TabController _tabController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Simulate loading data
    _loadUpcomingRides();
    _loadMyRides();
    _loadRideRequests();
  }

  void _loadUpcomingRides() {
    // Mock data - replace with actual API call
    setState(() {
      _upcomingRides = [
        {
          '_id': '1',
          'departure': 'Campus Main Gate',
          'destination': 'Downtown Mall',
          'rideDate': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
          'rideTime': '14:30',
          'price': 15.00,
          'availableSeats': 3,
          'status': 'Offered',
          'driver': {'fullName': 'John Smith'},
          'vehicleModel': 'Honda Civic',
          'notes': 'Pick up from main entrance',
        },
      ];
    });
  }

  void _loadMyRides() {
    setState(() {
      _myRides = [
        {
          '_id': '2',
          'departure': 'University Library',
          'destination': 'Airport',
          'rideDate': DateTime.now()
              .add(const Duration(days: 2))
              .toIso8601String(),
          'rideTime': '16:00',
          'price': 25.00,
          'availableSeats': 2,
          'status': 'Offered',
          'driver': {'fullName': 'Me'},
          'vehicleModel': 'Toyota Camry',
        },
      ];
    });
  }

  void _loadRideRequests() {
    setState(() {
      _receivedRequests = [
        {
          '_id': 'req1',
          'status': 'pending',
          'message': 'Hi! Can I join your ride?',
          'passenger': {'fullName': 'Alice Johnson'},
          'ride': {
            'departure': 'Campus',
            'destination': 'Mall',
            'rideDate': DateTime.now()
                .add(const Duration(days: 1))
                .toIso8601String(),
            'rideTime': '14:30',
            'price': 15.00,
          },
        },
      ];

      _sentRequests = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isTablet = screenWidth >= 768;
    final logoFontSize = screenWidth < 400 ? 24.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(context, screenWidth, logoFontSize),
      drawer: !isTablet ? _buildMobileDrawer() : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            _buildWelcomeBanner(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.02),
            _buildQuickActionsBar(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.02),
            _buildTabsSection(screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    double screenWidth,
    double logoFontSize,
  ) {
    final isTablet = screenWidth >= 768;

    return AppBar(
      title: Center(
        child: Text(
          'Uni-Rides',
          style: TextStyle(
            fontFamily: 'Pacifico',
            color: const Color(0xFF4F46E5),
            fontSize: logoFontSize,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
      actions: isTablet
          ? [
              TextButton(onPressed: () {}, child: const Text('About Us')),
              PopupMenuButton<String>(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF4F46E5),
                        child: Text(
                          'JD',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 'signout') {
                    // Clear any stored user data
                    // localStorage.removeItem('token'); // If using web storage

                    // Navigate to login page and clear navigation stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('My Profile'),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Account Settings'),
                  ),
                  const PopupMenuItem(
                    value: 'signout',
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ]
          : [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4F46E5)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);

              // Navigate to login page and clear navigation stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, John!',
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: TextStyle(
                        fontSize: screenWidth < 400 ? 14 : 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '32',
                  'Rides Taken',
                  const Color(0xFF4F46E5),
                  screenWidth,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  '18',
                  'Rides Shared',
                  const Color(0xFF10B981),
                  screenWidth,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  '\$215',
                  'Saved',
                  const Color(0xFF374151),
                  screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    double screenWidth,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth < 400 ? 18 : 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth < 400 ? 11 : 13,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsBar(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                'Book Ride',
                Icons.local_taxi,
                const Color(0xFF4F46E5),
                () {},
                screenWidth,
              ),
              _buildActionButton(
                'Offer a Ride',
                Icons.drive_eta,
                const Color(0xFF10B981),
                () {},
                screenWidth,
              ),
              _buildActionButton(
                'View Schedule',
                Icons.calendar_today,
                Colors.grey,
                () {},
                screenWidth,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search rides...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    double screenWidth,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        text,
        style: TextStyle(fontSize: screenWidth < 400 ? 12 : 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTabsSection(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Headers
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 18),
                      SizedBox(width: 8),
                      Text('Upcoming'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications, size: 18),
                      SizedBox(width: 8),
                      Text('Requests'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drive_eta, size: 18),
                      SizedBox(width: 8),
                      Text('My Rides'),
                    ],
                  ),
                ),
              ],
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF4F46E5),
            ),
          ),
          // Tab Content
          SizedBox(
            height: screenHeight * 0.6,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingRidesTab(screenWidth),
                _buildRideRequestsTab(screenWidth),
                _buildMyRidesTab(screenWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingRidesTab(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: _upcomingRides.isEmpty
          ? _buildEmptyState(
              'No upcoming rides found.',
              'Be the first to offer one!',
              Icons.directions_car,
            )
          : ListView.builder(
              itemCount: _upcomingRides.length,
              itemBuilder: (context, index) =>
                  _buildRideCard(_upcomingRides[index], false, screenWidth),
            ),
    );
  }

  Widget _buildRideRequestsTab(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          // Sub-tabs for requests
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _requestsTabIndex = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _requestsTabIndex == 0
                        ? const Color(0xFF4F46E5)
                        : Colors.grey[200],
                    foregroundColor: _requestsTabIndex == 0
                        ? Colors.white
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Received'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _requestsTabIndex = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _requestsTabIndex == 1
                        ? const Color(0xFF4F46E5)
                        : Colors.grey[200],
                    foregroundColor: _requestsTabIndex == 1
                        ? Colors.white
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _requestsTabIndex == 0
                ? (_receivedRequests.isEmpty
                      ? _buildEmptyState(
                          'No new requests received.',
                          '',
                          Icons.notifications,
                        )
                      : ListView.builder(
                          itemCount: _receivedRequests.length,
                          itemBuilder: (context, index) => _buildRequestCard(
                            _receivedRequests[index],
                            true,
                            screenWidth,
                          ),
                        ))
                : (_sentRequests.isEmpty
                      ? _buildEmptyState(
                          'You have not sent any requests.',
                          '',
                          Icons.send,
                        )
                      : ListView.builder(
                          itemCount: _sentRequests.length,
                          itemBuilder: (context, index) => _buildRequestCard(
                            _sentRequests[index],
                            false,
                            screenWidth,
                          ),
                        )),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRidesTab(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: _myRides.isEmpty
          ? _buildEmptyState(
              'You haven\'t offered any rides yet.',
              'Offer your first ride!',
              Icons.drive_eta,
            )
          : ListView.builder(
              itemCount: _myRides.length,
              itemBuilder: (context, index) =>
                  _buildRideCard(_myRides[index], true, screenWidth),
            ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: const Color(0xFF6B7280)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRideCard(
    Map<String, dynamic> ride,
    bool isMyRide,
    double screenWidth,
  ) {
    final statusColor = _getStatusColor(ride['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateTime.parse(ride['rideDate']).day}/${DateTime.parse(ride['rideDate']).month}, ${ride['rideTime']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${ride['departure']} → ${ride['destination']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Driver: ${ride['driver']['fullName']}'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${ride['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${ride['availableSeats']} seats left',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ride['vehicleModel'] != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Text('Vehicle: ${ride['vehicleModel']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (ride['notes'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(ride['notes']),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    if (isMyRide &&
                        ride['status'] != 'Cancelled' &&
                        ride['status'] != 'Completed') ...[
                      ElevatedButton(
                        onPressed: () => _cancelRide(ride['_id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel Ride'),
                      ),
                    ] else if (!isMyRide && ride['status'] == 'Offered') ...[
                      ElevatedButton(
                        onPressed: () => _requestRide(ride),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                        ),
                        child: const Text('Request Ride'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
    bool isReceived,
    double screenWidth,
  ) {
    final statusColor = _getStatusColor(request['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '\$${request['ride']['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${request['ride']['departure']} → ${request['ride']['destination']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              isReceived
                  ? 'From: ${request['passenger']['fullName']}'
                  : 'To: ${request['ride']['driver'] ?? 'Driver'}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            if (request['message'] != null &&
                request['message'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${request['message']}"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            if (isReceived && request['status'] == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        _updateRequestStatus(request['_id'], 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        _updateRequestStatus(request['_id'], 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'offered':
        return Colors.purple;
      case 'full':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _requestRide(Map<String, dynamic> ride) {
    showDialog(
      context: context,
      builder: (context) {
        String message = '';
        return AlertDialog(
          title: const Text('Request Ride'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Request to join the ride from ${ride['departure']} to ${ride['destination']}?',
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => message = value,
                decoration: const InputDecoration(
                  hintText: 'Add a message (optional)...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendRideRequest(ride['_id'], message);
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
  }

  void _sendRideRequest(String rideId, String message) {
    // Simulate API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ride request sent successfully!')),
    );
  }

  void _updateRequestStatus(String requestId, String status) {
    // Simulate API call
    setState(() {
      final index = _receivedRequests.indexWhere(
        (req) => req['_id'] == requestId,
      );
      if (index != -1) {
        _receivedRequests[index]['status'] = status;
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Request $status successfully!')));
  }

  void _cancelRide(String rideId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text(
          'Are you sure you want to cancel this ride? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _myRides.removeWhere((ride) => ride['_id'] == rideId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ride cancelled successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
