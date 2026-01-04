import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Direction the character is facing
enum CharacterDirection {
  down,
  up,
  left,
  right,
}

/// Animated RPG-style character that can walk in 4 directions
class RpgCharacter extends StatefulWidget {
  final String emoji;
  final double size;
  final CharacterDirection direction;
  final bool isWalking;
  final Color? backgroundColor;

  const RpgCharacter({
    Key? key,
    required this.emoji,
    this.size = 64,
    this.direction = CharacterDirection.down,
    this.isWalking = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<RpgCharacter> createState() => _RpgCharacterState();
}

class _RpgCharacterState extends State<RpgCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;
  late Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bobAnimation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _tiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isWalking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RpgCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWalking != oldWidget.isWalking) {
      if (widget.isWalking) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.isWalking ? _bobAnimation.value : 0),
          child: Transform.rotate(
            angle: widget.isWalking ? _tiltAnimation.value : 0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Transform.scale(
                  scale: widget.size / 64, // Scale emoji relative to size
                  child: Text(
                    widget.emoji,
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// RPG-style movement controller for navigating between points
class RpgMovementController {
  Offset currentPosition;
  Offset? targetPosition;
  CharacterDirection currentDirection;
  bool isMoving;
  double speed; // pixels per second

  RpgMovementController({
    this.currentPosition = Offset.zero,
    this.currentDirection = CharacterDirection.down,
    this.isMoving = false,
    this.speed = 200,
  });

  /// Start moving to a target position
  void moveTo(Offset target) {
    targetPosition = target;
    isMoving = true;
    _updateDirection();
  }

  /// Update position based on elapsed time
  /// Returns true if reached target
  bool update(double deltaTime) {
    if (!isMoving || targetPosition == null) return true;

    final direction = targetPosition! - currentPosition;
    final distance = direction.distance;
    
    if (distance < speed * deltaTime) {
      // Reached target
      currentPosition = targetPosition!;
      isMoving = false;
      targetPosition = null;
      return true;
    }

    // Move towards target
    final normalized = direction / distance;
    currentPosition += normalized * speed * deltaTime;
    return false;
  }

  /// Update character direction based on target
  void _updateDirection() {
    if (targetPosition == null) return;

    final direction = targetPosition! - currentPosition;
    final angle = math.atan2(direction.dy, direction.dx);
    final degrees = angle * 180 / math.pi;

    if (degrees >= -45 && degrees < 45) {
      currentDirection = CharacterDirection.right;
    } else if (degrees >= 45 && degrees < 135) {
      currentDirection = CharacterDirection.down;
    } else if (degrees >= 135 || degrees < -135) {
      currentDirection = CharacterDirection.left;
    } else {
      currentDirection = CharacterDirection.up;
    }
  }

  /// Stop movement
  void stop() {
    isMoving = false;
    targetPosition = null;
  }
}

/// Widget that handles RPG-style character movement
class RpgMovementWidget extends StatefulWidget {
  final String characterEmoji;
  final List<Offset> waypoints; // Positions character can move to
  final int currentWaypointIndex;
  final Function(int) onWaypointReached;
  final double characterSize;
  final Size mapSize;

  const RpgMovementWidget({
    Key? key,
    required this.characterEmoji,
    required this.waypoints,
    required this.currentWaypointIndex,
    required this.onWaypointReached,
    this.characterSize = 64,
    required this.mapSize,
  }) : super(key: key);

  @override
  State<RpgMovementWidget> createState() => _RpgMovementWidgetState();
}

class _RpgMovementWidgetState extends State<RpgMovementWidget>
    with SingleTickerProviderStateMixin {
  late RpgMovementController _controller;
  late AnimationController _updateController;
  int? _targetWaypointIndex;

  @override
  void initState() {
    super.initState();
    
    _controller = RpgMovementController(
      currentPosition: _normalizePosition(widget.waypoints[widget.currentWaypointIndex]),
      speed: 200,
    );

    _updateController = AnimationController(
      duration: const Duration(days: 1), // Infinite
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  Offset _normalizePosition(Offset normalized) {
    return Offset(
      normalized.dx * widget.mapSize.width,
      normalized.dy * widget.mapSize.height,
    );
  }

  void moveToWaypoint(int waypointIndex) {
    if (waypointIndex < 0 || waypointIndex >= widget.waypoints.length) return;
    if (_controller.isMoving) return;

    setState(() {
      _targetWaypointIndex = waypointIndex;
      _controller.moveTo(_normalizePosition(widget.waypoints[waypointIndex]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _updateController,
      builder: (context, child) {
        // Update movement
        if (_controller.isMoving) {
          final reached = _controller.update(1 / 60); // Assume 60fps
          if (reached && _targetWaypointIndex != null) {
            widget.onWaypointReached(_targetWaypointIndex!);
            setState(() {
              _targetWaypointIndex = null;
            });
          }
        }

        return Positioned(
          left: _controller.currentPosition.dx - widget.characterSize / 2,
          top: _controller.currentPosition.dy - widget.characterSize / 2,
          child: RpgCharacter(
            emoji: widget.characterEmoji,
            size: widget.characterSize,
            direction: _controller.currentDirection,
            isWalking: _controller.isMoving,
          ),
        );
      },
    );
  }
}
