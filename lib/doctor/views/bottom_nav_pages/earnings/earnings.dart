import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DoctorEarningsPage extends StatefulWidget {
  const DoctorEarningsPage({super.key});

  @override
  State<DoctorEarningsPage> createState() => _DoctorEarningsPageState();
}

class _DoctorEarningsPageState extends State<DoctorEarningsPage> {
  bool isLoading = true;
  double totalEarnings = 0.0;
  int totalAppointments = 0;
  int completedAppointments = 0;
  int cancelledAppointments = 0;
  int upcomingAppointments = 0;
  double thisMonthEarnings = 0.0;
  List<Map<String, dynamic>> recentTransactions = [];
  Map<String, double> monthlyEarnings = {};

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  Future<void> _loadEarningsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("Fetching appointments for doctor: ${user.uid}");

      // Fetch all appointments for this doctor
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: user.uid)
          .get();

      print("Found ${appointmentsSnapshot.docs.length} appointments");

      double earnings = 0.0;
      int total = 0;
      int completed = 0;
      int cancelled = 0;
      int upcoming = 0;
      double monthEarnings = 0.0;
      List<Map<String, dynamic>> transactions = [];
      Map<String, double> monthlyData = {};

      final now = DateTime.now();

      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        total++;

        final status = (data['status'] as String?)?.toLowerCase().trim() ?? '';
        
        // Try to get fee from different possible field names
        double fee = 0.0;
        if (data['consultationFee'] != null) {
          fee = (data['consultationFee'] is int) 
              ? (data['consultationFee'] as int).toDouble() 
              : (data['consultationFee'] as double);
        } else if (data['appointmentFee'] != null) {
          fee = (data['appointmentFee'] is int) 
              ? (data['appointmentFee'] as int).toDouble() 
              : (data['appointmentFee'] as double);
        }

        // Get patient/owner name
        String patientName = data['ownerName'] ?? 
                            data['patientName'] ?? 
                            data['userName'] ?? 
                            data['name'] ?? 
                            'Unknown Patient';

        // Get timestamp
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ??
            (data['appointmentDate'] as Timestamp?)?.toDate();

        print("Appointment: $patientName, Status: $status, Fee: $fee");

        // Count by status
        if (status == 'completed') {
          completed++;
          earnings += fee;

          // Check if this month
          if (timestamp != null &&
              timestamp.year == now.year &&
              timestamp.month == now.month) {
            monthEarnings += fee;
          }

          // Add to monthly earnings
          if (timestamp != null) {
            final monthKey = DateFormat('MMM yyyy').format(timestamp);
            monthlyData[monthKey] = (monthlyData[monthKey] ?? 0.0) + fee;
          }

          // Add to recent transactions
          transactions.add({
            'id': doc.id,
            'patientName': patientName,
            'amount': fee,
            'date': timestamp ?? now,
            'status': status,
          });
        } else if (status == 'cancelled' || status == 'rejected') {
          cancelled++;
        } else if (status == 'pending' || 
                   status == 'upcoming' || 
                   status == 'confirmed' || 
                   status == 'approved' ||
                   status == 'paymentverified') {
          upcoming++;
        }
      }

      print("Total Earnings: $earnings, Completed: $completed");

      // Sort transactions by date (most recent first)
      transactions.sort((a, b) {
        final dateA = a['date'] as DateTime;
        final dateB = b['date'] as DateTime;
        return dateB.compareTo(dateA);
      });

      setState(() {
        totalEarnings = earnings;
        totalAppointments = total;
        completedAppointments = completed;
        cancelledAppointments = cancelled;
        upcomingAppointments = upcoming;
        thisMonthEarnings = monthEarnings;
        recentTransactions = transactions.take(10).toList();
        monthlyEarnings = monthlyData;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading earnings data: $e");
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading earnings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF199A8E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Earnings',
          style: TextStyle(
            color: Color(0xFF199A8E),
            fontWeight: FontWeight.bold,
            fontFamily: "bolditalic",
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF199A8E),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading earnings data...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEarningsData,
              color: Color(0xFF199A8E),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF199A8E), Color(0xFF53B7A4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        screen.width * 0.06,
                        screen.height * 0.03,
                        screen.width * 0.06,
                        screen.height * 0.03,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: screen.width * 0.1,
                          ),
                          SizedBox(height: screen.height * 0.01),
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              fontSize: screen.width * 0.038,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screen.height * 0.005),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PKR ',
                                style: TextStyle(
                                  fontSize: screen.width * 0.06,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                totalEarnings.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: screen.width * 0.09,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screen.height * 0.01),
                          
                        ],
                      ),
                    ),

                    SizedBox(height: screen.height * 0.02),

                    // Statistics Cards
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screen.width * 0.04,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Statistics',
                            style: TextStyle(
                              fontSize: screen.width * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF199A8E),
                              fontFamily: 'bolditalic'
                            ),
                          ),
                          SizedBox(height: screen.height * 0.012),

                          // Statistics Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.75, // Increased from 1.7 to give slightly more height
                            children: [
                              _buildStatCard(
                                'Total',
                                totalAppointments.toString(),
                                Icons.calendar_today,
                                Colors.blue,
                                screen,
                              ),
                              _buildStatCard(
                                'Completed',
                                completedAppointments.toString(),
                                Icons.check_circle,
                                Colors.green,
                                screen,
                              ),
                              _buildStatCard(
                                'Upcoming',
                                upcomingAppointments.toString(),
                                Icons.pending,
                                Colors.orange,
                                screen,
                              ),
                              _buildStatCard(
                                'Cancelled',
                                cancelledAppointments.toString(),
                                Icons.cancel,
                                Colors.red,
                                screen,
                              ),
                            ],
                          ),

                          SizedBox(height: screen.height * 0.02),

                          // Monthly Breakdown
                          if (monthlyEarnings.isNotEmpty) ...[
                            Text(
                              'Monthly Breakdown',
                              style: TextStyle(
                                fontSize: screen.width * 0.042,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF199A8E),
                                  fontFamily: 'bolditalic'

                              ),
                            ),
                            SizedBox(height: screen.height * 0.01),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screen.width * 0.035),
                                child: Column(
                                  children: monthlyEarnings.entries
                                      .take(6)
                                      .map((entry) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  entry.key,
                                                  style: TextStyle(
                                                    fontSize:
                                                        screen.width * 0.036,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  'PKR ${entry.value.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screen.width * 0.038,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF199A8E),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: screen.height * 0.02),
                          ],

                          // Recent Transactions
                          Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: screen.width * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF199A8E),
                                fontFamily: 'bolditalic'

                            ),
                          ),
                          SizedBox(height: screen.height * 0.01),

                          if (recentTransactions.isEmpty)
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screen.width * 0.08),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: screen.width * 0.12,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No completed appointments yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: screen.width * 0.036,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            ...recentTransactions.map((transaction) {
                              return _buildTransactionCard(
                                transaction,
                                screen,
                              );
                            }).toList(),

                          SizedBox(height: screen.height * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Size screen,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.02,
          vertical: screen.width * 0.025,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Icon(
              icon,
              color: color,
              size: screen.width * 0.065,
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: screen.width * 0.06,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0, // Tight line height
              ),
            ),
            SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screen.width * 0.03,
                color: Colors.grey[600],
                height: 1.1, // Tight line height
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, Size screen) {
    final date = transaction['date'] as DateTime;
    final dateStr = DateFormat('MMM dd, yyyy').format(date);

    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.035,
          vertical: 4,
        ),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF199A8E).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.payment,
            color: Color(0xFF199A8E),
            size: 20,
          ),
        ),
        title: Text(
          transaction['patientName'] ?? 'Unknown',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screen.width * 0.036,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dateStr,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: screen.width * 0.03,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'PKR ${transaction['amount'].toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screen.width * 0.038,
                color: Color(0xFF199A8E),
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Paid',
                style: TextStyle(
                  fontSize: screen.width * 0.024,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}