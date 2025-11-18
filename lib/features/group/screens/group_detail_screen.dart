import 'package:flutter/material.dart';
// 1. ⭐️ (필수) 하단 내비게이션 바 임포트
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

// 2. ⭐️ (핵심) 버튼 타입 정의 (기존과 동일)
enum GroupDetailButtonType {
  none,//팀원이 소모임 세부사항 볼 때
  join,//오늘의 추천활동 세부사항
  joinOrInquire,//문의 or 참가신청
  acceptOrDecline,//참가신청 수락 or 거절
}

// 3. ⭐️ GroupDetailScreen (기존과 동일)
class GroupDetailScreen extends StatefulWidget {
  final GroupDetailButtonType buttonType;
  // final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.buttonType,
    // required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  // --- 4. ⭐️ 색상 정의 (기존과 동일) ---
  final Color _borderColor = const Color(0xFF4C6DAF);
  final Color _buttonColor70 = const Color(0xFF4C6DAF).withOpacity(0.7);

  // --- 5. ⭐️ 하단 내비게이션 탭 핸들러 (기존과 동일) ---
  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        print('🏠 홈 이동');
        Navigator.pushNamed(context, '/home');
        break;
      case 'chat':
        print('💬 채팅 탭');
      case 'connection':
        print('🔗 소모임 연결');
        Navigator.pushNamed(context, '/my-group-manage');
        break;
        break;
      case 'bell':
        print('🔔 알림 탭');
        Navigator.pushNamed(context, '/notification');
        break;
      case 'profile':
        print('👤 프로필 탭');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (AppBar는 기존과 동일)
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("세부정보",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      // 6. ⭐️ (수정) persistent... 속성 2줄 완전 삭제
      // persistentFooterButtons: ... (삭제)
      // persistentFooterButtonAlignment: ... (삭제)

      // 7. ⭐️ 하단 내비게이션 바 (기존과 동일)
      bottomNavigationBar: CustomBottomNavBar(
        onTabSelected: _handleBottomTap,
      ),

      // 8. ⭐️ (수정) body 구조 변경
      body: Column( // 👈 1. body를 Column으로
        children: [
          // 2. 콘텐츠 영역 (스크롤 가능)
          Expanded( // 👈 2. Expanded로 감싸서 남은 공간 모두 차지
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // 소모임 대표 이미지
                  Container(
                    width: 150,
                    height: 150,
                    // ... (이미지 스타일 동일)
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_icon.png', // (데이터)
                        fit: BoxFit.contain,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 소모임 이름
                  const Text(
                    '[소모임 이름]', // (데이터)
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 모임 정보 프레임 (기존과 동일)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('모임 주제 :', '투자ㆍ소비습관'), // (데이터)
                        const SizedBox(height: 15),
                        _buildInfoRow('인원 수 :', '6/10명'), // (데이터)
                        const SizedBox(height: 15),
                        _buildInfoRow('모임 설명 :', '이 모임은 소비 습관을 개선하고 함께 투자 공부를 하는 모임입니다.'), // (데이터)
                        const SizedBox(height: 25),
                        // ... (팀장 정보 Row 동일)
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400, width: 1),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '[팀장 닉네임]', // (데이터)
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '관심사 : 유저 관심사', // (데이터)
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // ⭐️ 하단 여백 (버튼과 겹치지 않게)
                ],
              ),
            ),
          ), // 👈 2. Expanded 끝

          // 3. ⭐️ 하단 버튼 영역 (Column의 두 번째 자식)
          // (이 영역은 스크롤되지 않고 항상 하단에 고정됨)
          _buildPersistentButtons(widget.buttonType),

          // 4. ⭐️ (필수) 하단 내비게이션 바 만큼의 안전 영역 확보
          // (버튼이 바에 가려지지 않도록)
          SafeArea(
            top: false, // 위쪽은 무시
            child: Container(),
          ),
        ],
      ),
    );
  }

  // --- 10. ⭐️ (수정) 버튼 생성 헬퍼 함수 ---
  // (반환 타입이 List<Widget>? -> Widget으로 변경)
  Widget _buildPersistentButtons(GroupDetailButtonType type) {
    // ⭐️ (수정) 버튼을 담을 컨테이너 추가
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      // ⭐️ (선택) 버튼 영역 배경색
      // color: Colors.white,
      child: switch (type) {
      // 10-1. 버튼 없음
        GroupDetailButtonType.none =>
        const SizedBox.shrink(), // 👈 1. 빈 위젯 반환

      // 10-2. 참가 신청
        GroupDetailButtonType.join =>
            _buildOneButton( // 👈 2. Row/List 없이 버튼 위젯 바로 반환
              text: '참가신청',
              color: _buttonColor70,
              onPressed: () {
                print('참가신청 클릭!');
              },
            ),

      // 10-3. 문의 / 참가
        GroupDetailButtonType.joinOrInquire =>
            _buildTwoButtons( // 👈 3. Row가 담긴 위젯 반환
              text1: '문의하기',
              text2: '참가신청',
              onPressed1: () {
                print('문의하기 클릭!');
              },
              onPressed2: () {
                print('참가신청 클릭!');
              },
            ),

      // 10-4. 거절 / 수락
        GroupDetailButtonType.acceptOrDecline =>
            _buildTwoButtons( // 👈 4. Row가 담긴 위젯 반환
              text1: '거절',
              text2: '수락',
              onPressed1: () {
                print('거절 클릭!');
              },
              onPressed2: () {
                print('수락 클릭!');
              },
            )
      },
    );
  }

  // --- 11. ⭐️ 버튼 스타일 헬퍼 (기존과 동일, Padding만 제거) ---

  // (버튼 1개)
  Widget _buildOneButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text,
            style:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // (버튼 2개)
  Widget _buildTwoButtons({
    required String text1,
    required String text2,
    required VoidCallback onPressed1,
    required VoidCallback onPressed2,
  }) {
    final Color buttonColor1 = _buttonColor70;
    final Color buttonColor2 = _buttonColor70;

    return Row( // 👈 Row 위젯을 바로 반환
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed1,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor1,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(text1,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed2,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor2,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(text2,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- 12. ⭐️ 정보 행(Row) 스타일 헬퍼 (기존과 동일) ---
  Widget _buildInfoRow(String label, String value) {
    bool isMultiline = label.contains("설명");
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value, // (데이터)
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
              maxLines: isMultiline ? 5 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}