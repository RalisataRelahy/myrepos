import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medilink_app/widgets/profil_doctor_for_p.dart';

class DoctorsPage extends StatelessWidget {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Top doctors"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            //search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search doctor ...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            //firestore doctors list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No doctors found'));
                  }

                  final doctors = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final data =
                          doctors[index].data() as Map<String, dynamic>;

                      //convertir tous les champs en string
                      final firstName = data['firstName']?.toString() ?? '';
                      final lastName = data['lastName']?.toString() ?? '';
                      final speciality = (data['speciality'] is List)
                          ? (data['speciality'] as List).join(',')
                          : (data['speciality']?.toString() ?? "");
                      final rating = data['rating']?.toString() ?? '0';
                      final years =
                          data['yearsOfExperience']?.toString() ?? '0';
                      final clinic = (data['clinicName'] is List)
                          ? (data['clinicName'] as List).join(',')
                          : (data['clinicName'] ?? '');

                      return DoctorListCard(
                        id: doctors[index].id,
                        name: "$firstName $lastName",
                        speciality: speciality,
                        rating: rating,
                        experience: "$years years",
                        hospital: clinic,
                        image: "assets/images/john.png",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorListCard extends StatefulWidget {
  final String id;
  final String name;
  final String speciality;
  final String rating;
  final String experience;
  final String hospital;
  final String image;

  const DoctorListCard({
    super.key,
    required this.id,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.experience,
    required this.hospital,
    required this.image,
  });

  @override
  State<DoctorListCard> createState() => _DoctorListCardState();
}

class _DoctorListCardState extends State<DoctorListCard> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),

          child: Column(
            children: [
              Row(
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      widget.image,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 15),

                  /// INFOS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          widget.speciality,
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 16,
                            ),

                            const SizedBox(width: 4),

                            Text(widget.rating),

                            const SizedBox(width: 10),

                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Text(widget.experience),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.blue,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              widget.hospital,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorProfile(doctorId: widget.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "About",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
