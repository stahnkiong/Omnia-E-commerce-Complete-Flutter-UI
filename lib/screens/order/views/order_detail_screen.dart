import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/components/network_image_with_loader.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${order.displayId}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(context),
            const SizedBox(height: defaultPadding),
            Text(
              "Items",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding),
            ...order.items.map((item) => _buildOrderItem(context, item)),
            const SizedBox(height: defaultPadding),
            _buildShippingInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, "Status", order.status.toUpperCase()),
          const SizedBox(height: 8),
          _buildSummaryRow(
              context, "Payment", order.paymentStatus.toUpperCase()),
          const SizedBox(height: 8),
          _buildSummaryRow(
              context, "Fulfillment", order.fulfillmentStatus.toUpperCase()),
          const Divider(height: 24),
          _buildSummaryRow(context, "Total",
              "${order.currencyCode} ${order.total.toStringAsFixed(2)}",
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? primaryColor : null,
              ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(BuildContext context, LineItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: NetworkImageWithLoader(item.thumbnail),
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity} x ${order.currencyCode} ${item.unitPrice.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            "${order.currencyCode} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(BuildContext context) {
    if (order.shippingAddress == null) return const SizedBox.shrink();
    final addr = order.shippingAddress!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shipping Details",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: defaultPadding),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${addr.firstName ?? ''} ${addr.lastName ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (addr.address1 != null) Text(addr.address1!),
              if (addr.city?.isNotEmpty ?? false) Text(addr.city!),
              if (addr.countryCode?.isNotEmpty ?? false)
                Text(addr.countryCode!.toUpperCase()),
            ],
          ),
        ),
      ],
    );
  }
}
