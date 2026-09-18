import 'connection_probe.dart';
import 'connection_probe_stub.dart'
    if (dart.library.html) 'connection_probe_web.dart'
    if (dart.library.io) 'connection_probe_io.dart' as impl;

StartupConnectionProbe createStartupConnectionProbe() =>
    impl.createStartupConnectionProbe();
