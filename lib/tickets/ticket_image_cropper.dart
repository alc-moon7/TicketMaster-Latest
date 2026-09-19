import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


const double kTicketCardHeaderImageAspectRatio = 2.0;

class TicketCardImageSelection {
  const TicketCardImageSelection({
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.cropRect,
  });

  final Uint8List imageBytes;
  final double imageWidth;
  final double imageHeight;
  final Rect cropRect;

  double get imageAspectRatio => imageWidth / imageHeight;
}

class TicketCardImageCropPage extends StatefulWidget {
  const TicketCardImageCropPage({
    super.key,
    required this.imageBytes,
    this.targetAspectRatio = kTicketCardHeaderImageAspectRatio,
  });

  final Uint8List imageBytes;
  final double targetAspectRatio;

  @override
  State<TicketCardImageCropPage> createState() =>
      _TicketCardImageCropPageState();
}

class _TicketCardImageCropPageState extends State<TicketCardImageCropPage> {
  Size? _imageSize;
  Rect? _cropRect;
  _CropInteractionMode _interactionMode = _CropInteractionMode.none;
  Offset _dragStartLocal = Offset.zero;
  Rect _cropRectOnDragStart = Rect.zero;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImageSize());
  }

  Future<void> _loadImageSize() async {
    final imageSize = await _decodeImageSize(widget.imageBytes);
    if (!mounted) return;
    setState(() {
      _imageSize = imageSize;
      _cropRect = _initialCropRect(imageSize);
    });
  }

  Future<Size> _decodeImageSize(Uint8List bytes) {
    final completer = Completer<Size>();
    ui.decodeImageFromList(bytes, (image) {
      completer.complete(Size(image.width.toDouble(), image.height.toDouble()));
    });
    return completer.future;
  }

  Rect _initialCropRect(Size imageSize) {
    final normalizedAspect = _cropAspectInImageSpace(imageSize);

    if (normalizedAspect <= 1) {
      final width = normalizedAspect;
      return Rect.fromLTWH((1 - width) / 2, 0, width, 1);
    }

    final height = 1 / normalizedAspect;
    return Rect.fromLTWH(0, (1 - height) / 2, 1, height);
  }

  double _cropAspectInImageSpace(Size imageSize) {
    return widget.targetAspectRatio / (imageSize.width / imageSize.height);
  }

  void _handlePanStart(Offset localPosition, Rect imageRect) {
    final cropRect = _cropRect;
    if (cropRect == null) return;

    final interactionMode = _resolveInteractionMode(localPosition, imageRect);
    if (interactionMode == _CropInteractionMode.none) {
      return;
    }

    setState(() {
      _interactionMode = interactionMode;
      _dragStartLocal = localPosition;
      _cropRectOnDragStart = cropRect;
    });
  }

  void _handlePanUpdate(Offset localPosition, Rect imageRect) {
    final imageSize = _imageSize;
    if (imageSize == null || _interactionMode == _CropInteractionMode.none) {
      return;
    }

    final normalizedAspect = _cropAspectInImageSpace(imageSize);
    final minHeight = _minimumCropHeight(imageRect, normalizedAspect);

    Rect nextCropRect;
    if (_interactionMode == _CropInteractionMode.move) {
      final delta = localPosition - _dragStartLocal;
      nextCropRect = _moveCropRect(_cropRectOnDragStart, delta, imageRect);
    } else {
      final normalizedPoint = _normalizedPoint(localPosition, imageRect);
      nextCropRect = _resizeCropRect(
        startRect: _cropRectOnDragStart,
        dragMode: _interactionMode,
        point: normalizedPoint,
        aspect: normalizedAspect,
        minHeight: minHeight,
      );
    }

    setState(() {
      _cropRect = nextCropRect;
    });
  }

  void _handlePanEnd() {
    if (_interactionMode == _CropInteractionMode.none) {
      return;
    }

    setState(() {
      _interactionMode = _CropInteractionMode.none;
    });
  }

  _CropInteractionMode _resolveInteractionMode(
    Offset localPosition,
    Rect imageRect,
  ) {
    if (!imageRect.inflate(24).contains(localPosition)) {
      return _CropInteractionMode.none;
    }

    final cropRect = _displayCropRect(_cropRect!, imageRect);
    const handleTouchRadius = 28.0;
    final handles = <_CropInteractionMode, Offset>{
      _CropInteractionMode.topLeft: cropRect.topLeft,
      _CropInteractionMode.topRight: cropRect.topRight,
      _CropInteractionMode.bottomLeft: cropRect.bottomLeft,
      _CropInteractionMode.bottomRight: cropRect.bottomRight,
    };

    for (final entry in handles.entries) {
      if ((entry.value - localPosition).distance <= handleTouchRadius) {
        return entry.key;
      }
    }

    if (cropRect.contains(localPosition)) {
      return _CropInteractionMode.move;
    }

    return _CropInteractionMode.none;
  }

  Rect _moveCropRect(Rect startRect, Offset delta, Rect imageRect) {
    final dx = delta.dx / imageRect.width;
    final dy = delta.dy / imageRect.height;
    return Rect.fromLTWH(
      (startRect.left + dx).clamp(0.0, 1.0 - startRect.width).toDouble(),
      (startRect.top + dy).clamp(0.0, 1.0 - startRect.height).toDouble(),
      startRect.width,
      startRect.height,
    );
  }

  Rect _resizeCropRect({
    required Rect startRect,
    required _CropInteractionMode dragMode,
    required Offset point,
    required double aspect,
    required double minHeight,
  }) {
    late final Offset anchor;
    late final double maxWidth;
    late final double maxHeight;
    late final double desiredDx;
    late final double desiredDy;

    switch (dragMode) {
      case _CropInteractionMode.topLeft:
        anchor = startRect.bottomRight;
        maxWidth = anchor.dx;
        maxHeight = anchor.dy;
        desiredDx = anchor.dx - point.dx;
        desiredDy = anchor.dy - point.dy;
        break;
      case _CropInteractionMode.topRight:
        anchor = startRect.bottomLeft;
        maxWidth = 1 - anchor.dx;
        maxHeight = anchor.dy;
        desiredDx = point.dx - anchor.dx;
        desiredDy = anchor.dy - point.dy;
        break;
      case _CropInteractionMode.bottomLeft:
        anchor = startRect.topRight;
        maxWidth = anchor.dx;
        maxHeight = 1 - anchor.dy;
        desiredDx = anchor.dx - point.dx;
        desiredDy = point.dy - anchor.dy;
        break;
      case _CropInteractionMode.bottomRight:
        anchor = startRect.topLeft;
        maxWidth = 1 - anchor.dx;
        maxHeight = 1 - anchor.dy;
        desiredDx = point.dx - anchor.dx;
        desiredDy = point.dy - anchor.dy;
        break;
      case _CropInteractionMode.move:
      case _CropInteractionMode.none:
        return startRect;
    }

    final maxAllowedHeight = math.min(maxHeight, maxWidth / aspect);
    final effectiveMinHeight = math.min(minHeight, maxAllowedHeight);
    final desiredHeight = math.min(desiredDy, desiredDx / aspect);
    final height = desiredHeight
        .clamp(effectiveMinHeight, maxAllowedHeight)
        .toDouble();
    final width = height * aspect;

    switch (dragMode) {
      case _CropInteractionMode.topLeft:
        return Rect.fromLTWH(
          anchor.dx - width,
          anchor.dy - height,
          width,
          height,
        );
      case _CropInteractionMode.topRight:
        return Rect.fromLTWH(anchor.dx, anchor.dy - height, width, height);
      case _CropInteractionMode.bottomLeft:
        return Rect.fromLTWH(anchor.dx - width, anchor.dy, width, height);
      case _CropInteractionMode.bottomRight:
        return Rect.fromLTWH(anchor.dx, anchor.dy, width, height);
      case _CropInteractionMode.move:
      case _CropInteractionMode.none:
        return startRect;
    }
  }

  double _minimumCropHeight(Rect imageRect, double aspect) {
    const minHandleSpan = 96.0;
    final minByHeight = minHandleSpan / imageRect.height;
    final minByWidth = (minHandleSpan / imageRect.width) / aspect;
    return math.max(minByHeight, minByWidth).clamp(0.1, 0.72).toDouble();
  }

  Offset _normalizedPoint(Offset localPosition, Rect imageRect) {
    return Offset(
      ((localPosition.dx - imageRect.left) / imageRect.width)
          .clamp(0.0, 1.0)
          .toDouble(),
      ((localPosition.dy - imageRect.top) / imageRect.height)
          .clamp(0.0, 1.0)
          .toDouble(),
    );
  }

  Rect _displayCropRect(Rect cropRect, Rect imageRect) {
    return Rect.fromLTWH(
      imageRect.left + (cropRect.left * imageRect.width),
      imageRect.top + (cropRect.top * imageRect.height),
      cropRect.width * imageRect.width,
      cropRect.height * imageRect.height,
    );
  }

  void _resetCrop() {
    final imageSize = _imageSize;
    if (imageSize == null) return;

    setState(() {
      _cropRect = _initialCropRect(imageSize);
      _interactionMode = _CropInteractionMode.none;
    });
  }

  void _confirmCrop() {
    final imageSize = _imageSize;
    final cropRect = _cropRect;
    if (imageSize == null || cropRect == null) {
      return;
    }

    Navigator.of(context).pop(
      TicketCardImageSelection(
        imageBytes: widget.imageBytes,
        imageWidth: imageSize.width,
        imageHeight: imageSize.height,
        cropRect: cropRect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = _imageSize;

    return Scaffold(
      backgroundColor: const Color(0xFF0F131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F131A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Adjust Card Image',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: imageSize == null ? null : _confirmCrop,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: imageSize == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    Text(
                      'Move the crop box or drag any corner handle to choose which part of the top ticket image will be shown.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final previewSize = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            final imageRect = _containImageRect(
                              previewSize,
                              imageSize,
                            );
                            final selection = TicketCardImageSelection(
                              imageBytes: widget.imageBytes,
                              imageWidth: imageSize.width,
                              imageHeight: imageSize.height,
                              cropRect: _cropRect!,
                            );

                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B23),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onPanStart: (details) {
                                  _handlePanStart(
                                    details.localPosition,
                                    imageRect,
                                  );
                                },
                                onPanUpdate: (details) {
                                  _handlePanUpdate(
                                    details.localPosition,
                                    imageRect,
                                  );
                                },
                                onPanEnd: (_) => _handlePanEnd(),
                                onPanCancel: _handlePanEnd,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned.fromRect(
                                      rect: imageRect,
                                      child: Image.memory(
                                        widget.imageBytes,
                                        fit: BoxFit.fill,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: CustomPaint(
                                        painter: _CropOverlayPainter(
                                          imageRect: imageRect,
                                          cropRect: _displayCropRect(
                                            _cropRect!,
                                            imageRect,
                                          ),
                                          isMoveActive:
                                              _interactionMode ==
                                              _CropInteractionMode.move,
                                          activeHandle:
                                              switch (_interactionMode) {
                                                _CropInteractionMode.topLeft =>
                                                  _CropInteractionMode.topLeft,
                                                _CropInteractionMode.topRight =>
                                                  _CropInteractionMode.topRight,
                                                _CropInteractionMode
                                                    .bottomLeft =>
                                                  _CropInteractionMode
                                                      .bottomLeft,
                                                _CropInteractionMode
                                                    .bottomRight =>
                                                  _CropInteractionMode
                                                      .bottomRight,
                                                _ => null,
                                              },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 16,
                                      top: 16,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.48,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Ticket ratio locked',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      right: 16,
                                      bottom: 16,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                          width: math.min(
                                            constraints.maxWidth - 32,
                                            190,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio:
                                                widget.targetAspectRatio,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.34),
                                                ),
                                                child: TicketCardImageViewport(
                                                  selection: selection,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetCrop,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _confirmCrop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF026CDF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Use This Crop'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class TicketCardImageViewport extends StatelessWidget {
  const TicketCardImageViewport({super.key, required this.selection});

  final TicketCardImageSelection selection;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final cropRect = Rect.fromLTWH(
          selection.cropRect.left * selection.imageWidth,
          selection.cropRect.top * selection.imageHeight,
          selection.cropRect.width * selection.imageWidth,
          selection.cropRect.height * selection.imageHeight,
        );
        final scale = math.max(
          viewportSize.width / cropRect.width,
          viewportSize.height / cropRect.height,
        );
        final renderedWidth = selection.imageWidth * scale;
        final renderedHeight = selection.imageHeight * scale;
        final cropWidth = cropRect.width * scale;
        final cropHeight = cropRect.height * scale;

        return ClipRect(
          child: Stack(
            children: [
              Positioned(
                left:
                    (-cropRect.left * scale) +
                    ((viewportSize.width - cropWidth) / 2),
                top:
                    (-cropRect.top * scale) +
                    ((viewportSize.height - cropHeight) / 2),
                child: SizedBox(
                  width: renderedWidth,
                  height: renderedHeight,
                  child: Image.memory(
                    selection.imageBytes,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Rect _containImageRect(Size viewportSize, Size imageSize) {
  final viewportAspectRatio = viewportSize.width / viewportSize.height;
  final imageAspectRatio = imageSize.width / imageSize.height;
  late final Size renderedSize;

  if (imageAspectRatio > viewportAspectRatio) {
    final width = viewportSize.width;
    renderedSize = Size(width, width / imageAspectRatio);
  } else {
    final height = viewportSize.height;
    renderedSize = Size(height * imageAspectRatio, height);
  }

  return Rect.fromLTWH(
    (viewportSize.width - renderedSize.width) / 2,
    (viewportSize.height - renderedSize.height) / 2,
    renderedSize.width,
    renderedSize.height,
  );
}

enum _CropInteractionMode {
  none,
  move,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _CropOverlayPainter extends CustomPainter {
  const _CropOverlayPainter({
    required this.imageRect,
    required this.cropRect,
    required this.isMoveActive,
    required this.activeHandle,
  });

  final Rect imageRect;
  final Rect cropRect;
  final bool isMoveActive;
  final _CropInteractionMode? activeHandle;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.58);
    final overlayPath = Path()..addRect(Offset.zero & size);
    final cropHolePath = Path()
      ..addRRect(RRect.fromRectAndRadius(cropRect, const Radius.circular(16)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, overlayPath, cropHolePath),
      overlayPaint,
    );

    final imageBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(imageRect, const Radius.circular(18)),
      imageBorderPaint,
    );

    final cropBorderPaint = Paint()
      ..color = isMoveActive ? const Color(0xFF3DA1FF) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cropRect, const Radius.circular(16)),
      cropBorderPaint,
    );

    for (var i = 1; i < 3; i++) {
      final dx = cropRect.left + (cropRect.width / 3) * i;
      final dy = cropRect.top + (cropRect.height / 3) * i;
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(dx, cropRect.top),
        Offset(dx, cropRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(cropRect.left, dy),
        Offset(cropRect.right, dy),
        gridPaint,
      );
    }

    _paintHandle(canvas, cropRect.topLeft, _CropInteractionMode.topLeft);
    _paintHandle(canvas, cropRect.topRight, _CropInteractionMode.topRight);
    _paintHandle(canvas, cropRect.bottomLeft, _CropInteractionMode.bottomLeft);
    _paintHandle(
      canvas,
      cropRect.bottomRight,
      _CropInteractionMode.bottomRight,
    );
  }

  void _paintHandle(
    Canvas canvas,
    Offset corner,
    _CropInteractionMode handleMode,
  ) {
    const handleLength = 18.0;
    const handleStroke = 4.0;
    final handleColor = activeHandle == handleMode
        ? const Color(0xFF3DA1FF)
        : Colors.white;
    final handlePaint = Paint()
      ..color = handleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = handleStroke
      ..strokeCap = StrokeCap.round;

    switch (handleMode) {
      case _CropInteractionMode.topLeft:
        canvas.drawLine(
          corner,
          corner + const Offset(handleLength, 0),
          handlePaint,
        );
        canvas.drawLine(
          corner,
          corner + const Offset(0, handleLength),
          handlePaint,
        );
        break;
      case _CropInteractionMode.topRight:
        canvas.drawLine(
          corner,
          corner + const Offset(-handleLength, 0),
          handlePaint,
        );
        canvas.drawLine(
          corner,
          corner + const Offset(0, handleLength),
          handlePaint,
        );
        break;
      case _CropInteractionMode.bottomLeft:
        canvas.drawLine(
          corner,
          corner + const Offset(handleLength, 0),
          handlePaint,
        );
        canvas.drawLine(
          corner,
          corner + const Offset(0, -handleLength),
          handlePaint,
        );
        break;
      case _CropInteractionMode.bottomRight:
        canvas.drawLine(
          corner,
          corner + const Offset(-handleLength, 0),
          handlePaint,
        );
        canvas.drawLine(
          corner,
          corner + const Offset(0, -handleLength),
          handlePaint,
        );
        break;
      case _CropInteractionMode.none:
      case _CropInteractionMode.move:
        return;
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.imageRect != imageRect ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.isMoveActive != isMoveActive ||
        oldDelegate.activeHandle != activeHandle;
  }
}
