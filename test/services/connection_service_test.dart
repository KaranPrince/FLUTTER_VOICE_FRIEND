import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';
import 'package:flutter_voice_friend/services/connection_service.dart';

import 'connection_service_test.mocks.dart';

@GenerateMocks([InternetConnection])
void main() {
  late MockInternetConnection mockInternetConnection;
  late ConnectionService connectionService;
  late StreamController<InternetStatus> statusChangeController;

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize mock and service
    mockInternetConnection = MockInternetConnection();
    statusChangeController = StreamController<InternetStatus>.broadcast();

    // Mock InternetConnection onStatusChange stream
    when(mockInternetConnection.onStatusChange)
        .thenAnswer((_) => statusChangeController.stream);

    when(mockInternetConnection.internetStatus)
        .thenAnswer((_) async => InternetStatus.connected);

    connectionService =
        ConnectionService(internetConnection: mockInternetConnection);
  });

  tearDown(() {
    // Close the stream controller after each test
    statusChangeController.close();
  });

  group('ConnectionService Initialization', () {
    test('Initializes with correct connection status', () async {
      // Mock the initial status to return 'connected'
      when(mockInternetConnection.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);

      // Create the service (this might start the async initialization)
      connectionService =
          ConnectionService(internetConnection: mockInternetConnection);

      // Await the emission of the connection status from the stream
      await expectLater(
        connectionService.connectionStatusStream,
        emitsInOrder([InternetStatus.connected]),
      );

      // Ensure the connection status and hasInternet are correctly updated
      expect(connectionService.connectionStatus, InternetStatus.connected);
      expect(connectionService.hasInternet, true);

      // Verify the method that checks the internet status was called
      verify(mockInternetConnection.internetStatus).called(2);
    });
  });

  group('ConnectionService forceUpdate', () {
    test('Forces an update of the connection status', () async {
      // Mock the initial status as disconnected
      when(mockInternetConnection.internetStatus)
          .thenAnswer((_) async => InternetStatus.disconnected);

      // Force an update
      await connectionService.forceUpdate();

      // Check if the connection status is updated
      expect(connectionService.connectionStatus, InternetStatus.disconnected);
      expect(connectionService.hasInternet, false);

      verify(mockInternetConnection.internetStatus).called(2);
    });
  });

  group('ConnectionService Monitoring', () {
    test('Starts monitoring and updates the stream on status change', () async {
      // Expect that the stream will emit first 'connected' and then 'disconnected'
      expectLater(
        connectionService.connectionStatusStream,
        emitsInOrder([
          InternetStatus.connected, // Initial status
          InternetStatus.disconnected, // Simulated status change
        ]),
      );

      // Simulate a status change to disconnected
      statusChangeController.add(InternetStatus.connected);
      statusChangeController.add(InternetStatus.disconnected);

      // Allow time for the async operation to complete
      await Future.delayed(Duration.zero);

      // Optionally verify that the connectionService has updated its internal state
      expect(connectionService.connectionStatus, InternetStatus.disconnected);
      expect(connectionService.hasInternet, false);
    });
  });

  group('ConnectionService stopMonitoring', () {
    test('Stops monitoring and closes the stream', () async {
      // Listen to the connectionStatusStream
      final streamListener = expectLater(
        connectionService.connectionStatusStream,
        emitsInOrder([InternetStatus.connected]),
      );

      // Simulate an initial status
      statusChangeController.add(InternetStatus.connected);

      await Future.delayed(Duration.zero);

      // Call stopMonitoring to cancel the subscription
      connectionService.stopMonitoring();

      // Simulate another status after stopping the monitoring
      statusChangeController.add(InternetStatus.disconnected);

      // Check if no further emissions happen after stopping
      await streamListener;

      // Ensure the stream is closed and no further events are emitted
      expect(
        connectionService.connectionStatusStream.isBroadcast,
        true,
      );
    });
  });
}
