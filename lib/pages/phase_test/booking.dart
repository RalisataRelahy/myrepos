
// import 'package:medilink_flutter/pages/send.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';

// class BookingPage extends StatefulWidget {
//   const BookingPage({super.key});

//   @override
//   State<BookingPage> createState() => _BookingPageState();
// }

// class _BookingPageState extends State<BookingPage> {

//   DateTime today = DateTime.now();
//   DateTime? selectedDay;

//   int selectedTime = -1;
//   int consultationType = 0;

//   List<String> times = [
//     "09:00",
//     "09:30",
//     "10:00",
//     "10:30",
//     "11:00",
//     "11:30"
//   ];

//   List<String> consultationTypes = [
//     "Clinic Visit",
//     "HomePatient",
//     "HomeDoctor"
//   ];
//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text("Booking Appointment"),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             /// DOCTOR INFO
//             Column(
//               children: [
//                 Row(
//                   children: [

//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Image.asset(
//                         "assets/images/1773120350398.jpg",
//                         height: 70,
//                         width: 70,
//                         fit: BoxFit.cover,
//                       ),
//                     ),

//                     const SizedBox(width: 15),

//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [

//                         Text(
//                           "Dr. Anne Mendez",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         Text(
//                           "Cardiology speciality",
//                           style: TextStyle(color: Colors.grey),
//                         ),

//                         Row(
//                           children: [
//                             Icon(Icons.favorite,
//                                 color: Colors.red,
//                                 size: 16),
//                             Text(" 200")
//                           ],
//                         ),
//                         Row(
//                           children: [

//                             Icon(Icons.location_on,
//                               size: 16, color: Colors.blue),

//                             SizedBox(width: 4),

//                             Text(
//                               "Balance Care Clinic",
//                               style: TextStyle(color: Colors.grey),
//                             )
//                           ]
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//                 SizedBox(height: 5,),
//                 Text("Consultation Price: 30000 Ar", 
//                 style: TextStyle(
//                   fontSize: 15
//                 ),)
                
//               ],
//             ),

//             const SizedBox(height: 20),

//             /// CALENDAR
//             const Text(
//               "Select Date",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),


//             TableCalendar(

//               focusedDay: today,

//               firstDay: DateTime.now(), // empêche les jours passés

//               lastDay: DateTime(2030),

//               selectedDayPredicate: (day) {
//                 return isSameDay(selectedDay, day);
//               },

//               onDaySelected: (selected, focused) {

//                 setState(() {
//                   selectedDay = selected;
//                   today = focused;
//                 });
//               },
//               calendarStyle: CalendarStyle(
//                 todayDecoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   shape: BoxShape.circle,
//                 ),
//                 selectedDecoration: const BoxDecoration(
//                   color: Colors.blue,
//                   shape: BoxShape.circle,
//                 )
//               ),

//             ),

//             const SizedBox(height: 10),

//             /// TIME
//             const Text(
//               "Select Time",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: List.generate(times.length, (index) {

//                 bool isSelected = selectedTime == index;

//                 return GestureDetector(
//                   onTap: () {

//                     setState(() {
//                       selectedTime = index;
//                     });

//                   },

//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 18,
//                         vertical: 10),

//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Colors.blue
//                           : Colors.grey.shade200,

//                       borderRadius:
//                       BorderRadius.circular(20),
//                     ),

//                     child: Text(
//                       times[index],
//                       style: TextStyle(
//                         color: isSelected
//                             ? Colors.white
//                             : Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),

//             const SizedBox(height: 20),

//             /// CONSULTATION TYPE
//             const Text(
//               "Consultation Type",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10,),

//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: 
//               List.generate(consultationTypes.length, (index){
//                 bool isSelected = consultationType == index;

//                 return GestureDetector(
//                   onTap: (){
//                     setState(() {
//                       consultationType = index;
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 18,
//                       vertical: 10 
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.blue : Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(20)
//                     ),
//                     child: Text(
//                       consultationTypes[index],
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               })
//             ),
            
//             /// TOTAL

//             const SizedBox(height: 15),

//             /// BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(

//                 onPressed: () {

//                   if(selectedDay == null || selectedTime == -1){
//                     ScaffoldMessenger.of(context)
//                         .showSnackBar(
//                         const SnackBar(
//                           content:
//                           Text("Please select date and time"),
//                         ));
//                     return;
//                   }
//                   else{
//                     Navigator.push(context, MaterialPageRoute(builder: (constext)=>Sended()));
//                   }

//                 },

//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.all(15),
//                   backgroundColor: Colors.blue,
//                 ),

//                 child: const Text(
//                   "Confirm Booking",
//                   style: TextStyle(fontSize: 16 , color: Colors.white),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }