import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/* ───────────── asset helpers ────────────────────────────────────── */

const _svgPrefix = 'assets/';

String _glyphPath(String ch) {
  if (RegExp(r'[0-9]').hasMatch(ch)) {
    return '${_svgPrefix}numbers/HQ_font_$ch.svg';
  }
  if (ch == '.') return '${_svgPrefix}numbers/HQ_font_period.svg';
  return '${_svgPrefix}letters/HQ_font_${ch.toUpperCase()}.svg';
}

class _Glyph extends StatelessWidget {
  final String ch;
  final double size;
  const _Glyph(this.ch, {required this.size});
  @override
  Widget build(BuildContext ctx) =>
      SvgPicture.asset(_glyphPath(ch), width: size, height: size);
}

/// Render any string with the custom SVG font.
class _FontString extends StatelessWidget {
  final String text;
  final double big, small, spacing;
  const _FontString(
      this.text, {
        this.big = 64,
        this.small = 16,
        this.spacing = 2,
      });
  @override
  Widget build(BuildContext ctx) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Glyph(text[0], size: big),
      ...text.substring(1).split('').map(
            (c) => Padding(
          padding: EdgeInsets.only(left: spacing),
          child: _Glyph(c, size: small),
        ),
      ),
    ],
  );
}

class _Word32 extends StatelessWidget {
  final String w;
  const _Word32(this.w);
  @override
  Widget build(BuildContext ctx) =>
      _FontString(w, big: 32, small: 32, spacing: 1);
}

/* ───────────── slanted frame ────────────────────────────────────── */

class _Slanted extends StatelessWidget {
  final double w, h;
  final Widget child;
  const _Slanted({required this.w, required this.h, required this.child});
  @override
  Widget build(BuildContext ctx) => CustomPaint(
    painter: _Painter(),
    child: SizedBox(width: w, height: h, child: child),
  );
}

class _Painter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width - s.height / 2, 0)
      ..lineTo(s.width, s.height / 2)
      ..lineTo(s.width, s.height)
      ..lineTo(s.height / 2, s.height)
      ..lineTo(0, s.height - s.height / 2)
      ..close();
    c.drawPath(p, Paint()..color = const Color(0xFF1E2B3F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ───────────── building tile ────────────────────────────────────── */

class _BuildingTile extends StatelessWidget {
  final String label, pop, path;
  const _BuildingTile(
      {required this.label, required this.pop, required this.path});
  @override
  Widget build(BuildContext ctx) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      Text('Pop. $pop',
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 4),
      SvgPicture.asset(path, width: 56, height: 56),
    ],
  );
}

/* ───────────── HQ screen ───────────────────────────────────────── */

class HQDashboardScreen extends StatelessWidget {
  const HQDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final colW = s.width / 48, rowH = s.height / 27;

    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0B1323), Color(0xFF1B2D46)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),

        /* main grid */
        Positioned.fill(
          child: Row(children: [
            /* left metrics */
            SizedBox(
              width: colW * 7,
              child: Column(children: [
                _metric(colW, rowH, 'STREAK', '2333'),
                _metric(colW, rowH, 'RANK', '15'),
                _metric(colW, rowH, 'MULT', '1.48'),
                _metric(colW, rowH, 'EXP', '5846/7025'),
              ]),
            ),

            /* middle column */
            SizedBox(
              width: colW * 24,
              child: Column(children: [
                SizedBox(
                    height: rowH,
                    child: Center(
                        child: SvgPicture.asset(
                            '${_svgPrefix}template_svgs/HQ_font.svg',
                            height: rowH))),
                Row(children: [
                  /* tasks column */
                  Expanded(
                    child: Column(children: [
                      _panel(colW * 12, rowH * 3, const [
                        _Word32('TASKS'),
                        _Word32('DONE')
                      ]),
                      _panelBody(colW * 12, rowH * 7,
                          const Center(child: _FontString('12'))),
                      SizedBox(height: rowH * .5),
                      _panel(colW * 12, rowH * 3, const [
                        _Word32('TASK'),
                        _Word32('HISTORY')
                      ]),
                      _panelBody(colW * 12, rowH * 7, const SizedBox()),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  /* badges/custom column */
                  Expanded(
                    child: Column(children: [
                      _panel(colW * 11, rowH * 3, const [_Word32('BADGES')]),
                      _panelBody(colW * 11, rowH * 6, const SizedBox()),
                      SizedBox(height: rowH * .5),
                      _panel(
                          colW * 11, rowH * 3, const [_Word32('CUSTOMIZATION')]),
                      _panelBody(colW * 11, rowH * 6, const SizedBox()),
                    ]),
                  ),
                ]),
                SizedBox(height: rowH * .5),

                /* town */
                Row(children: [
                  Expanded(
                      child: SizedBox(
                          height: rowH * 10,
                          child: Stack(fit: StackFit.expand, children: [
                            SvgPicture.asset(
                              '${_svgPrefix}buildings/HQ_town_land.svg',
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                                children: const [
                                  _BuildingTile(
                                      label: 'Finance',
                                      pop: '1 014',
                                      path:
                                      '${_svgPrefix}buildings/castle/HQ_castle.svg'),
                                  _BuildingTile(
                                      label: 'Homelife',
                                      pop: '430',
                                      path:
                                      '${_svgPrefix}buildings/bighouse/HQ_bighouse.svg'),
                                  _BuildingTile(
                                      label: 'School',
                                      pop: '89',
                                      path:
                                      '${_svgPrefix}buildings/cabin/HQ_cabin.svg'),
                                  _BuildingTile(
                                      label: 'Work',
                                      pop: '12',
                                      path:
                                      '${_svgPrefix}buildings/tent/HQ_tent.svg'),
                                  _BuildingTile(
                                      label: 'Guild',
                                      pop: '54',
                                      path:
                                      '${_svgPrefix}buildings/house/HQ_house.svg'),
                                  _BuildingTile(
                                      label: 'Tower',
                                      pop: '8',
                                      path:
                                      '${_svgPrefix}buildings/tower/HQ_tower.svg'),
                                ],
                              ),
                            ),
                          ]))),
                ]),
              ]),
            ),

            /* right column */
            Expanded(
                child: Column(children: [
                  _border(rowH * 13, const _Word32('CALENDAR')),
                  const SizedBox(height: 8),
                  Expanded(child: _border(double.infinity, const _Word32('MISC')))
                ])),
          ]),
        ),

        /* XP bubble */
        Positioned(
            right: 24,
            top: rowH * 2,
            child: Transform.rotate(
                angle: math.pi / 9,
                child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: Colors.white24, shape: BoxShape.circle),
                    child:
                    const _FontString('XP+12', big: 24, small: 12)))),
      ]),
    );
  }

  /* helpers */
  Widget _metric(double cw, double rh, String t, String v) => Column(children: [
    _Slanted(
        w: cw * 7,
        h: rh * 4,
        child:
        Padding(padding: const EdgeInsets.only(left: 12), child: _Word32(t))),
    const SizedBox(height: 4),
    _FontString(v),
    SizedBox(height: rh),
  ]);

  Widget _panel(double w, double h, List<Widget> lines) => _Slanted(
    w: w,
    h: h,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: lines),
  );

  Widget _panelBody(double w, double h, Widget child) =>
      Container(width: w, height: h, color: const Color(0xFF0E1829), child: child);

  Widget _border(double h, Widget child) => Container(
    height: h,
    width: double.infinity,
    decoration:
    BoxDecoration(border: Border.all(color: Colors.white, width: 3)),
    child: Center(child: child),
  );
}