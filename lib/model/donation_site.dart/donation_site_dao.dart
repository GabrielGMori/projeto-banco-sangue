import 'package:projeto_banco_sangue/database/database_helper.dart';
import 'package:projeto_banco_sangue/model/donation_site.dart/donation_site.dart';
import 'package:sqflite/sqflite.dart';

class DonationSiteDao {
  const DonationSiteDao();

  /// Retorna todos os postos cadastrados no banco de dados ordenados por nome
  Future<List<DonationSite>> getSites() async {
    Database db = await DatabaseHelper.instance.database;
    var sites = await db.query('donation_sites', orderBy: 'nome ASC');
    List<DonationSite> sitesList = sites.isNotEmpty
        ? sites.map((item) => DonationSite.fromMap(item)).toList()
        : [];
    return sitesList;
  }

  /// Busca um posto pelo seu identificador primário 'id'
  Future<DonationSite?> findById(int id) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(
      'donation_sites',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (query.isNotEmpty) {
      return DonationSite.fromMap(query.first);
    }
    return null;
  }

  /// Adiciona um novo posto ou atualiza caso o 'id' já exista
  Future<int> add(DonationSite site) async {
    Database db = await DatabaseHelper.instance.database;
    var existing = await findById(site.id);
    if (existing != null) {
      return await update(site);
    }
    return await db.insert(
      'donation_sites',
      site.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove um posto cadastrado utilizando o 'id'
  Future<int> remove(DonationSite site) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'donation_sites',
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }

  /// Atualiza os dados de um posto de doação
  Future<int> update(DonationSite site) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'donation_sites',
      site.toMap(),
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }
}
