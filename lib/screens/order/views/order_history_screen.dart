import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/services/api_service.dart';
import 'package:shop/screens/order/views/order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await _apiService.getOrders();
      // Sort by created date (latest first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _orders = orders;
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
        title: const Text("Order History"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.separated(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: _orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: defaultPadding),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return OrderCard(order: order);
                  },
                ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

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
                _buildStatusBadge(context, order.status),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "Placed on ${order.createdAt.toLocal().toString().split(' ')[0]}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'archived':
        color = Colors.grey;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      case 'requires_action':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
