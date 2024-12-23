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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A customizable MacOS-like dock with draggable and reorderable buttons.
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
  late ValueNotifier<List<IconData>> _dockItemsNotifier;

  @override
  void initState() {
    super.initState();
    _dockItemsNotifier = ValueNotifier(List.from(widget.items));
  }

  @override
  void dispose() {
    _dockItemsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 20),
      child: ValueListenableBuilder<List<IconData>>(
        valueListenable: _dockItemsNotifier,
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
                  _dockItemsNotifier.value = updatedDockItems;
                },
                builder: (context, candidateData, rejectedData) {
                  return Draggable<IconData>(
                    data: dockItems[index],
                    feedback: Transform.scale(
                      scale: 1.2,
                      child: DockItem(icon: dockItems[index], isDragging: true),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    child: DockItem(icon: dockItems[index]),
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
    this.isDragging = false,
  });

  final IconData icon;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDragging ? Colors.grey.shade800 : Colors.white,
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
          color: isDragging ? Colors.white : Colors.black,
          size: 32,
        ),
      ),
    );
  }
}
