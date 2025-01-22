// lib/channels/realtime_channel.dart

export 'realtime_channel_stub.dart'
    if (dart.library.html) 'realtime_channel_web.dart'
    if (dart.library.io) 'realtime_channel_io.dart';