package sayabletime;

public final class TimeLocale {

    private final String code;
    private final ClockConfig clock;
    private final CompactnessOverride shortOverride;
    private final CompactnessOverride compactOverride;

    public TimeLocale(
        String code,
        ClockConfig clock,
        CompactnessOverride shortOverride,
        CompactnessOverride compactOverride
    ) {
        this.code = code;
        this.clock = clock;
        this.shortOverride = shortOverride;
        this.compactOverride = compactOverride;
    }

    public TimeLocale(String code, ClockConfig clock) {
        this(code, clock, null, null);
    }

    public String code() { return code; }
    public ClockConfig clock() { return clock; }
    public CompactnessOverride shortOverride() { return shortOverride; }
    public CompactnessOverride compactOverride() { return compactOverride; }
}
