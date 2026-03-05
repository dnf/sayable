package sayabledate;

import java.util.List;
import java.util.Map;

public record CompactnessOverride(
    List<String> months,
    List<String> monthsInDate,
    List<String> weekdays,
    String dayFormat,
    Map<String, String> dayFormatExceptions,
    String datePattern,
    String datePatternWithYear,
    String today,
    String tomorrow,
    String yesterday
) {}
