import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({Key? key}) : super(key: key);

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'hospital')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<HospitalModel> hospitals = [];
            final docs = snapshot.data!.docs;
            for (var i in docs) {
              hospitals.add(HospitalModel.fromJson(i.data(), i.id));
            }

            return ListView.separated(
                separatorBuilder: (context, i) => const SizedBox(
                      height: 16,
                    ),
                itemBuilder: (context, i) => Hospitalcard(model: hospitals[i]),
                itemCount: hospitals.length);
          },
        ),
      ),
    );
  }
}

class HospitalModel {
  String name, email, phone, id;

  HospitalModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.id,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json, String id) {
    return HospitalModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['number'] as String,
      id: id,
    );
  }
}

class Hospitalcard extends StatelessWidget {
  final HospitalModel model;
  const Hospitalcard({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.local_hospital),
      title: Text(model.name),
      subtitle: Text(model.email),
      trailing: Text(model.phone),
    );
  }
}
