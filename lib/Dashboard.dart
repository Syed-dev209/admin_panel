import 'dart:async';

import 'package:admin_panel/Controllers/auth_controller.dart';
import 'package:admin_panel/Controllers/controllerMethods.dart';
import 'package:admin_panel/ambulances_screen.dart';
import 'package:admin_panel/hospitals_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late StreamController<List<AccidentModel>?> streamController;

  loadAccidentsOnTheWay() {
    getAccidentsOnTheWay().then((value) {
      if (value != null) {
        streamController.add(value);
        return value;
      } else {
        streamController.add(null);
        return null;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    streamController = StreamController<List<AccidentModel>?>.broadcast();
    loadAccidentsOnTheWay();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          loadAccidentsOnTheWay();
        },
        child: SingleChildScrollView(
          child: Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  CustomContainer(
                    size,
                    'Accidents detected',
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('accidents')
                            .where('Status', isEqualTo: 'Detected')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          List<AccidentModel> accidents = [];
                          for (var i in docs) {
                            accidents
                                .add(AccidentModel.fromJson(i.id, i.data()));
                          }

                          return accidents.isNotEmpty
                              ? ListView.separated(
                                  itemBuilder: (context, i) =>
                                      AccidentCard(model: accidents[0]),
                                  separatorBuilder: (context, i) =>
                                      const SizedBox(
                                    height: 12,
                                  ),
                                  itemCount: accidents.length,
                                )
                              : const Center(
                                  child: Text('No accidents detected'),
                                );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  ///Alerts on the way
                  CustomContainer(
                      size,
                      'Accidents picked and on the way to Hospital',
                      Expanded(
                        child: StreamBuilder<List<AccidentModel>?>(
                          stream: streamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError ||
                                snapshot.connectionState ==
                                    ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.data == null) {
                              return const Center(
                                child: Text('No accidents detected'),
                              );
                            }

                            return ListView.separated(
                                itemBuilder: (context, i) =>
                                    AlertsCard(model: snapshot.data![i]),
                                separatorBuilder: (context, i) =>
                                    const SizedBox(
                                      height: 12,
                                    ),
                                itemCount: snapshot.data!.length);
                          },
                        ),
                      ))
                ],
              )),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              child: Text('Admin Panel'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Ambulances'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AmbulancesScren(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Hospitals'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HospitalsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                AuthController().logout().then((value) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Dashboard(),
                      ),
                      (route) => false);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  CustomContainer(Size size, String title, Widget child) {
    return Container(
      height: size.height * 0.4,
      width: size.width,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black26,
                spreadRadius: 3,
                blurRadius: 3)
          ]),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          child,
        ],
      ),
    );
  }
}

class AccidentModel {
  String? id;
  var createdAt;
  String? status;
  Map<String, dynamic> accidentLocation = {};
  HospitalModel? hospitalModel;
  AmbulanceModel? ambulanceModel;
  String? alertId;
  String? address;

  AccidentModel.fromJson(String id, Map<String, dynamic> json) {
    this.id = id;
    createdAt = json["Date Time"];
    //location = json["Latitude & Longitude"];
    accidentLocation.putIfAbsent(
        "latitude", () => json["Latitude & Longitude"][0]);
    accidentLocation.putIfAbsent(
        "longitude", () => json["Latitude & Longitude"][1]);
    status = json["Status"];
  }

  setHospitalData(HospitalModel model) {
    hospitalModel = model;
  }

  setAmbulanceData(AmbulanceModel model) {
    ambulanceModel = model;
  }

  setAlertId(String id) {
    alertId = id;
  }

  setAccidentAddress(String address) {
    this.address = address;
  }
}

class AccidentCard extends StatelessWidget {
  final AccidentModel model;
  const AccidentCard({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'Accident at ${model.accidentLocation["latitude"]}, ${model.accidentLocation["longitude"]}',
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
      ),
    );
  }
}

class AlertsCard extends StatelessWidget {
  final AccidentModel model;
  const AlertsCard({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          "Accident at ${model.accidentLocation["latitude"]}, ${model.accidentLocation["longitude"]}",
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
      subtitle: Text('Picked by ${model.ambulanceModel?.name ?? ''}'),
      trailing: Text('On the way to ${model.hospitalModel?.name ?? ''}'),
    );
  }
}
