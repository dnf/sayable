package sayableduration;

public record CompactnessOverride(
    UnitForms second,
    UnitForms minute,
    UnitForms hour,
    UnitForms day,
    UnitForms week,
    UnitForms month,
    UnitForms year,
    String half,
    String delimiter,
    String ago,
    String inFuture
) {}
