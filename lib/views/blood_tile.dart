import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';

class BloodTile extends StatelessWidget {
  final BloodDonation donation;
  final Function(BloodDonation)? onDelete;
  final Function(BloodDonation)? onEdit;
  final Function(BloodDonation)? onChangeStatus;

  const BloodTile({
    super.key,
    required this.donation,
    this.onDelete,
    this.onEdit,
    this.onChangeStatus,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final donationDate = _formatDate(donation.dateDonation);
    final usageDate = donation.isUsed() ? _formatDate(donation.dateUsed) : '';

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          donation.getTypeRH(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        'Doador: ${donation.donator}${donation.isUsed() ? "\nDonatário: ${donation.grantee}" : ""}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Doação: $donationDate${donation.isUsed() ? "\nUso: $usageDate" : ""}\nStatus: ${donation.isUsed() ? "Utilizado" : "Disponível"}',
        style: TextStyle(
          fontSize: 12,
          color: donation.isUsed()
              ? Theme.of(context).colorScheme.surfaceTint
              : Colors.green,
        ),
      ),
      isThreeLine: donation.isUsed(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!donation.isUsed())
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: () => onChangeStatus!.call(donation),
            ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => onEdit!.call(donation),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => onDelete!(donation),
          ),
        ],
      ),
      dense: true,
    );
  }
}
