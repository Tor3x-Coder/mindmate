import 'package:flutter/material.dart';
import '../../models/check_in_context_model.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import 'guidance_result_screen.dart';

class GuidanceLoadingScreen extends StatefulWidget {
  final CheckInContext checkInContext;

  const GuidanceLoadingScreen({
    super.key,
    required this.checkInContext,
  });

  @override
  State<GuidanceLoadingScreen> createState() => _GuidanceLoadingScreenState();
}

class _GuidanceLoadingScreenState extends State<GuidanceLoadingScreen> {
  final ChatService _chatService = ChatService();
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGuidance();
  }

  Future<void> _fetchGuidance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Debug: show what we're sending
    debugPrint('[Guidance] Sending check-in: ${widget.checkInContext.toJson()}');
    debugPrint('[Guidance] FreeText: "${widget.checkInContext.boundedFreeText}"');

    try {
      final response = await _chatService.sendGuidance(
        checkInContext: widget.checkInContext,
      );

      debugPrint('[Guidance] Received reply: ${response.reply}');
      debugPrint('[Guidance] Next step: ${response.guidance.nextStep.actionId} - ${response.guidance.nextStep.title}');
      debugPrint('[Guidance] What might be happening: ${response.guidance.whatMightBeHappening}');
      debugPrint('[Guidance] Is crisis: ${response.guidance.isCrisis}');
      debugPrint('[Guidance] Alternatives: ${response.guidance.alternatives.map((a) => a.actionId).join(', ')}');

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GuidanceResultScreen(
            checkInContext: widget.checkInContext,
            guidanceResponse: response.guidance,
            chatAction: response.action,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finding your next step')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: _isLoading ? _buildLoading() : _buildError(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Understanding your check-in...',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'MindMate is generating a personalised, non-diagnostic next step based on what you shared.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.checkInContext.feeling.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.checkInContext.feeling.displayLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.checkInContext.energySource.displayLabel} • ${widget.checkInContext.need.displayLabel}',
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.cloud_off_rounded,
            size: 48, color: AppTheme.textLight),
        const SizedBox(height: 16),
        Text(
          'Could not generate your next step',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Something went wrong. Please try again.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _fetchGuidance,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Go back to check-in'),
        ),
      ],
    );
  }
}
