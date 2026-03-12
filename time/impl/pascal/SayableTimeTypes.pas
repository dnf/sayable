{$mode objfpc}{$H+}
{$codepage utf8}
unit SayableTimeTypes;

interface

type
  TCompactness = (csNormal, csShort, csCompact);

  TClockConfig = record
    Hours: array[0..11] of string;
    Midnight: string;
    Noon: string;
    Patterns: array[0..55] of string;
  end;

  TShortClockConfig = record
    Use24h: Boolean;
    Format: string;
    HasAmPm: Boolean;
    AmStr: string;
    PmStr: string;
  end;

  TTimeCompactnessOverride = record
    Clock: TShortClockConfig;
  end;

  TTimeLocale = record
    Code: string;
    Clock: TClockConfig;
    HasShort: Boolean;
    ShortOverride: TTimeCompactnessOverride;
    HasCompact: Boolean;
    CompactOverride: TTimeCompactnessOverride;
  end;

  TTimeLocalePtr = ^TTimeLocale;

implementation

end.
