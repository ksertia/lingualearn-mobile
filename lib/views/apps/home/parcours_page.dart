// import 'package:flutter/material.dart';
// import '../../../models/module_model.dart';
// import '../../../widgets/module_card.dart';
// import '../../../widgets/timeline_dot.dart';
// class ParcoursPage extends StatelessWidget {
//   ParcoursPage({super.key});

//   final List<ModuleModel> modules = [
//     ModuleModel(
//       id: '1',
//       title: 'Module 1',
//       subtitle: 'Bases : Salutations',
//       completedLessons: 5,
//       totalLessons: 5,
//       status: ModuleStatus.completed,
//     ),
//     ModuleModel(
//       id: '2',
//       title: 'Module 2',
//       subtitle: 'Présentations',
//       completedLessons: 2,
//       totalLessons: 5,
//       status: ModuleStatus.inProgress,
//     ),
//     ModuleModel(
//       id: '3',
//       title: 'Module 3',
//       subtitle: 'Expressions courantes',
//       completedLessons: 0,
//       totalLessons: 5,
//       status: ModuleStatus.locked,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: true,
//         centerTitle: true,
//         title: Column(
//           children: const [
//             Text(
//               'Apprendre le Mooré',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Niveau : Débutant',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//       ),

//       body: ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
//         itemCount: modules.length,
//         itemBuilder: (context, index) {
//           final module = modules[index];

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 28),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TimelineDot(status: module.status),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ModuleCard(
//                     module: module,
//                     onTap: () {},
//                   ),
//                 ),
//               ],
//             ),
//           );

//         },
//       ),
//     );
//   }
// }
