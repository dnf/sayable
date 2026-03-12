{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableDurationTypes;

interface

type
  TPluralCategory = (pcZero, pcOne, pcTwo, pcFew, pcMany, pcOther);

  TPluralFunc = function(n: Integer): TPluralCategory;

  TCompactness = (csNormal, csShort, csCompact);

  TUnitForms = record
    Simple: string;
    HasSimple: Boolean;
    Forms: array[0..5] of string; { zero, one, two, few, many, other }
  end;

  TDurationUnitSet = record
    Second: TUnitForms;
    Minute: TUnitForms;
    Hour: TUnitForms;
    Day: TUnitForms;
    Week: TUnitForms;
    Month: TUnitForms;
    Year: TUnitForms;
  end;

  TDurationCompactnessOverride = record
    HasSecond: Boolean;
    Second: TUnitForms;
    HasMinute: Boolean;
    Minute: TUnitForms;
    HasHour: Boolean;
    Hour: TUnitForms;
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
    HasAgo: Boolean;
    Ago: string;
    HasInFuture: Boolean;
    InFuture: string;
  end;

  TDurationLocale = record
    Code: string;
    Plural: TPluralFunc;
    Units: TDurationUnitSet;
    Half: string;
    Delimiter: string;
    JustNow: string;
    Ago: string;
    InFuture: string;
    HasShort: Boolean;
    ShortOverride: TDurationCompactnessOverride;
    HasCompact: Boolean;
    CompactOverride: TDurationCompactnessOverride;
  end;

  TDurationLocalePtr = ^TDurationLocale;

implementation

end.
