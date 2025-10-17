import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // SocketException 사용을 위해 필요
import 'dart:async'; // TimeoutException 사용을 위해 필요

// 서버 연결 상태를 나타내는 열거형
enum ConnectionStatus {
  initial,
  connecting,
  success,
  serverError,
  networkError,
}

void main() {
  runApp(const LocalServerCheckerApp());
}

class LocalServerCheckerApp extends StatelessWidget {
  const LocalServerCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로컬 백엔드 연결 확인',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const ConnectionCheckerScreen(),
    );
  }
}

class ConnectionCheckerScreen extends StatefulWidget {
  const ConnectionCheckerScreen({super.key});

  @override
  State<ConnectionCheckerScreen> createState() => _ConnectionCheckerScreenState();
}

class _ConnectionCheckerScreenState extends State<ConnectionCheckerScreen> {
  // 연결 상태를 저장하는 변수
  ConnectionStatus _status = ConnectionStatus.initial;
  // 결과를 사용자에게 보여줄 메시지
  String _message = '테스트할 로컬 서버 주소를 입력하고 확인 버튼을 누르세요.';

  // 사용자가 URL을 입력할 수 있는 컨트롤러
  late TextEditingController _urlController;
  // 기본 로컬 서버 URL (Android 에뮬레이터에서 로컬 PC의 8080 포트로 접속)
  final String _defaultLocalUrl = 'http://10.0.2.2:8080/health';

  @override
  void initState() {
    super.initState();
    // 초기 URL을 기본값으로 설정
    _urlController = TextEditingController(text: _defaultLocalUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // 로컬 서버 연결을 확인하는 핵심 비동기 함수
  Future<void> checkLocalServerConnection() async {
    final String url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _status = ConnectionStatus.initial;
        _message = '⚠️ 연결할 URL을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _status = ConnectionStatus.connecting;
      _message = '서버 ($url)에 연결 중...';
    });

    try {
      // 서버에 GET 요청을 보내고 5초 타임아웃 설정
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // HTTP 상태 코드가 200이면 성공
        setState(() {
          _status = ConnectionStatus.success;
          _message = '✅ 연결 성공! (Status Code: 200)';
          if (response.body.isNotEmpty) {
            _message += '\n서버 응답 내용 (Body):\n${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...';
          }
        });
      } else {
        // 200이 아니면 서버는 응답했으나, 서버 내부 오류 (예: 404, 500 등)
        setState(() {
          _status = ConnectionStatus.serverError;
          _message = '❌ 서버 오류 (Status Code: ${response.statusCode})';
        });
      }
    } on TimeoutException {
      // 타임아웃 발생 (5초 이내에 서버가 응답하지 않음)
      setState(() {
        _status = ConnectionStatus.networkError;
        _message = '❌ 연결 시간 초과: 5초 이내에 서버 응답을 받지 못했습니다.\n서버가 실행 중인지, 방화벽이 막고 있지 않은지 확인하세요.';
      });
    } on SocketException catch (e) {
      // 소켓 오류 (네트워크 연결 끊김, URL 도달 불가 등)
      setState(() {
        _status = ConnectionStatus.networkError;
        _message = '❌ 네트워크/소켓 오류: 서버 주소에 도달할 수 없습니다.\n($e)\n\n로컬 IP와 포트 설정을 다시 확인하세요.';
      });
    } catch (e) {
      // 기타 예상치 못한 오류
      setState(() {
        _status = ConnectionStatus.networkError;
        _message = '⚠️ 알 수 없는 오류 발생: $e';
      });
    }
  }

  // 현재 상태에 따른 아이콘 위젯 반환
  Widget _buildIcon() {
    switch (_status) {
      case ConnectionStatus.initial:
        return const Icon(Icons.link_off, size: 80, color: Colors.grey);
      case ConnectionStatus.connecting:
        return const SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(strokeWidth: 6, color: Colors.indigo),
        );
      case ConnectionStatus.success:
        return const Icon(Icons.check_circle, size: 80, color: Colors.green);
      case ConnectionStatus.serverError:
        return const Icon(Icons.warning_amber, size: 80, color: Colors.orange);
      case ConnectionStatus.networkError:
        return const Icon(Icons.cancel, size: 80, color: Colors.red);
    }
  }

  // 현재 상태에 따른 메시지 스타일 반환
  Color _getMessageColor() {
    switch (_status) {
      case ConnectionStatus.success:
        return Colors.green.shade800;
      case ConnectionStatus.serverError:
        return Colors.orange.shade800;
      case ConnectionStatus.networkError:
        return Colors.red.shade800;
      case ConnectionStatus.connecting:
        return Colors.indigo.shade800;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로컬 백엔드 연결 상태 확인'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // URL 입력 필드
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: '테스트할 서버 URL',
                hintText: '예: http://10.0.2.2:8080/api/status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.public),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),

            // 연결 확인 버튼
            ElevatedButton.icon(
              onPressed: _status == ConnectionStatus.connecting
                  ? null // 연결 중일 때는 버튼 비활성화
                  : checkLocalServerConnection,
              icon: const Icon(Icons.cable),
              label: const Text(
                '연결 확인 시작',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),

            const SizedBox(height: 40),

            // 결과 표시 영역
            Center(child: _buildIcon()),
            const SizedBox(height: 30),

            // 상태 메시지 카드
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '연결 결과',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 20),
                    Text(
                      _message,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getMessageColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 로컬 서버 연결 가이드
            const Text(
              '⭐ 로컬 서버 테스트 가이드',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            _buildGuidanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.indigo.shade50,
      child: const Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuidancePoint(
              title: 'Android 에뮬레이터',
              content: 'URL: http://10.0.2.2:<백엔드_포트>',
            ),
            Divider(),
            GuidancePoint(
              title: 'iOS 시뮬레이터',
              content: 'URL: http://localhost:<백엔드_포트> 또는 http://127.0.0.1:<백엔드_포트>',
            ),
            Divider(),
            GuidancePoint(
              title: '실제 디바이스 (휴대폰)',
              content: 'URL: http://<PC의_로컬_IP>:<백엔드_포트> (같은 Wi-Fi 사용 필수)',
            ),
          ],
        ),
      ),
    );
  }
}

// 가이드라인 포인트를 위한 작은 위젯
class GuidancePoint extends StatelessWidget {
  final String title;
  final String content;

  const GuidancePoint({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
