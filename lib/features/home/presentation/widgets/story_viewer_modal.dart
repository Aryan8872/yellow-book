import 'package:flutter/material.dart';

class StoryViewerModal extends StatefulWidget {
  final String mediaUrl;
  final String title;
  final VoidCallback onClose;

  const StoryViewerModal({
    super.key,
    required this.mediaUrl,
    required this.title,
    required this.onClose,
  });

  @override
  State<StoryViewerModal> createState() => _StoryViewerModalState();
}

class _StoryViewerModalState extends State<StoryViewerModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward().whenComplete(() {
        widget.onClose();
      });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => _progressController.stop(),
        onTapUp: (_) => _progressController.forward(),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            widget.onClose();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media Background (Simulating Video/Image story)
            Image.network(
              widget.mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 80),
                ),
              ),
            ),
            // Gradient Overlay for readability
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black54],
                ),
              ),
            ),
            // Top Header (Progress Bar & Title)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title & Close Button
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF346EF6),
                          child: Icon(Icons.store, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
