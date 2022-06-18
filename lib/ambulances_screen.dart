import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AmbulancesScren extends StatefulWidget {
  const AmbulancesScren({Key? key}) : super(key: key);

  @override
  State<AmbulancesScren> createState() => _AmbulancesScrenState();
}

class _AmbulancesScrenState extends State<AmbulancesScren> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          title: const Text('Ambulances'),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        height: size.height,
        width: size.width,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'ambulance')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<AmbulanceModel> ambulances = [];
            final docs = snapshot.data!.docs;
            for (var i in docs) {
              ambulances.add(AmbulanceModel.fromJson(i.data(), i.id));
            }

            return ListView.separated(
                itemBuilder: (context, i) =>
                    AmbulanceCard(model: ambulances[i]),
                separatorBuilder: (context, i) => const SizedBox(
                      height: 12,
                    ),
                itemCount: ambulances.length);
          },
        ),
      ),
    );
  }
}

class AmbulanceModel {
  String name, email, phone, id;
  int cancelled;
  AmbulanceModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.id,
    required this.cancelled,
  });

  factory AmbulanceModel.fromJson(Map<String, dynamic> json, String id) {
    return AmbulanceModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['number'] as String,
      id: id,
      cancelled: json['cancelled'] as int,
    );
  }
}

class AmbulanceCard extends StatelessWidget {
  final AmbulanceModel model;
  const AmbulanceCard({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        if (model.cancelled == 3) {
          FirebaseFirestore.instance.collection('users').doc(model.id).update({
            'cancelled': 0,
          });
        }
      },
      leading: Icon(Icons.person),
      title: Text(model.name +
          (model.cancelled == 3
              ? '(Account Blocked. Tap to unlock account.)'
              : '')),
      subtitle: Text(model.phone),
      trailing: Column(
        children: [
          Text('Rides Canclled'),
          Text(
            model.cancelled.toString(),
            style: TextStyle(
              color: model.cancelled < 3 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
