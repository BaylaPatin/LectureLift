import 'package:flutter/material.dart';

class NumbersWidget extends StatelessWidget {
  const NumbersWidget({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildButton(context, '0', 'Ranking'),
      buildDivider(),
      buildButton(context, '0', 'Following'),
      buildDivider(),
      buildButton(context, '0', 'Followers'),
    ],
  );

  Widget buildDivider() => SizedBox(
    height: 24,
    child: VerticalDivider(),
  );

  Widget buildButton(BuildContext context, String value, String text) => MaterialButton(
    padding: EdgeInsets.symmetric(vertical: 4),
    onPressed: () {},
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: 2),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}