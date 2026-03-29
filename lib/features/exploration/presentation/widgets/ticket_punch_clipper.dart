import 'package:flutter/material.dart';

/// 티켓 상단 펀치 자국 CustomClipper
///
/// 해금된 티켓의 상단 테두리에 반원 홈을 표현합니다.
/// [punched]가 true일 때만 펀치 자국이 적용됩니다.
///
/// 펀치 위치: 상단 테두리 좌우 대칭 (25%, 75% 지점)
class TicketPunchClipper extends CustomClipper<Path> {
  TicketPunchClipper({
    required this.punched,
    this.punchRadius = 10.0,
    this.borderRadius = 12.0,
  });

  final bool punched;
  final double punchRadius;
  final double borderRadius;

  @override
  Path getClip(Size size) {
    final path = Path();

    if (!punched) {
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );
      return path;
    }

    final leftPunchX = size.width * 0.25;
    final rightPunchX = size.width * 0.75;
    final r = punchRadius;
    final br = borderRadius;

    // 시작: 좌측 상단 둥근 모서리
    path.moveTo(0, br);
    path.quadraticBezierTo(0, 0, br, 0);

    // 좌측 펀치까지 직선
    path.lineTo(leftPunchX - r, 0);

    // 좌측 펀치 반원 (위로 파임)
    path.arcToPoint(
      Offset(leftPunchX + r, 0),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // 우측 펀치까지 직선
    path.lineTo(rightPunchX - r, 0);

    // 우측 펀치 반원 (위로 파임)
    path.arcToPoint(
      Offset(rightPunchX + r, 0),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // 우측 상단 둥근 모서리
    path.lineTo(size.width - br, 0);
    path.quadraticBezierTo(size.width, 0, size.width, br);

    // 우측 하단 둥근 모서리
    path.lineTo(size.width, size.height - br);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - br,
      size.height,
    );

    // 좌측 하단 둥근 모서리
    path.lineTo(br, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - br);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketPunchClipper oldClipper) =>
      punched != oldClipper.punched ||
      punchRadius != oldClipper.punchRadius ||
      borderRadius != oldClipper.borderRadius;
}
