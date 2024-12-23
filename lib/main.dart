

import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: MacOSDock(
              items: [
                Icons.person,
                Icons.message,
                Icons.call,
                Icons.camera,
                Icons.photo,
                Icons.ice_skating_rounded,
                Icons.import_contacts
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MacOSDock extends StatefulWidget {
  const MacOSDock({
    super.key,
    required this.items,
  });

  /// List of icons to display in the dock.
  final List<IconData> items;

  @override
  State<MacOSDock> createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> with SingleTickerProviderStateMixin {
  late ValueNotifier<List<IconData>> dockItemsNotifier;
  late ValueNotifier<int?> hoveredIndexNotifier;

  @override
  void initState() {
    super.initState();
    dockItemsNotifier = ValueNotifier(List.from(widget.items));
    hoveredIndexNotifier = ValueNotifier<int?>(null);
  }

  @override
  void dispose() {
    dockItemsNotifier.dispose();
    hoveredIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 20),
      child: ValueListenableBuilder<List<IconData>>(
        valueListenable: dockItemsNotifier,
        builder: (context, dockItems, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(dockItems.length, (index) {
              return DragTarget<IconData>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  final updatedDockItems = List<IconData>.from(dockItems);
                  final oldIndex = updatedDockItems.indexOf(details.data);
                  final newIndex = index;
                  updatedDockItems.removeAt(oldIndex);
                  updatedDockItems.insert(newIndex, details.data);
                  dockItemsNotifier.value = updatedDockItems;
                },
                builder: (context, candidateData, rejectedData) {
                  return MouseRegion(
                    onEnter: (_) => hoveredIndexNotifier.value = index,
                    onExit: (_) => hoveredIndexNotifier.value = null,
                    child: ValueListenableBuilder<int?>(
                      valueListenable: hoveredIndexNotifier,
                      builder: (context, hoveredIndex, _) {
                        final isHovered = hoveredIndex == index;
                        return Draggable<IconData>(
                          data: dockItems[index],
                          feedback: Transform.scale(
                            scale: 1.2,
                            child: DockItem(icon: dockItems[index], isDragging: true),
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          child: DockItem(icon: dockItems[index], isHovered: isHovered),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}

/// Individual dock item widget.
class DockItem extends StatelessWidget {
  const DockItem({
    super.key,
    required this.icon,
    this.isHovered = false,
    this.isDragging = false,
  });

  final IconData icon;
  final bool isHovered;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        minWidth: isHovered ? 60 : 50,
        minHeight: isHovered ? 60 : 50,
        maxWidth: isHovered ? 60: 50,
        maxHeight: isHovered ? 60 : 50,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDragging
            ? Colors.grey.shade800
            : isHovered
            ? Colors.grey.shade300
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: isDragging || isHovered ? Colors.black : Colors.grey.shade800,
          size: 32,
        ),
      ),
    );
  }
}

