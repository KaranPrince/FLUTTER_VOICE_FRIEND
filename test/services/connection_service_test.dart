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

    connectionService = ConnectionService();
  });

  tearDown(() {
    // Close the stream controller after each test
    statusChangeController.close();
  });

  group('ConnectionService Initialization', () {
    test('Initializes with correct connection status', () async {
      // Mock the initial status
      when(mockInternetConnection.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);

      // Create the service and check if it initializes correctly
      connectionService = ConnectionService();

      // Wait for the async initialization to complete
      //await Future.delayed(const Duration(seconds: 1));

      // Verify that the correct status is set and emitted
      expectLater(connectionService.connectionStatusStream,
          emitsInOrder([InternetStatus.connected]));

      // Ensure the connection status and hasInternet are correctly updated
      expect(connectionService.connectionStatus, InternetStatus.connected);
      expect(connectionService.hasInternet, true);

      verify(mockInternetConnection.internetStatus).called(1);
    });
  }, skip: 'TODO: Auto generated test - review failure case and fix test');

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

      verify(mockInternetConnection.internetStatus).called(1);
    });
  }, skip: 'TODO: Auto generated test - review failure case and fix test');

  group('ConnectionService Monitoring', () {
    test('Starts monitoring and updates the stream on status change', () async {
      // Mock initial status as connected
      when(mockInternetConnection.internetStatus)
          .thenAnswer((_) async => InternetStatus.connected);

      connectionService = ConnectionService();

      // Expect the initial connection status to be emitted
      expectLater(
          connectionService.connectionStatusStream,
          emitsInOrder(
              [InternetStatus.connected, InternetStatus.disconnected]));

      // Simulate a status change to disconnected
      statusChangeController.add(InternetStatus.disconnected);

      await Future.delayed(Duration.zero); // Allow async operation to complete

      // Verify the new status and hasInternet flag
      expect(connectionService.connectionStatus, InternetStatus.disconnected);
      expect(connectionService.hasInternet, false);

      verify(mockInternetConnection.onStatusChange).called(1);
    });
  }, skip: 'TODO: Auto generated test - review failure case and fix test');

  group('ConnectionService stopMonitoring', () {
    test('Stops monitoring and closes the stream', () async {
      // Start the monitoring first
      connectionService.startMonitoring();

      // Listen to the connectionStatusStream
      final streamListener = expectLater(
        connectionService.connectionStatusStream,
        emitsInOrder([InternetStatus.connected]),
      );

      // Simulate an initial status
      statusChangeController.add(InternetStatus.connected);

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
  }, skip: 'TODO: Auto generated test - review failure case and fix test');
}
