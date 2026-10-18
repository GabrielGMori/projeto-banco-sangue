import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';

class DonationSiteCreateForm extends StatefulWidget {
  const DonationSiteCreateForm({super.key, required this.position, this.site});
  final LatLng position;
  final DonationSite? site;

  @override
  State<DonationSiteCreateForm> createState() => _DonationSiteCreateFormState();
}

class _DonationSiteCreateFormState extends State<DonationSiteCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();

  @override
  void initState() {
    if (widget.site != null) {
      _nomeController.text = widget.site!.nome;
      _enderecoController.text = widget.site!.endereco;
    }
    super.initState();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${widget.site == null ? 'Cadastrar' : 'Atualizar'} posto de doação",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(label: Text("Nome do posto")),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o nome do posto';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _enderecoController,
              decoration: const InputDecoration(label: Text("Endereço")),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o endereço';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(
                        context,
                        DonationSite(
                          id: widget.site?.id,
                          nome: _nomeController.text.trim(),
                          endereco: _enderecoController.text.trim(),
                          position: widget.position,
                        ),
                      );
                    }
                  },
                  child: Text(widget.site == null ? "Cadastrar" : "Atualizar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
