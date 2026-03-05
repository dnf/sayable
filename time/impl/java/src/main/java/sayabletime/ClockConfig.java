package sayabletime;

import java.util.List;
import java.util.Map;

public record ClockConfig(
    List<String> hours,
    String midnight,
    String noon,
    Map<Integer, String> patterns
) {}
