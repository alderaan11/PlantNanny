import 'package:flutter/material.dart';

/// A widget that displays an API connection error with options to retry or configure server.
///
/// Use this widget when API calls fail due to timeout or connection issues.
class ApiErrorWidget extends StatelessWidget {
  /// The error that occurred
  final Object error;

  /// Callback to retry the failed operation
  final VoidCallback? onRetry;

  /// Optional custom title
  final String? title;

  /// Optional custom message
  final String? message;

  const ApiErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.message,
  });

  /// Check if the error is a connection/timeout error
  static bool isConnectionError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection reset') ||
        errorString.contains('connection closed') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('host not found') ||
        errorString.contains('no route to host') ||
        errorString.contains('socket') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection failed') ||
        errorString.contains('eof') ||
        errorString.contains('http exception');
  }

  String _getDisplayTitle() {
    if (title != null) return title!;
    if (isConnectionError(error)) {
      return 'Impossible de joindre le serveur';
    }
    return 'Une erreur est survenue';
  }

  String _getDisplayMessage() {
    if (message != null) return message!;
    if (isConnectionError(error)) {
      return 'Vérifiez votre connexion internet et assurez-vous que le serveur est correctement configuré.';
    }
    return error.toString();
  }

  IconData _getIcon() {
    if (isConnectionError(error)) {
      return Icons.cloud_off;
    }
    return Icons.error_outline;
  }

  Color _getIconColor(BuildContext context) {
    if (isConnectionError(error)) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnection = isConnectionError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), size: 80, color: _getIconColor(context)),
            const SizedBox(height: 24),
            Text(
              _getDisplayTitle(),
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getDisplayMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                if (isConnection)
                  OutlinedButton.icon(
                    onPressed: () => _navigateToServerConfig(context),
                    icon: const Icon(Icons.settings),
                    label: const Text('Configurer le serveur'),
                  ),
              ],
            ),

            // Show technical error details in expandable section
            if (isConnection) ...[
              const SizedBox(height: 24),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    'Détails techniques',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToServerConfig(BuildContext context) {
    Navigator.of(context).pushNamed('/settings/server');
  }
}

/// A simpler inline error indicator for smaller spaces
class ApiErrorBanner extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final VoidCallback? onConfigure;

  const ApiErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final isConnection = ApiErrorWidget.isConnectionError(error);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnection ? Colors.orange.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnection ? Colors.orange.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isConnection ? Icons.cloud_off : Icons.error_outline,
                color: isConnection ? Colors.orange : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isConnection
                      ? 'Impossible de joindre le serveur'
                      : 'Erreur de chargement',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (isConnection) ...[
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion et la configuration du serveur.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('Réessayer')),
              if (isConnection) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      onConfigure ??
                      () => Navigator.of(context).pushNamed('/settings/server'),
                  child: const Text('Configurer'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
