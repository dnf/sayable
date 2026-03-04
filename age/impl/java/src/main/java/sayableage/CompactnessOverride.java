package sayableage;

public record CompactnessOverride(
    UnitForms day,
    UnitForms week,
    UnitForms month,
    UnitForms year,
    String half,
    String delimiter,
    String justBorn
) {}
