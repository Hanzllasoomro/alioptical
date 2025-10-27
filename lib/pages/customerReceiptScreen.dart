import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

class CustomerReceiptScreen extends StatefulWidget {
  final String customerId; // Firestore doc ID of the customer
  final String userId; // Firestore doc ID of the shop user

  const CustomerReceiptScreen({
    super.key,
    required this.customerId,
    required this.userId,
  });

  @override
  State<CustomerReceiptScreen> createState() => _CustomerReceiptScreenState();
}

class _CustomerReceiptScreenState extends State<CustomerReceiptScreen> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? customerData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      DocumentSnapshot? customerSnap;

      final opticsSnap = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .get();

      if (opticsSnap.exists) {
        customerSnap = opticsSnap;
      } else {
        final repairingSnap = await FirebaseFirestore.instance
            .collection('repairing_customers')
            .doc(widget.customerId)
            .get();
        if (repairingSnap.exists) {
          customerSnap = repairingSnap;
        }
      }

      if (customerSnap == null || !customerSnap.exists) {
        print("⚠️ Customer not found in either collection");
        return;
      }

      setState(() {
        userData = userSnap.data();
        customerData = customerSnap!.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('❌ Error fetching Firestore data: $e');
    }
  }

  bool isDueDatePassed(String dueDateStr) {
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return DateTime.now().isAfter(dueDate);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null || customerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Receipt'),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final bool duePassed = isDueDatePassed(customerData!['dueDate']);
    final Color dueColor = duePassed ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Receipt'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Shop Info
            Text(
              userData!['shopName'] ?? 'Shop Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(userData!['address'] ?? '', textAlign: TextAlign.center),
            Text('Ph: ${userData!['contactNumber'] ?? ''}',
                textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // 🔹 Customer Info
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Customer Information:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            buildInfoRow('Name', customerData!['name']),
            buildInfoRow('S.No', customerData!['serialNo'].toString()),
            buildInfoRow('Phone', customerData!['contact']),
            buildInfoRow('Date', customerData!['date']),
            Row(
              children: [
                const Text('Due Date: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  customerData!['dueDate'],
                  style: TextStyle(color: dueColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            buildInfoRow('Frame', customerData!['frameDetails']),
            buildInfoRow('Lens', customerData!['lensDetails']),
            const SizedBox(height: 16),

            // 🔹 Vision
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Vision:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            buildVisionTable(customerData!),
            const SizedBox(height: 16),

            // 🔹 Financial Details
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Financial Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            buildFinanceTable(customerData!),
            const SizedBox(height: 20),

            // 🔹 Notes
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Note:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 50% Advance Required for Order Confirmation.\n'
                  '2. No Refund on Completed Orders.\n'
                  '3. Not Responsible for Damaged Frames or Lenses.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // 🔹 Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.print),
                  label: const Text('Customer Receipt'),
                  onPressed: () async {
                    await Printing.layoutPdf(onLayout: (format) async {
                      return await Printing.convertHtml(
                        format: format,
                        html: '''
                          <h1 style="text-align:center;">${userData!['shopName']}</h1>
                          <p style="text-align:center;">${userData!['address']}<br>Ph: ${userData!['contactNumber']}</p>
                          <hr>
                          <h2>Customer Receipt</h2>
                          <p><b>Name:</b> ${customerData!['name']}<br>
                          <b>S.No:</b> ${customerData!['serialNo']}<br>
                          <b>Phone:</b> ${customerData!['contact']}<br>
                          <b>Date:</b> ${customerData!['date']}<br>
                          <b>Due Date:</b> ${customerData!['dueDate']}<br>
                          <b>Frame:</b> ${customerData!['frameDetails']}<br>
                          <b>Lens:</b> ${customerData!['lensDetails']}</p>
                          <h3>Financial Details</h3>
                          <p>Total: ${customerData!['total']} Pkr<br>
                          Advance: ${customerData!['advance']} Pkr<br>
                          Balance: ${customerData!['balance']} Pkr</p>
                        ''',
                      );
                    });
                  },
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () {
                    final receiptText = '''
Shop: ${userData!['shopName']}
Customer: ${customerData!['name']}
Frame: ${customerData!['frameDetails']}
Lens: ${customerData!['lensDetails']}
Total: ${customerData!['total']} Pkr
Due Date: ${customerData!['dueDate']}
''';
                    Share.share(receiptText, subject: 'Customer Receipt');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  /// ✅ Fixed Vision Table — correctly reads from nested `eyeData` map
  Widget buildVisionTable(Map<String, dynamic> data) {
    final eyeData = data['eyeData'] as Map<String, dynamic>? ?? {};
    final right = eyeData['right'] as Map<String, dynamic>? ?? {};
    final left = eyeData['left'] as Map<String, dynamic>? ?? {};
    final add = eyeData['add'] as Map<String, dynamic>? ?? {};
    final ipd = eyeData['ipd'] as Map<String, dynamic>? ?? {};

    return Table(
      border: TableBorder.all(color: Colors.black54),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
          children: [
            tableCell(''),
            tableCell('SPH'),
            tableCell('CYL'),
            tableCell('AXIS'),
            tableCell('VA'),
          ],
        ),
        TableRow(children: [
          tableCell('Rt Eye'),
          tableCell(right['sph'] ?? ''),
          tableCell(right['cyl'] ?? ''),
          tableCell(right['axis'] ?? ''),
          tableCell(right['va'] ?? ''),
        ]),
        TableRow(children: [
          tableCell('Lt Eye'),
          tableCell(left['sph'] ?? ''),
          tableCell(left['cyl'] ?? ''),
          tableCell(left['axis'] ?? ''),
          tableCell(left['va'] ?? ''),
        ]),
        TableRow(children: [
          tableCell('ADD'),
          tableCell(add['add1'] ?? ''),
          tableCell(add['add2'] ?? ''),
          tableCell(''),
          tableCell(''),
        ]),
        TableRow(children: [
          tableCell('IPD'),
          tableCell(ipd['ipd1'] ?? ''),
          tableCell(ipd['ipd2'] ?? ''),
          tableCell(''),
          tableCell(''),
        ]),
      ],
    );
  }

  Widget buildFinanceTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black54),
      children: [
        TableRow(children: [
          tableCell('Total'),
          tableCell('${data['total']} Pkr'),
        ]),
        TableRow(children: [
          tableCell('Advance'),
          tableCell('${data['advance']} Pkr'),
        ]),
        TableRow(children: [
          tableCell('Balance'),
          tableCell('${data['balance']} Pkr'),
        ]),
      ],
    );
  }

  static Widget tableCell(String text, {int colspan = 1}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
