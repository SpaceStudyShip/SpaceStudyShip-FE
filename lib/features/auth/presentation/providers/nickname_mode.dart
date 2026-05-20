/// 닉네임 화면 진입 컨텍스트.
enum NicknameMode {
  /// 신규 회원 첫 로그인: 백버튼 차단, 완료 시 router redirect 가 /home 으로.
  initialSetup,

  /// 설정 메뉴 자발적 변경: 백버튼 있음, 완료 시 context.pop().
  edit,
}
