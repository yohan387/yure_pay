import 'package:flutter/material.dart';
import 'package:yure_tips/src/common/colors.dart';
import 'package:yure_tips/src/common/extensions.dart';

class TipForm extends StatefulWidget {
  final int totalAmount;
  final String merchantId;
  final String merchantName;
  final Function(int) onTipAdded;
  final Function() onCancelled;

  const TipForm({
    super.key,
    required this.totalAmount,
    required this.merchantId,
    required this.merchantName,
    required this.onTipAdded,
    required this.onCancelled,
  });

  @override
  State<TipForm> createState() => _TipFormState();
}

class _TipFormState extends State<TipForm> {
  final List<int> _defaultPercentages = [5, 10];
  int? _selectedTipAmount;
  final TextEditingController _customAmountController = TextEditingController();
  bool _showCustomInput = false;
  final FocusNode _customAmountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedTipAmount = _calculatePercentageAmount(5);
  }

  int _calculatePercentageAmount(int percentage) {
    return (widget.totalAmount * percentage / 100).ceil();
  }

  void _selectPercentage(int percentage) {
    setState(() {
      _showCustomInput = false;
      _selectedTipAmount = _calculatePercentageAmount(percentage);
      _customAmountController.clear();
    });
  }

  void _selectCustomOption() {
    setState(() {
      _showCustomInput = true;
      _selectedTipAmount = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customAmountFocusNode.requestFocus();
    });
  }

  void _onCustomAmountChanged(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _selectedTipAmount = int.tryParse(value);
      });
    } else {
      setState(() {
        _selectedTipAmount = 0;
      });
    }
  }

  void _addTip() {
    final tipAmount = _selectedTipAmount?.toInt() ?? 0;
    if (tipAmount > 0) {
      widget.onTipAdded(tipAmount);
    } else {
      widget.onCancelled();
    }
  }

  void _cancel() {
    widget.onCancelled();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _customAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.main,
                  child: Text(
                    widget.merchantName[0],
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.merchantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Merci d'avoir payé avec YurePay !",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Paiement : ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.totalAmount.formatAsAmount(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            "Offrir un pourboire ?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          if (!_showCustomInput) ...[
            Text(
              "Sélectionner un montant par défaut",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ..._defaultPercentages.map((percentage) {
                  final int amount = _calculatePercentageAmount(percentage);
                  final isSelected = _selectedTipAmount == amount;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _selectPercentage(percentage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.main
                              : Colors.grey[200],
                          foregroundColor: isSelected
                              ? Colors.white
                              : AppColors.main,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              amount.formatAsAmount(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: _selectCustomOption,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: AppColors.main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Autre",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            TextField(
              controller: _customAmountController,
              focusNode: _customAmountFocusNode,
              decoration: InputDecoration(
                hintText: "Saisissez un montant",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.main),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: _onCustomAmountChanged,
            ),
          ],

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _addTip,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              _selectedTipAmount != null
                  ? "Oui, J'offre ${_selectedTipAmount!.formatAsAmount()}"
                  : "Offrir un pourboire",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: _cancel,
            child: Text(
              "Non merci",
              style: TextStyle(fontSize: 16, color: AppColors.main),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
