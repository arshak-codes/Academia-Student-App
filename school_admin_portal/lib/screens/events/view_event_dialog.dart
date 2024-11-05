import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';

class ViewEventDialog extends StatelessWidget {
  final Event event;

  const ViewEventDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(context),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(event.description),
                    if (event.attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Attachments',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildAttachmentsList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              'Type',
              event.type.toString().split('.').last,
              Icons.category,
            ),
            _buildInfoRow(
              'Date',
              '${DateFormat('MMM d, y').format(event.startDate)} - ${DateFormat('MMM d, y').format(event.endDate)}',
              Icons.calendar_today,
            ),
            _buildInfoRow(
              'Venue',
              event.venue,
              Icons.location_on,
            ),
            _buildInfoRow(
              'Target Classes',
              event.targetClasses.join(', '),
              Icons.group,
            ),
            _buildInfoRow(
              'Organizer',
              event.organizerName,
              Icons.person,
            ),
            _buildInfoRow(
              'Status',
              event.isPublished ? 'Published' : 'Draft',
              Icons.public,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: event.attachments.length,
      itemBuilder: (context, index) {
        final url = event.attachments[index];
        final fileName = url.split('/').last;

        return ListTile(
          leading: const Icon(Icons.attach_file),
          title: Text(fileName),
          trailing: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadAttachment(url),
          ),
        );
      },
    );
  }

  Future<void> _downloadAttachment(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
