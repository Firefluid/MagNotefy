
// Returns a DateTime parsed from the creation date stored in the filename
DateTime pathToDateTime(String path) {
  // Strip the directory
  int startPos = path.lastIndexOf('/');
  String name = path.substring(startPos+1, startPos+20);
  // Parse date from filename
  return DateTime(
    int.parse(name.substring(0, 4)),
    int.parse(name.substring(5, 7)),
    int.parse(name.substring(8, 10)),
    int.parse(name.substring(11, 13)),
    int.parse(name.substring(14, 16)),
    int.parse(name.substring(17, 19)),
  );
}

// Returns a DateTime converted to a more human-readable String
String dateTimeToString(DateTime date) {
  const Map<int, String> months = {
    1:'January', 2:'February', 3:'March', 4:'April', 5:'May', 6:'June',
    7:'July', 8:'August', 9:'September', 10:'October', 11:'November',
    12:'December'
  };
  return '${date.day}. ${months[date.month]} ${date.year}'
    ' ${date.hour}:${date.minute}';
}

// Converts a filesize to a String
String fileSizeToString(int size) {
  // Kilo-, Mega-, Giga-, TerraBytes
  const Map<int, String> map = {
    1: 'K', 2: 'M', 3: 'G', 4: 'T'
  };
  int order = 0;
  while(size > 1024 && order < 5) {
    size = size/1024 as int;
    order++;
  }
  if(order == 0)
    return '${size.toStringAsFixed(0)} bytes';
  return '${size.toStringAsFixed(2)} ${map[order]}B';
}

// Converts a Number to a String with a fixed width (optional 0s on the left)
String numberToWideString(int number, int width) {
  return number.toString().padLeft(width, '0');
}

// Converts a DateTime to a String of the format yyyy-mm-dd_hh-mm-ss
String dateTimeToMyString(DateTime dateTime) {
  String result = '';
  result += numberToWideString(dateTime.year, 4);
  result += '-';
  result += numberToWideString(dateTime.month, 2);
  result += '-';
  result += numberToWideString(dateTime.day, 2);
  result += '_';
  result += numberToWideString(dateTime.hour, 2);
  result += '-';
  result += numberToWideString(dateTime.minute, 2);
  result += '-';
  result += numberToWideString(dateTime.second, 2);
  return result;
}