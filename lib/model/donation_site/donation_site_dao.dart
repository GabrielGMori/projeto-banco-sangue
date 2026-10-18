import 'package:projeto_banco_sangue/database/database_helper.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';
import 'package:sqflite/sqflite.dart';

class DonationSiteDao {
  const DonationSiteDao();

  Future<List<DonationSite>> getSites() async {
    Database db = await DatabaseHelper.instance.database;
    var sites = await db.query('donation_sites');
    List<DonationSite> sitesList = sites.isNotEmpty
        ? sites.map((item) => DonationSite.fromMap(item)).toList()
        : [];
    return sitesList;
  }

  Future<DonationSite?> findById(int id) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(
      'donation_sites',
      where: "id = ?",
      whereArgs: [id],
    );
    if (query.isNotEmpty) {
      return DonationSite.fromMap(query.first);
    }
    return null;
  }

  Future<int> add(DonationSite newSite) async {
    Database db = await DatabaseHelper.instance.database;
    if (newSite.id != null && newSite.id! > 0) {
      return await update(newSite);
    }
    return await db.insert('donation_sites', newSite.toMap());
  }

  Future<int> remove(DonationSite site) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'donation_sites',
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }

  Future<int> update(DonationSite site) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'donation_sites',
      site.toMap(),
      where: 'id = ?',
      whereArgs: [site.id],
    );
  }

  Future<int> countDonations(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'select count(*) as total from blood_donations where donation_site_id = ?',
      [id],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
