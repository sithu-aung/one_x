import 'dart:async';

// Event types
enum EventType { unauthorized }

// Event class
class AppEvent {
  final EventType type;
  final dynamic data;

  AppEvent(this.type, {this.data});
}

// Global event bus using singleton pattern
class GlobalEventBus {
  // Singleton instance
  static final GlobalEventBus _instance = GlobalEventBus._internal();
  static GlobalEventBus get instance => _instance;

  // Stream controller
  final StreamController<AppEvent> _eventController =
      StreamController<AppEvent>.broadcast();

  // Constructor
  GlobalEventBus._internal();

  // Stream getter
  Stream<AppEvent> get stream => _eventController.stream;

  // Fire an unauthorized event
  void fireUnauthorized() {
    _eventController.add(AppEvent(EventType.unauthorized));
  }

  // Fire a custom event
  void fireEvent(AppEvent event) {
    _eventController.add(event);
  }

  // Dispose
  void dispose() {
    _eventController.close();
  }
}
