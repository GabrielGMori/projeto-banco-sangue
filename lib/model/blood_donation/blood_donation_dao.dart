import 'package:projeto_banco_sangue/database/database_helper.dart';
import 'package:projeto_banco_sangue/model/blood_donation/blood_donation.dart';
import 'package:projeto_banco_sangue/model/donation_site/donation_site.dart';
import 'package:sqflite/sqflite.dart';

class BloodDonationDao {
  const BloodDonationDao();

  Future<List<BloodDonation>> getDonations(
    RhFactor factor,
    BloodType type,
    DonationSite? site,
  ) async {
    Database db = await DatabaseHelper.instance.database;
    String where = "type = ? and rh = ?";
    List<dynamic> whereArgs = [type.name, factor.name];

    if (site != null) {
      where += " and donation_site_id = ?";
      whereArgs.add(site.id);
    }

    var donations = await db.query(
      'blood_donations',
      orderBy: 'used ASC, date_donation DESC, id DESC',
      where: where,
      whereArgs: whereArgs,
    );

    List<BloodDonation> donationsList = donations.isNotEmpty
        ? donations.map((item) => BloodDonation.fromMap(item)).toList()
        : [];
    return donationsList;
  }

  Future<BloodDonation?> findById(int id) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(
      'blood_donations',
      where: "id = ?",
      whereArgs: [id],
    );
    if (query.isNotEmpty) {
      return BloodDonation.fromMap(query.first);
    }
    return null;
  }

  Future<int> add(BloodDonation newDonations) async {
    Database db = await DatabaseHelper.instance.database;
    if (newDonations.id != null && newDonations.id! > 0) {
      return await update(newDonations);
    }
    return await db.insert('blood_donations', newDonations.toMap());
  }

  Future<int> remove(BloodDonation donation) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'blood_donations',
      where: 'id = ?',
      whereArgs: [donation.id],
    );
  }

  Future<int> update(BloodDonation donation) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'blood_donations',
      donation.toMap(),
      where: 'id = ?',
      whereArgs: [donation.id],
    );
  }
}
