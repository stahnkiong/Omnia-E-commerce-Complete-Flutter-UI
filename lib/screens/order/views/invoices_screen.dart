import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/services/api_service.dart';
import 'package:shop/screens/order/views/order_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final allOrders = await _apiService.getOrders();
      final filteredOrders =
          allOrders.where((o) => o.paymentStatus != 'captured').toList();
      // Sort by created date (latest first)
      filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      double total = 0.0;
      for (var order in filteredOrders) {
        total += order.total;
      }

      setState(() {
        _orders = filteredOrders;
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoices"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("No upcoming invoices"))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          bottom:
                              BorderSide(color: Theme.of(context).dividerColor),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Pending:",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _orders.isNotEmpty
                                ? "${_orders.first.currencyCode} ${_totalAmount.toStringAsFixed(2)}"
                                : "RM ${_totalAmount.toStringAsFixed(2)}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(defaultPadding),
                        itemCount: _orders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: defaultPadding),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return InvoiceOrderCard(order: order);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class InvoiceOrderCard extends StatelessWidget {
  final OrderModel order;

  const InvoiceOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      },
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order.displayId}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildStatusBadge(context, order.fulfillmentStatus),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "Placed on ${order.createdAt.toLocal().toString().split(' ')[0]}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       "Payment: ${order.paymentStatus}",
            //       style: Theme.of(context).textTheme.bodySmall,
            //     ),
            //     Text(
            //       "Fulfillment: ${order.fulfillmentStatus}",
            //       style: Theme.of(context).textTheme.bodySmall,
            //     ),
            //   ],
            // ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${order.items.length} Items",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "${order.currencyCode} ${order.total.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: primaryColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'pending':
      case 'awaiting':
      case 'not_fulfilled':
        color = Colors.orange;
        break;
      case 'completed':
      case 'captured':
      case 'delivered':
      case 'fulfilled':
        color = Colors.green;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'archived':
        color = Colors.grey;
        break;
      case 'canceled':
      case 'refunded':
      case 'returned':
        color = Colors.red;
        break;
      case 'requires_action':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        _getLabel(status).toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLabel(String status) {
    if (status == 'not_fulfilled') return 'pending';
    if (status == 'fulfilled') return 'ready to deliver';
    return status;
  }
}
