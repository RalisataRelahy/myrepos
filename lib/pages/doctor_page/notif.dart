import 'package:flutter/material.dart';

// Page Notification côté docteur
class NotificationPageDoc extends StatefulWidget {
  const NotificationPageDoc({super.key});

  @override
  State<NotificationPageDoc> createState() => _NotificationPageDocState();
}

class _NotificationPageDocState extends State<NotificationPageDoc> {
  // Liste des notifications
  List<Map<String, dynamic>> notifications = [
    {
      "type": "appointment_request",
      "image":"https://i.pravatar.cc/150?img=1",
      "title": "Demande de rendez-vous",
      "subtitle": "Emma Smith souhaite prendre un rendez-vous",
      "time": "Aujourd'hui 09:00 AM",
      "status": "pending", // pending / accepted / refused
      "unread": true,
    },
    {
      "type": "like",
      "image": "https://i.pravatar.cc/150?img=2",
      "title": "Patient qui a liké",
      "subtitle": "Maria Garcia aime votre profil",
      "time": "Hier",
      "unread": false,
    },
    {
      "type": "rappel_appointement",
      "image": "https://i.pravatar.cc/150?img=3",
      "title": "Rappel rendez-vous",
      "subtitle": "James doit prendre son médicament Aspirine maintenant",
      "time": "2 jours",
      "unread": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return NotificationCardDoc(
            item: item,
            onAccept: () {
              setState(() {
                notifications[index]['status'] = "accepted";
                notifications[index]['unread'] = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Rendez-vous accepté pour ${item['subtitle']}")),
              );
            },
            onRefuse: () {
              setState(() {
                notifications[index]['status'] = "refused";
                notifications[index]['unread'] = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Rendez-vous refusé pour ${item['subtitle']}")),
              );
            },
          );
        },
      ),
    );
  }
}

// Widget pour chaque notification
class NotificationCardDoc extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onAccept;
  final VoidCallback? onRefuse;

  const NotificationCardDoc({
    super.key,
    required this.item,
    this.onAccept,
    this.onRefuse,
  });

  // Couleur selon type
  Color getTypeColor() {
    switch (item['type']) {
      case "appointment_request":
        return Colors.blue.shade50;
      case "like":
        return Colors.blue.shade50;
      case "rappel_appointement":
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: getTypeColor(),
                    backgroundImage: NetworkImage(item['image']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 3),
                        Text(item['subtitle'], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 3),
                        Text(item['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              // Boutons Accepter / Refuser uniquement pour les demandes de rendez-vous
              if (item['type'] == "appointment_request" && item['status'] == "pending")
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Accepter"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: onRefuse,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Refuser"),
                      ),
                    ],
                  ),
                ),

              // Affichage du statut si accepté ou refusé
              if (item['type'] == "appointment_request" && item['status'] != "pending")
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    item['status'] == "accepted" ? "Rendez-vous accepté" : "Rendez-vous refusé",
                    style: TextStyle(
                      color: item['status'] == "accepted" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Badge rouge pour notifications non lues
        if (item['unread'])
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}