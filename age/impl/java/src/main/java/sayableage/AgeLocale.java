package sayableage;

import java.util.function.BiFunction;
import java.util.function.IntFunction;

public final class AgeLocale {

    private final String code;
    private final IntFunction<PluralCategory> plural;
    private final Units units;
    private final String half;
    private final String delimiter;
    private final String justBorn;
    private final Stages stages;
    private final CompactnessOverride shortOverride;
    private final CompactnessOverride compactOverride;
    private final IntFunction<String> formatNumber;
    private final BiFunction<Integer, String, String> formatUnit;

    @SuppressWarnings("ParameterNumber")
    public AgeLocale(
        String code,
        IntFunction<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justBorn,
        Stages stages,
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
        this.justBorn = justBorn;
        this.stages = stages;
        this.shortOverride = shortOverride;
        this.compactOverride = compactOverride;
        this.formatNumber = formatNumber;
        this.formatUnit = formatUnit;
    }

    public AgeLocale(
        String code,
        IntFunction<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justBorn,
        Stages stages
    ) {
        this(code, plural, units, half, delimiter, justBorn, stages, null, null, null, null);
    }

    public String code() { return code; }
    public IntFunction<PluralCategory> plural() { return plural; }
    public Units units() { return units; }
    public String half() { return half; }
    public String delimiter() { return delimiter; }
    public String justBorn() { return justBorn; }
    public Stages stages() { return stages; }
    public CompactnessOverride shortOverride() { return shortOverride; }
    public CompactnessOverride compactOverride() { return compactOverride; }
    public IntFunction<String> formatNumber() { return formatNumber; }
    public BiFunction<Integer, String, String> formatUnit() { return formatUnit; }
}
