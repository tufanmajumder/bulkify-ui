class PaymentModel {
  final String orderId;
  final String paymentId;
  final String utrRrn;
  final String paymentMethod;
  final String customerName;
  final String customerSubtext;
  final String date;
  final String time;
  final String status;
  final String amount;
  final String terminal;
  final String channel;

  PaymentModel({
    required this.orderId,
    required this.paymentId,
    required this.utrRrn,
    required this.paymentMethod,
    required this.customerName,
    this.customerSubtext = 'NA',
    required String date,
    required this.time,
    required this.status,
    required this.amount,
    this.terminal = 'Bulkify-Ride-USR001',
    this.channel = 'bulkifyb2b.com',
  }) : date = _formatDate(date);

  static String _formatDate(String raw) {
    final str = raw.trim();
    if (str.isEmpty || str == 'null' || str == '-') return '-';
    if (str.endsWith('-26')) {
      return '${str.substring(0, str.length - 2)}2026';
    }
    if (str.endsWith('/26')) {
      return '${str.substring(0, str.length - 2)}2026';
    }
    final components = str.split(RegExp(r'[-/.]'));
    if (components.length == 3 && components[2] == '26') {
      return '${components[0]}-${components[1]}-2026';
    }
    return str;
  }
}
