import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title; // 제목으로 텍스트, 이미지, 아이콘 등을 받을 수 있도록 수정
  final List<Widget>? actions; // AppBar 오른쪽 아이콘들
  final VoidCallback? onBackPressed; // 왼쪽 뒤로가기 버튼 동작

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ??
                () => Navigator.pop(context), // 기본 동작: Navigator.pop
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
        children: [
          if (title is String)
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (title is Widget)
            title, // 아이콘 또는 다른 위젯이 제목인 경우
        ],
      ),
      centerTitle: false, // Row를 사용하므로 centerTitle은 비활성화
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions ?? [SizedBox(width: 56)], // 오른쪽 아이콘이 없으면 여백 추가
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}