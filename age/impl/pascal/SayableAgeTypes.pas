{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableAgeTypes;

interface

type
  TPluralCategory = (pcZero, pcOne, pcTwo, pcFew, pcMany, pcOther);

  TPluralFunc = function(n: Integer): TPluralCategory;

  TUnitForms = record
    Simple: string;
    HasSimple: Boolean;
    Forms: array[0..5] of string; { zero, one, two, few, many, other }
  end;

  TUnitSet = record
    Day: TUnitForms;
    Week: TUnitForms;
    Month: TUnitForms;
    Year: TUnitForms;
  end;

  TStageLabel = record
    LabelText: string;
    M: string;
    F: string;
  end;

  TStageSet = record
    Newborn: TStageLabel;
    Infant: TStageLabel;
    Toddler: TStageLabel;
    Child: TStageLabel;
    Teenager: TStageLabel;
    Adult: TStageLabel;
  end;

  TCompactnessOverride = record
    HasDay: Boolean;
    Day: TUnitForms;
    HasWeek: Boolean;
    Week: TUnitForms;
    HasMonth: Boolean;
    Month: TUnitForms;
    HasYear: Boolean;
    Year: TUnitForms;
    HasHalf: Boolean;
    Half: string;
    HasDelimiter: Boolean;
    Delimiter: string;
    HasJustBorn: Boolean;
    JustBorn: string;
  end;

  TCompactness = (csNormal, csShort, csCompact);

  TAgeLocale = record
    Code: string;
    Plural: TPluralFunc;
    Units: TUnitSet;
    Half: string;
    Delimiter: string;
    JustBorn: string;
    Stages: TStageSet;
    HasShort: Boolean;
    ShortOverride: TCompactnessOverride;
    HasCompact: Boolean;
    CompactOverride: TCompactnessOverride;
  end;

  TAgeLocalePtr = ^TAgeLocale;

implementation

end.
