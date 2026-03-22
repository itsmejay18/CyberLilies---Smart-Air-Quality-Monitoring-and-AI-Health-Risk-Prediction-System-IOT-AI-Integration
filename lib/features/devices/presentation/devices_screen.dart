import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../presentation/widgets/empty_state_card.dart';
import '../../../presentation/widgets/iot_device_card.dart';
import '../application/device_providers.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(iotDevicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect an ESP32 node',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register an ESP32 directly in the app. This pairing setup is stored locally on the device, so you can prepare the hardware flow even without Supabase.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showRegisterSheet(context, ref),
                    icon: const Icon(Icons.add_link),
                    label: const Text('Register ESP32'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _ConnectionSteps(),
          const SizedBox(height: 16),
          AsyncValueWidget(
            value: devices,
            loadingMessage: 'Loading devices...',
            data: (items) {
              if (items.isEmpty) {
                return const EmptyStateCard(
                  icon: Icons.memory_outlined,
                  title: 'No devices registered',
                  message:
                      'Once you register an ESP32 and it starts sending telemetry, it will appear here.',
                );
              }

              return Column(
                children: [
                  for (final device in items) ...[
                    IoTDeviceCard(device: device),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          const EmptyStateCard(
            icon: Icons.info_outline,
            title: 'App-managed setup',
            message:
                'Devices registered here are kept in local app storage. You can later connect telemetry delivery however you want.',
          ),
        ],
      ),
    );
  }

  Future<void> _showRegisterSheet(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final deviceIdController = TextEditingController();
    final deviceNameController = TextEditingController();
    final zoneIdController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register ESP32',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: deviceIdController,
                      decoration: const InputDecoration(
                        labelText: 'Device ID',
                        hintText: 'node-1',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Device id is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: deviceNameController,
                      decoration: const InputDecoration(
                        labelText: 'Device name',
                        hintText: 'ESP32 North Field',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Device name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: zoneIdController,
                      decoration: const InputDecoration(
                        labelText: 'Zone ID',
                        hintText: 'north-field',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Zone id is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        try {
                          final repository = await ref.read(
                            localDeviceRepositoryProvider.future,
                          );
                          await repository.registerDevice(
                            deviceId: deviceIdController.text.trim(),
                            zoneId: zoneIdController.text.trim(),
                            deviceName: deviceNameController.text.trim(),
                          );
                          ref.invalidate(iotDevicesProvider);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ESP32 registered. Start sending telemetry to complete the connection.',
                              ),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not register device: $error'),
                            ),
                          );
                        }
                      },
                      child: const Text('Save Device'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    deviceIdController.dispose();
    deviceNameController.dispose();
    zoneIdController.dispose();
  }
}

class _ConnectionSteps extends StatelessWidget {
  const _ConnectionSteps();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How pairing works',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text('1. Open the app and register your ESP32 node here.'),
            const SizedBox(height: 6),
            const Text('2. Enter the same device id and zone id you plan to use on the hardware.'),
            const SizedBox(height: 6),
            const Text('3. Flash the ESP32 with the same device id and your chosen transport setup.'),
            const SizedBox(height: 6),
            const Text('4. The app keeps the pairing record locally, even without Supabase.'),
          ],
        ),
      ),
    );
  }
}
