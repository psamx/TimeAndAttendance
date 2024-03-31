class AttendanceStatus {
  String? employeeName;
  final String status;
  final String address;
  final double weeklyHoursWorked;
  final double todayHoursWorked;
  final double breakHours;
  String? longitude;
  String? latitude;

  AttendanceStatus({
      this.employeeName,
      required this.status,
      required this.address,
      required this.weeklyHoursWorked,
      required this.todayHoursWorked,
      required this.breakHours,
      this.longitude,
      this.latitude});
}
