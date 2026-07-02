import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/models/order_model.dart';
import 'package:pasar_now/models/address_model.dart';
import 'package:pasar_now/components/network_image_with_loader.dart';
import 'package:pasar_now/services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    try {
      final detailedOrder = await _apiService.getOrder(widget.order.id);
      if (detailedOrder != null && mounted) {
        setState(() {
          _order = detailedOrder;
        });
      }
    } catch (_) {
      // Fallback to the initial widget.order
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${_order.displayId}"),
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
            ..._order.items.map((item) => _buildOrderItem(context, item)),
            const SizedBox(height: defaultPadding),
            // _buildShippingInfo(context),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final year = localDate.year;
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return "$year-$month-$day $hour:$minute";
  }

  String _formatAddress(Address address) {
    // final name = "${address.firstName ?? ''} ${address.lastName ?? ''}".trim();
    final parts = <String>[];
    // if (name.isNotEmpty) {
    //   parts.add(name);
    // }
    if (address.address1 != null && address.address1!.trim().isNotEmpty) {
      parts.add(address.address1!.trim());
    }
    if (address.address2 != null && address.address2!.trim().isNotEmpty) {
      parts.add(address.address2!.trim());
    }
    if (address.city != null && address.city!.trim().isNotEmpty) {
      parts.add(address.city!.trim());
    }
    if (address.province != null && address.province!.trim().isNotEmpty) {
      parts.add(address.province!.trim());
    }
    if (address.postalCode != null && address.postalCode!.trim().isNotEmpty) {
      parts.add(address.postalCode!.trim());
    }
    if (address.countryCode != null && address.countryCode!.trim().isNotEmpty) {
      parts.add(address.countryCode!.trim().toUpperCase());
    }
    return parts.join(', ');
  }

  String _getPaymentStatusDisplay(String status) {
    if (status.toLowerCase() == 'captured') {
      return 'RECEIVED';
    }
    return status.toUpperCase();
  }

  String _getFulfillmentStatusDisplay(String status) {
    if (status.toLowerCase() == 'not_fulfilled') {
      return 'PENDING';
    }
    return status.toUpperCase();
  }

  Widget _buildOrderSummary(BuildContext context) {
    DateTime? deliveryDate;
    if (_order.fulfillments.isNotEmpty) {
      for (var f in _order.fulfillments) {
        if (f.deliveredAt != null) {
          deliveryDate = f.deliveredAt;
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
              context, "Order Date", _formatDate(_order.createdAt)),
          const SizedBox(height: 8),
          if (_order.shippingAddress != null) ...[
            _buildSummaryRow(
                context, "Ship To", _formatAddress(_order.shippingAddress!)),
            const SizedBox(height: 8),
          ],
          if (deliveryDate != null) ...[
            _buildSummaryRow(
                context, "Delivery Date", _formatDate(deliveryDate)),
            const SizedBox(height: 8),
          ],
          _buildSummaryRow(context, "Payment",
              _getPaymentStatusDisplay(_order.paymentStatus)),
          const SizedBox(height: 8),
          _buildSummaryRow(context, "Status",
              _getFulfillmentStatusDisplay(_order.fulfillmentStatus)),
          const Divider(height: 24),
          _buildSummaryRow(context, "Total",
              "${_order.currencyCode} ${_order.total.toStringAsFixed(2)}",
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? primaryColor : null,
                ),
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
                if (item.variantTitle != null &&
                    item.variantTitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variantTitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  "Qty: ${item.quantity} x ${_order.currencyCode} ${item.unitPrice.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            "${_order.currencyCode} ${(item.quantity * item.unitPrice).toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  // Widget _buildShippingInfo(BuildContext context) {
  //   if (_order.shippingAddress == null) return const SizedBox.shrink();
  //   final addr = _order.shippingAddress!;
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Shipping Details",
  //         style: Theme.of(context).textTheme.titleMedium,
  //       ),
  //       const SizedBox(height: defaultPadding),
  //       Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.all(defaultPadding),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).cardColor,
  //           borderRadius: BorderRadius.circular(defaultBorderRadious),
  //           border: Border.all(color: Theme.of(context).dividerColor),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text("${addr.firstName ?? ''} ${addr.lastName ?? ''}",
  //                 style: const TextStyle(fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 4),
  //             if (addr.address1 != null) Text(addr.address1!),
  //             if (addr.city?.isNotEmpty ?? false) Text(addr.city!),
  //             if (addr.countryCode?.isNotEmpty ?? false)
  //               Text(addr.countryCode!.toUpperCase()),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
