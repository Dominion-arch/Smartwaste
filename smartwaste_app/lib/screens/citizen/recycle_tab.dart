import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class RecycleTab extends StatelessWidget {
  const RecycleTab({super.key});

  static const _bins = <(String, String, String, List<(bool, String)>, String?)>[
    ('🟢', 'General Waste', 'BLACK BIN', [
      (true, 'Food scraps'), (true, 'Soiled paper / packaging'), (true, 'Nappies & diapers'),
      (false, 'Electronics or batteries'), (false, 'Hazardous chemicals'),
    ], null),
    ('🔵', 'Recyclables', 'BLUE BIN', [
      (true, 'Plastic bottles & containers'), (true, 'Paper & cardboard'), (true, 'Metal cans & tins'),
      (false, 'Greasy pizza boxes'), (false, 'Plastic bags'),
    ], null),
    ('🟤', 'Organic Waste', 'BROWN BIN', [
      (true, 'Fruit & vegetable peels'), (true, 'Coffee grounds & tea bags'), (true, 'Grass & leaves'),
      (false, 'Meat & fish'), (false, 'Cooked food'),
    ], null),
    ('🔴', 'Hazardous', 'RED BIN (special)', [
      (true, 'Batteries & bulbs'), (true, 'Paint & solvents'), (true, 'Pesticides'), (true, 'Medical sharps'),
    ], '⚠ Call 0302-XXX for special pickup'),
  ];

  static const _tips = [
    'Rinse containers before placing in the blue bin — food residue contaminates batches.',
    'Flatten cardboard boxes to save space.',
    'Plastic bags are NOT recyclable — return to supermarkets.',
    'Remove lids from glass bottles before placing in the glass bin.',
    'E-waste drop points: Sunyani Market & Sunyani Technical University (StuTec).',
    'Compost fruit peels at home to cut organic waste by up to 30%.',
  ];

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('♻️ Sunyani Recycling Guide'),
              const Text(
                'Separate your waste to help SmartWaste sort and process materials efficiently.',
                style: TextStyle(fontSize: 13, color: C.text2),
              ),
              const SizedBox(height: 14),
              ..._bins.map((b) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: C.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(b.$1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(b.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(b.$3, style: mono(size: 9)),
                        ]),
                      ]),
                      const SizedBox(height: 8),
                      ...b.$4.map((i) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text('${i.$1 ? '✓' : '✗'} ${i.$2}',
                                style: TextStyle(fontSize: 12, color: i.$1 ? C.accent : C.danger)),
                          )),
                      if (b.$5 != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(b.$5!, style: const TextStyle(fontSize: 11, color: C.warn)),
                        ),
                    ]),
                  )),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PanelTitle('💡 Tips for Sunyani'),
              ..._tips.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('→  ', style: TextStyle(color: C.accent)),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: C.text2))),
                    ]),
                  )),
            ]),
          ),
        ],
      );
}
