import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // AppBar 제목
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
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions, // 전달된 actions를 AppBar에 추가
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
