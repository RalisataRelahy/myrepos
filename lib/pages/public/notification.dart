import 'package:flutter/material.dart';
import 'package:medilink_app/pages/patient_page/medical_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "type": "appointment_accepte",
        "image": "assets/images/1772983374731.jpg",
        "title": "Rendez-vous acceptée",
        "subtitle": "Dr John a accepté votre rendez-vous",
        "time": "Aujourd'hui 10:30 AM",
        "unread": true,
      },
      {
        "type": "prescription",
        "image": "assets/images/1772983374731.jpg",
        "uid": "asdfghjkodepf",
        "title": "Ordonnance envoyée",
        "subtitle": "Dr Anne vous a envoyé une ordonnance",
        "time": "Hier",
        "unread": false,
      },
      {
        "type": "appointement_refuse",
        "image": "assets/images/1772983374731.jpg",
        "title": "Appointement refusée",
        "subtitle":
            "Dr Anne vous a refusé votre demande\nVeuillez selectionner un autre temps ou date!",
        "time": "Hier",
        "unread": false,
      },
      {
        "type": "medication",
        "image": "assets/images/1772983374731.jpg",
        "title": "Rappel médicament",
        "subtitle": "Prenez votre médicament Aspirine maintenant",
        "time": "2 jours",
        "unread": true,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return NotificationCard(
            type: item['type']!,
            image: item['image']!,
            title: item['title']!,
            subtitle: item['subtitle']!,
            time: item['time']!,
            unread: item['unread']!,
            onTap: () {
              // Action selon le type
              switch (item['type']) {
                case "appointment_accepte":
                  break;
                case "prescription":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrescriptionPage()),
                  );
                  break;
                case "medication":
                  break;
                case "appointment_refuse":
                  break;
              }
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String type;
  final String image;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.type,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  // Couleur selon type
  Color getTypeColor() {
    switch (type) {
      case "appointment_accepte":
        return Colors.blue.shade50;
      case "prescription":
        return Colors.green.shade50;
      case "medication":
        return Colors.orange.shade50;
      case "appointment_refuse":
        return Colors.blue.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: getTypeColor(),
                  backgroundImage: AssetImage(image),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Badge rouge pour notification non lue
          if (unread)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Page de détail générique
class DetailPage extends StatelessWidget {
  final String title;
  const DetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          "Détails pour $title",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
