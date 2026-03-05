package sayabletime;

public record ShortClockConfig(
    boolean use24h,
    String[] amPm,
    String format
) {}
