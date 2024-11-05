class AssignmentData {
  final String subjectName;
  final String topicName;
  final String assignDate;
  final String lastDate;
  final String status;

  AssignmentData(this.subjectName, this.topicName, this.assignDate,
      this.lastDate, this.status);

  bool get isPending => status == 'Pending';
}

// Empty list - no hardcoded assignments
List<AssignmentData> assignment = [];
