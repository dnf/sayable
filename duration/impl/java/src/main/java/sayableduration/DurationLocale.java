package sayableduration;

import java.util.function.BiFunction;
import java.util.function.IntFunction;

public final class DurationLocale {

    private final String code;
    private final IntFunction<PluralCategory> plural;
    private final Units units;
    private final String half;
    private final String delimiter;
    private final String justNow;
    private final String ago;
    private final String inFuture;
    private final CompactnessOverride shortOverride;
    private final CompactnessOverride compactOverride;
    private final IntFunction<String> formatNumber;
    private final BiFunction<Integer, String, String> formatUnit;

    @SuppressWarnings("ParameterNumber")
    public DurationLocale(
        String code,
        IntFunction<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justNow,
        String ago,
        String inFuture,
        CompactnessOverride shortOverride,
        CompactnessOverride compactOverride,
        IntFunction<String> formatNumber,
        BiFunction<Integer, String, String> formatUnit
    ) {
        this.code = code;
        this.plural = plural;
        this.units = units;
        this.half = half;
        this.delimiter = delimiter;
        this.justNow = justNow;
        this.ago = ago;
        this.inFuture = inFuture;
        this.shortOverride = shortOverride;
        this.compactOverride = compactOverride;
        this.formatNumber = formatNumber;
        this.formatUnit = formatUnit;
    }

    public DurationLocale(
        String code,
        IntFunction<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justNow,
        String ago,
        String inFuture
    ) {
        this(code, plural, units, half, delimiter, justNow, ago, inFuture, null, null, null, null);
    }

    public String code() { return code; }
    public IntFunction<PluralCategory> plural() { return plural; }
    public Units units() { return units; }
    public String half() { return half; }
    public String delimiter() { return delimiter; }
    public String justNow() { return justNow; }
    public String ago() { return ago; }
    public String inFuture() { return inFuture; }
    public CompactnessOverride shortOverride() { return shortOverride; }
    public CompactnessOverride compactOverride() { return compactOverride; }
    public IntFunction<String> formatNumber() { return formatNumber; }
    public BiFunction<Integer, String, String> formatUnit() { return formatUnit; }
}
