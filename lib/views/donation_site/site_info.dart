import 'package:flutter/material.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';

enum SiteAction { select, cancel, delete, edit }

class DonationSiteInfo extends StatelessWidget {
  const DonationSiteInfo({super.key, required this.site});
  final DonationSite site;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                site.nome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, SiteAction.edit),
                    icon: Icon(Icons.edit, size: 20),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, SiteAction.delete),
                    icon: Icon(Icons.delete, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(site.endereco, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, SiteAction.cancel),
                child: const Text("Voltar"),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, SiteAction.select),
                child: const Text("Selecionar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
