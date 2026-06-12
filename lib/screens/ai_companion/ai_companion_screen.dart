import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/ai_message.dart';
import '../../providers/health_provider.dart';

class AiCompanionScreen extends StatefulWidget {
  const AiCompanionScreen({super.key});

  @override
  State<AiCompanionScreen> createState() => _AiCompanionScreenState();
}

class _AiCompanionScreenState extends State<AiCompanionScreen> with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  
  bool _isVoiceMode = true; // Default to beautiful voice mode!
  bool _isListening = false;
  bool _isAuroraSpeaking = false;
  String _listeningTranscript = "";

  late AnimationController _pulseController;

  final List<String> _suggestedPrompts = [
    "How am I doing this week?",
    "I drank 500ml water.",
    "I slept 7.5 hours last night.",
    "Create a habit to Meditate.",
    "What habits should I focus on?",
    "Did I drink enough water today?",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Handle message sending (Text or simulated Voice)
  Future<void> _handleSendMessage(String text, {required bool voice}) async {
    if (text.trim().isEmpty) return;
    
    final provider = Provider.of<HealthProvider>(context, listen: false);

    if (voice) {
      setState(() {
        _isListening = false;
        _isAuroraSpeaking = true;
        _pulseController.repeat(reverse: true);
      });
    }

    await provider.sendMessage(text, isVoice: voice);
    _scrollToBottom();

    if (voice) {
      // Aurora speaks. Stop pulsing after duration or simulate reading time
      int speakSeconds = (provider.messages.last.text.length / 12).round().clamp(2, 6);
      await Future.delayed(Duration(seconds: speakSeconds));
      if (mounted) {
        setState(() {
          _isAuroraSpeaking = false;
          _pulseController.stop();
          _pulseController.value = 0.0;
        });
      }
    }
  }

  // Simulate speaking input press-and-hold
  void _startListeningSimulated() {
    setState(() {
      _isListening = true;
      _listeningTranscript = "Listening...";
      _pulseController.repeat(reverse: true);
    });

    // Pick a random suggestion or trigger listening simulation text
    final randomPrompt = _suggestedPrompts[Random().nextInt(_suggestedPrompts.length)];
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isListening && mounted) {
        setState(() {
          _listeningTranscript = "Aurora, $randomPrompt";
        });
      }
    });
  }

  void _stopListeningSimulated() {
    if (!_isListening) return;
    
    final finalCommand = _listeningTranscript.replaceFirst("Aurora, ", "").replaceAll("Listening...", "");
    
    if (finalCommand.isNotEmpty && finalCommand != "Listening") {
      _handleSendMessage(finalCommand, voice: true);
    } else {
      setState(() {
        _isListening = false;
        _pulseController.stop();
        _pulseController.value = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final messages = provider.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aurora Coach"),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceMode ? Icons.keyboard_rounded : Icons.graphic_eq_rounded,
              color: AuroraTheme.primary,
            ),
            onPressed: () {
              setState(() {
                _isVoiceMode = !_isVoiceMode;
              });
              _scrollToBottom();
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.auroraGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main Screen Body depending on mode
              Expanded(
                child: _isVoiceMode 
                    ? _buildVoiceInterface(messages) 
                    : _buildTextChatInterface(messages),
              ),

              // Bottom control input
              _isVoiceMode 
                  ? _buildVoiceInputControls() 
                  : _buildTextInputControls(),
            ],
          ),
        ),
      ),
    );
  }

  // Text Chat UI
  Widget _buildTextChatInterface(List<AiMessage> messages) {
    return Column(
      children: [
        // Suggested prompt chips at top of chat
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _suggestedPrompts.length,
            itemBuilder: (context, index) {
              final prompt = _suggestedPrompts[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AuroraTheme.cardBg.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => _handleSendMessage(prompt, voice: false),
                ),
              );
            },
          ),
        ),
        
        // Chat bubbles list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isUser = msg.sender == "user";
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AuroraTheme.secondary.withOpacity(0.2)
                        : AuroraTheme.cardBg.withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AuroraTheme.secondary.withOpacity(0.4)
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(color: AuroraTheme.textPrimary, fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (msg.isVoice)
                            const Icon(Icons.volume_up_rounded, size: 12, color: AuroraTheme.primary)
                          else
                            const SizedBox.shrink(),
                          if (msg.isVoice) const SizedBox(width: 4) else const SizedBox.shrink(),
                          Text(
                            DateFormat('hh:mm a').format(msg.timestamp),
                            style: TextStyle(color: AuroraTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Text keyboard inputs
  Widget _buildTextInputControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AuroraTheme.cardBg.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: "Ask Aurora anything...",
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  _handleSendMessage(val, voice: false);
                  _textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AuroraTheme.primary,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: AuroraTheme.darkBg),
              onPressed: () {
                final txt = _textController.text;
                if (txt.isNotEmpty) {
                  _handleSendMessage(txt, voice: false);
                  _textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Voice Orbit UI Interface
  Widget _buildVoiceInterface(List<AiMessage> messages) {
    final String lastResponse = messages.isNotEmpty 
        ? messages.last.text 
        : "Tap and hold the microphone to talk with Aurora.";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Voice Mode Slogan / Heading
          Text(
            _isListening 
                ? "Listening..." 
                : _isAuroraSpeaking 
                    ? "Aurora Speaking..." 
                    : "Aurora Voice Assistant",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AuroraTheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 32),

          // Central Pulsating Orb
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring 2
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.8);
                    final opacity = (1.0 - _pulseController.value).clamp(0.0, 0.4);
                    return Container(
                      width: 180,
                      height: 180,
                      transform: Matrix4.identity()..scale(scale),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AuroraTheme.primary.withOpacity(opacity),
                      ),
                    );
                  },
                ),
                // Outer Pulse Ring 1
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.4);
                    final opacity = (1.0 - _pulseController.value).clamp(0.0, 0.6);
                    return Container(
                      width: 140,
                      height: 140,
                      transform: Matrix4.identity()..scale(scale),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AuroraTheme.secondary.withOpacity(opacity),
                      ),
                    );
                  },
                ),
                // Solid Inner Orb
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AuroraTheme.primary, AuroraTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AuroraTheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.blur_on_rounded,
                    size: 54,
                    color: AuroraTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Dialog Response Display Card
          Card(
            color: AuroraTheme.cardBg.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _isListening ? _listeningTranscript : lastResponse,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AuroraTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Voice buttons
  Widget _buildVoiceInputControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Column(
        children: [
          // Suggestions for voice
          const Text(
            "TAP AND HOLD TO SPEAK",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: AuroraTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          // Glowing microphone button
          GestureDetector(
            onTapDown: (_) => _startListeningSimulated(),
            onTapUp: (_) => _stopListeningSimulated(),
            onTapCancel: () => _stopListeningSimulated(),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening 
                    ? Colors.redAccent.withOpacity(0.2) 
                    : AuroraTheme.primary.withOpacity(0.15),
                border: Border.all(
                  color: _isListening ? Colors.redAccent : AuroraTheme.primary,
                  width: 2.0,
                ),
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? Colors.redAccent : AuroraTheme.primary,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
