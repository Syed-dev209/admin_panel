import 'dart:developer';

import 'package:admin_panel/Dashboard.dart';
import 'package:admin_panel/ambulances_screen.dart';
import 'package:admin_panel/hospitals_screen.dart';
import 'package:admin_panel/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_geocoding/google_geocoding.dart';

final firestore = FirebaseFirestore.instance;
var googleGeocoding = GoogleGeocoding(API_KEY);

Future<List<AccidentModel>?> getAccidentsOnTheWay() async {
  // try{
  List<AlertModel> alertsList = [];
  List<AccidentModel> accidents = [];

  final alerts = await firestore
      .collection('alerts')
      .where('status', isEqualTo: 'alert')
      .get();

  for (var i in alerts.docs) {
    alertsList.add(AlertModel.fromJson(i.data()));
  }

  for (var i in alertsList) {
    log(i.accidentId.toString());
    AccidentModel accident;
    final accidentDetails = await firestore
        .collection('accidents')
        .doc(i.accidentId ?? 'RBEP8KvK6hkkN9EZZQst')
        .get();

    accident = AccidentModel.fromJson(i.accidentId!, accidentDetails.data()!);

    final driverDetails =
        await firestore.collection('users').doc(i.driverId).get();
    accident.setAmbulanceData(
        AmbulanceModel.fromJson(driverDetails.data()!, i.driverId!));

    final hospitalDetails =
        await firestore.collection('users').doc(i.hospitalId).get();
    accident.setHospitalData(
        HospitalModel.fromJson(hospitalDetails.data()!, i.hospitalId!));

    // GeocodingResponse? risult = await googleGeocoding.geocoding.getReverse(
    //     LatLon(accident.accidentLocation['latitude'],
    //         accident.accidentLocation['longitude']));
    // if (risult != null) {
    //   accident.setAccidentAddress(
    //       "${risult.results?.first.formattedAddress ?? ''}");
    // }

    accidents.add(accident);
  }

  return accidents;
  // }
  // catch(e){
  //   print(e.toString());
  //   return null;
  // }
}

class AlertModel {
  String? accidentId, driverId, hospitalId, pickTime;

  AlertModel.fromJson(Map<String, dynamic> json) {
    log(json['accidentId'].toString());
    accidentId = json['accidentId'];
    driverId = json['driverId'];
    hospitalId = json['hospitalId'];
    pickTime = json['pickTime'];
  }
}
