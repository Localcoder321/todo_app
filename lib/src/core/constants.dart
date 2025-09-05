const int kMinYear = 1950;
const int kMaxYear = 2950;

const List<String> monthNames = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

const List<String> weekDaysShort = [
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat",
  "Sun",
];

String formatYmd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
DateTime parseYmd(String s) {
  final p = s.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

int monthsTotal() => (kMaxYear - kMinYear + 1) * 12;
DateTime monthFromIndex(int idx) {
  final y = kMinYear + (idx ~/ 12);
  final m = (idx % 12) + 1;
  return DateTime(y, m, 1);
}

int indexFromMonth(DateTime dt) => (dt.year - kMinYear) * 12 + (dt.month - 1);

enum Priority { low, normal, high }
