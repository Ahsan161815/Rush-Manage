import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/app/widgets/gradient_button.dart';
import '../controllers/finance_controller.dart';

class FinanceCreateQuoteScreen extends StatefulWidget {
  const FinanceCreateQuoteScreen({super.key});
  @override
  State<FinanceCreateQuoteScreen> createState() =>
      _FinanceCreateQuoteScreenState();
}

class _FinanceCreateQuoteScreenState extends State<FinanceCreateQuoteScreen> {
  final _clientController = TextEditingController();
  final _referenceController = TextEditingController();
  final GlobalKey<_LineItemsEditorState> _lineItemsKey =
      GlobalKey<_LineItemsEditorState>();

  @override
  void dispose() {
    _clientController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceController>();
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Create Quote',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 32,
              24,
              isMobile ? 16 : 32,
              48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardSection(
                  title: 'Client & Project',
                  child: Column(
                    children: [
                      TextField(
                        controller: _clientController,
                        decoration: InputDecoration(
                          labelText: 'Client Name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _referenceController,
                        decoration: InputDecoration(
                          labelText: 'Project / Reference (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _CardSection(
                  title: 'Line Items',
                  child: _LineItemsEditor(key: _lineItemsKey),
                ),
                const SizedBox(height: 24),
                _CardSection(
                  title: 'Conditions & Validity',
                  child: TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Payment terms, delivery schedule, notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _CardSection(
                  title: 'Options',
                  child: Row(
                    children: [
                      Switch(value: true, onChanged: (_) {}),
                      const SizedBox(width: 8),
                      Text(
                        'Require e-Signature',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  onPressed: () {
                    final subtotal = _lineItemsKey.currentState?._total ?? 0.0;
                    final quote = finance.createDraftQuote(
                      clientName: _clientController.text.trim().isEmpty
                          ? 'Unnamed Client'
                          : _clientController.text.trim(),
                      description: _referenceController.text.trim().isEmpty
                          ? 'Quote draft'
                          : _referenceController.text.trim(),
                      subtotal: subtotal,
                    );
                    context.push('/finance/quote/${quote.id}/preview');
                  },
                  text: 'Generate Quote',
                  height: 56,
                  width: double.infinity,
                ),
                const SizedBox(height: 14),
                Text(
                  'Existing Quotes: ${finance.quotes.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hintTextfiled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LineItemsEditor extends StatefulWidget {
  const _LineItemsEditor({super.key});
  @override
  State<_LineItemsEditor> createState() => _LineItemsEditorState();
}

class _LineItemsEditorState extends State<_LineItemsEditor> {
  final List<_LineItemDraft> _items = [];

  void _addItem() {
    setState(() => _items.add(_LineItemDraft()));
  }

  double get _total => _items.fold(0, (s, i) => s + (i.quantity * i.unitPrice));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _items.length; i++)
          _LineItemRow(
            item: _items[i],
            onRemove: () => setState(() => _items.removeAt(i)),
          ),
        OutlinedButton.icon(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Line Item'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.secondary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Subtotal: €${_total.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LineItemDraft {
  String description = '';
  int quantity = 1;
  double unitPrice = 0;
}

class _LineItemRow extends StatelessWidget {
  final _LineItemDraft item;
  final VoidCallback onRemove;
  const _LineItemRow({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              onChanged: (v) => item.description = v,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) => item.quantity = int.tryParse(v) ?? 1,
              decoration: InputDecoration(
                hintText: 'Qty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) => item.unitPrice = double.tryParse(v) ?? 0,
              decoration: InputDecoration(
                hintText: 'Unit Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.textfieldBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
