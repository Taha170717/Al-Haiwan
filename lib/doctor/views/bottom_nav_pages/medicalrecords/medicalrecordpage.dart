import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/appointment_model.dart';

class MedicalRecordPage extends StatefulWidget {
  final String doctorId;
  final String? patientUserId;
  final String? patientName;

  const MedicalRecordPage({
    super.key,
    required this.doctorId,
    this.patientUserId,
    this.patientName,
  });

  @override
  State<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  static const Color kTeal = Color(0xFF199A8E);

  String _searchQuery = '';
  String _selectedPatient = 'All Patients';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final isTablet = screen.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.patientName != null
                ? 'Medical Records • ${widget.patientName!}'
                : 'Patient History',
            style: const TextStyle(color: kTeal, fontWeight: FontWeight.w700, fontFamily: 'bolditalic'),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kTeal),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kTeal),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screen.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilter(screen),

            SizedBox(height: screen.height * 0.016),

            _HeaderNote(
              doctorId: widget.doctorId,
              patientName: widget.patientName,
              selectedPatient: _selectedPatient,
            ),

            SizedBox(height: screen.height * 0.016),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('doctorId', isEqualTo: widget.doctorId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: kTeal));
                  }
                  if (snapshot.hasError) {
                    return _EmptyState(
                      title: 'Failed to load records',
                      message: 'Please try again later.',
                      icon: Icons.error_outline,
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  List<AppointmentModel> records = docs
                      .map((d) => AppointmentModel.fromFirestore(d))
                      .where((a) {
                    final isCompleted = (a.status.toLowerCase().trim() == 'completed');
                    final isForPatient = widget.patientUserId == null
                        ? true
                        : a.userId == widget.patientUserId;

                    // Apply search filter
                    final matchesSearch = _searchQuery.isEmpty ||
                        a.ownerName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        a.petName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        a.problem
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());

                    return isCompleted && isForPatient && matchesSearch;
                  })
                      .toList();

                  // Sort newest first
                  records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (records.isEmpty) {
                    return _EmptyState(
                      title: _searchQuery.isNotEmpty
                          ? 'No matching records'
                          : 'No completed appointments',
                      message: _searchQuery.isNotEmpty
                          ? 'Try adjusting your search criteria.'
                          : widget.patientUserId == null
                              ? 'Completed records will appear here once available.'
                              : 'No completed records found for this patient.',
                      icon: _searchQuery.isNotEmpty
                          ? Icons.search_off
                          : Icons.history,
                    );
                  }

                  return _buildPatientHistoryList(records, screen, isTablet);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(Size screen) {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by owner, pet name, or condition...',
              prefixIcon: const Icon(Icons.search, color: kTeal),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.04,
                vertical: screen.height * 0.015,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientHistoryList(
      List<AppointmentModel> records, Size screen, bool isTablet) {
    // Group records by patient (owner + pet combination)
    Map<String, List<AppointmentModel>> groupedRecords = {};

    for (var record in records) {
      String patientKey = '${record.ownerName}-${record.petName}';
      if (!groupedRecords.containsKey(patientKey)) {
        groupedRecords[patientKey] = [];
      }
      groupedRecords[patientKey]!.add(record);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: groupedRecords.length,
      separatorBuilder: (_, __) => SizedBox(height: screen.height * 0.02),
      itemBuilder: (context, index) {
        String patientKey = groupedRecords.keys.elementAt(index);
        List<AppointmentModel> patientRecords = groupedRecords[patientKey]!;

        return _PatientHistoryGroup(
          patientKey: patientKey,
          records: patientRecords,
          isTablet: isTablet,
        );
      },
    );
  }
}

class _PatientHistoryGroup extends StatefulWidget {
  final String patientKey;
  final List<AppointmentModel> records;
  final bool isTablet;

  const _PatientHistoryGroup({
    required this.patientKey,
    required this.records,
    required this.isTablet,
  });

  @override
  State<_PatientHistoryGroup> createState() => _PatientHistoryGroupState();
}

class _PatientHistoryGroupState extends State<_PatientHistoryGroup> {
  bool _isExpanded = false;
  static const Color kTeal = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final firstRecord = widget.records.first;
    final totalVisits = widget.records.length;
    final lastVisit = widget.records.first.createdAt;
    final firstVisit = widget.records.last.createdAt;

    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            // Patient Header
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(screen.width * 0.04),
                child: Row(
                  children: [
                    // Patient Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: kTeal.withOpacity(0.12),
                      child: const Icon(Icons.pets, color: kTeal, size: 24),
                    ),

                    SizedBox(width: screen.width * 0.03),

                    // Patient Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  firstRecord.petName.isNotEmpty
                                      ? firstRecord.petName
                                      : 'Unknown Pet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: screen.width * 0.042,
                                    color: Colors.grey[900],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$totalVisits visit${totalVisits > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: kTeal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screen.width * 0.03,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screen.height * 0.004),
                          Text(
                            'Owner: ${firstRecord.ownerName.isNotEmpty ? firstRecord.ownerName : 'Unknown'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screen.width * 0.035,
                            ),
                          ),
                          SizedBox(height: screen.height * 0.006),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey[500]),
                              SizedBox(width: 4),
                              Text(
                                'Last visit: ${DateFormat('MMM dd, yyyy').format(lastVisit)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: screen.width * 0.032,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Expand Icon
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: kTeal,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Records
            if (_isExpanded) ...[
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.records.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final record = widget.records[index];
                  return _RecordCard(
                    appointment: record,
                    isTablet: widget.isTablet,
                    isInGroup: true,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderNote extends StatelessWidget {
  final String doctorId;
  final String? patientName;
  final String selectedPatient;

  const _HeaderNote({
    required this.doctorId,
    this.patientName,
    required this.selectedPatient,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF199A8E).withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF199A8E).withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(screen.width * 0.035),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, color: Color(0xFF199A8E)),
          ),
          SizedBox(width: screen.width * 0.03),
          Expanded(
            child: Text(
              patientName != null
                  ? 'Complete medical history for $patientName'
                  : 'Complete patient history for all your patients',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: screen.width * 0.036,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isTablet;
  final bool isInGroup;

  const _RecordCard({
    required this.appointment,
    required this.isTablet,
    this.isInGroup = false,
  });

  static const Color kTeal = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return InkWell(
      onTap: () => _showDetailedView(context),
      borderRadius: BorderRadius.circular(isInGroup ? 8 : 16),
      child: Container(
        padding: EdgeInsets.all(screen.width * (isInGroup ? 0.03 : 0.04)),
        decoration: BoxDecoration(
          color: isInGroup ? Colors.transparent : Colors.white,
          borderRadius: isInGroup ? null : BorderRadius.circular(16),
          border: isInGroup
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and basic info
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(appointment.createdAt),
                    style: TextStyle(
                      color: kTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: screen.width * 0.032,
                    ),
                  ),
                ),

                if (appointment.selectedTime.isNotEmpty) ...[
                  SizedBox(width: screen.width * 0.02),
                  Text(
                    appointment.selectedTime,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screen.width * 0.032,
                    ),
                  ),
                ],

                const Spacer(),

                // Tap indicator
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),

            SizedBox(height: screen.height * 0.012),

            // Problem/Issue (truncated)
            Text(
              'Condition Treated:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                fontSize: screen.width * (isTablet ? 0.028 : 0.034),
              ),
            ),

            SizedBox(height: screen.height * 0.004),

            Text(
              appointment.problem.isNotEmpty
                  ? (appointment.problem.length > 100
                      ? '${appointment.problem.substring(0, 100)}...'
                      : appointment.problem)
                  : 'Not specified',
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
                fontSize: screen.width * (isTablet ? 0.024 : 0.032),
              ),
            ),

            // Show fee if available
            if (appointment.consultationFee > 0) ...[
              SizedBox(height: screen.height * 0.008),
              Text(
                'Consultation Fee: Rs ${appointment.consultationFee.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: screen.width * 0.03,
                ),
              ),
            ],

            // Treatment notes indicator if available
            if ((appointment.doctorNotes ?? '').trim().isNotEmpty) ...[
              SizedBox(height: screen.height * 0.008),
              Row(
                children: [
                  Icon(Icons.note_alt, size: 16, color: kTeal),
                  SizedBox(width: 4),
                  Text(
                    'Treatment notes available',
                    style: TextStyle(
                      color: kTeal,
                      fontWeight: FontWeight.w500,
                      fontSize: screen.width * 0.03,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetailedView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailedRecordView(appointment: appointment),
    );
  }
}

class _DetailedRecordView extends StatelessWidget {
  final AppointmentModel appointment;

  const _DetailedRecordView({required this.appointment});

  static const Color kTeal = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Container(
      height: screen.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screen.width * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Medical Record Details',
                    style: TextStyle(
                      fontSize: screen.width * 0.05,
                      fontWeight: FontWeight.w700,
                      color: kTeal,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screen.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Information Card
                  _DetailCard(
                    title: 'Patient Information',
                    icon: Icons.pets,
                    children: [
                      _DetailRow(
                        label: 'Pet Name',
                        value: appointment.petName.isNotEmpty
                            ? appointment.petName
                            : 'Not specified',
                      ),
                      _DetailRow(
                        label: 'Owner Name',
                        value: appointment.ownerName.isNotEmpty
                            ? appointment.ownerName
                            : 'Not specified',
                      ),
                    ],
                  ),

                  SizedBox(height: screen.height * 0.02),

                  // Appointment Details Card
                  _DetailCard(
                    title: 'Appointment Details',
                    icon: Icons.calendar_today,
                    children: [
                      _DetailRow(
                        label: 'Date',
                        value: DateFormat('EEEE, MMMM dd, yyyy')
                            .format(appointment.createdAt),
                      ),
                      if (appointment.selectedTime.isNotEmpty)
                        _DetailRow(
                          label: 'Time',
                          value: appointment.selectedTime,
                        ),
                      _DetailRow(
                        label: 'Status',
                        value: appointment.status.toUpperCase(),
                        valueColor: kTeal,
                      ),
                      if (appointment.consultationFee > 0)
                        _DetailRow(
                          label: 'Consultation Fee',
                          value:
                              'Rs ${appointment.consultationFee.toStringAsFixed(2)}',
                          valueColor: Colors.green[700],
                        ),
                      if (appointment.paymentMethod.isNotEmpty)
                        _DetailRow(
                          label: 'Payment Method',
                          value: appointment.paymentMethod,
                        ),
                    ],
                  ),

                  SizedBox(height: screen.height * 0.02),

                  // Medical Information Card
                  _DetailCard(
                    title: 'Medical Information',
                    icon: Icons.medical_services,
                    children: [
                      _DetailSection(
                        label: 'Presenting Problem/Condition',
                        value: appointment.problem.isNotEmpty
                            ? appointment.problem
                            : 'Not specified',
                      ),
                      if ((appointment.doctorNotes ?? '').trim().isNotEmpty)
                        _DetailSection(
                          label: 'Treatment Notes & Recommendations',
                          value: appointment.doctorNotes!,
                        ),
                    ],
                  ),

                  SizedBox(height: screen.height * 0.02),

                  // Timeline Information
                  _DetailCard(
                    title: 'Timeline',
                    icon: Icons.timeline,
                    children: [
                      _DetailRow(
                        label: 'Appointment Created',
                        value: DateFormat('MMM dd, yyyy \'at\' hh:mm a')
                            .format(appointment.createdAt),
                      ),
                      if (appointment.confirmedAt != null)
                        _DetailRow(
                          label: 'Confirmed At',
                          value: DateFormat('MMM dd, yyyy \'at\' hh:mm a')
                              .format(appointment.confirmedAt!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  static const Color kTeal = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(screen.width * 0.04),
            decoration: BoxDecoration(
              color: kTeal.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: kTeal, size: 20),
                SizedBox(width: screen.width * 0.02),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kTeal,
                    fontSize: screen.width * 0.04,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(screen.width * 0.04),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screen.width * 0.3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: screen.width * 0.034,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey[800],
                fontSize: screen.width * 0.034,
                fontWeight:
                    valueColor != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String value;

  const _DetailSection({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: screen.width * 0.034,
            ),
          ),
          SizedBox(height: screen.height * 0.008),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screen.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: screen.width * 0.034,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.message,
    required this.icon,
  });

  static const Color kTeal = Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screen.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: kTeal.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w800,
                fontSize: screen.width * 0.05,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.6,
                fontSize: screen.width * 0.036,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
