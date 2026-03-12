{$mode objfpc}{$H+}
{$codepage utf8}
program sayable;

uses SysUtils,
     SayableAgeTypes, SayableAge, SayableAgeLocales,
     SayableDateTypes, SayableDate, SayableDateLocales,
     SayableDurationTypes, SayableDuration, SayableDurationLocales,
     SayableTimeTypes, SayableTime, SayableTimeLocales;

const
  CliVersion = '0.5.0';

var
  Command: string;
  Positionals: array of string;
  PositionalCount: Integer;
  OptLocale: string;
  OptAsOf: string;
  OptCompactness: string;
  OptGender: string;
  OptWithYear: Boolean;

procedure WriteError(const AMsg: string);
begin
  WriteLn(StdErr, 'error: ', AMsg);
  WriteLn(StdErr, 'Run ''sayable help'' for usage.');
  Halt(2);
end;

procedure PrintHelp;
begin
  WriteLn('Usage: sayable <command> [arguments] [options]');
  WriteLn('');
  WriteLn('Commands:');
  WriteLn('  age <dob>              Format an age');
  WriteLn('  stage <dob>            Get developmental stage');
  WriteLn('  date <date>            Format a calendar date');
  WriteLn('  relative <date>        Format a relative date');
  WriteLn('  time <time>            Format a clock time');
  WriteLn('  duration <value> [end] Format a duration');
  WriteLn('  since <start>          Format elapsed time');
  WriteLn('  until <target>         Format remaining time');
  WriteLn('  locales                List available locale codes');
  WriteLn('  version                Show version');
  WriteLn('  help                   Show this help');
  WriteLn('');
  WriteLn('Options:');
  WriteLn('  -l, --locale <code>    Locale code (default: en)');
  WriteLn('  -d, --as-of <value>    Reference date/timestamp');
  WriteLn('      --short            Short compactness');
  WriteLn('      --compact          Compact compactness');
  WriteLn('  -g, --gender <m|f>     Gender for stage labels');
  WriteLn('      --with-year        Include year (date only)');
  WriteLn('  -h, --help             Show this help');
  WriteLn('  -v, --version          Show version');
end;

function Nullify(const AValue: string): string;
begin
  if AValue = 'null' then
    Result := ''
  else
    Result := AValue;
end;

function IsNullArg(const AValue: string): Boolean;
begin
  Result := AValue = 'null';
end;

function GetTodayStr: string;
var
  Y, M, D: Word;
begin
  DecodeDate(Date, Y, M, D);
  Result := Format('%.4d-%.2d-%.2d', [Y, M, D]);
end;

function IsDigits(const S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if S = '' then exit;
  for I := 1 to Length(S) do
    if not (S[I] in ['0'..'9']) then exit;
  Result := True;
end;

function IsNegativeInt(const S: string): Boolean;
begin
  Result := False;
  if Length(S) < 2 then exit;
  if S[1] <> '-' then exit;
  Result := IsDigits(Copy(S, 2, Length(S) - 1));
end;

procedure ParseArgs;
var
  I: Integer;
  Arg: string;
  StopOpts: Boolean;
begin
  Command := '';
  SetLength(Positionals, 0);
  PositionalCount := 0;
  OptLocale := 'en';
  OptAsOf := '';
  OptCompactness := 'normal';
  OptGender := '';
  OptWithYear := False;
  StopOpts := False;

  if ParamCount = 0 then begin
    Command := '';
    exit;
  end;

  Arg := ParamStr(1);
  if (Arg = '-h') or (Arg = '--help') or (Arg = 'help') then begin
    Command := 'help';
    exit;
  end;
  if (Arg = '-v') or (Arg = '--version') or (Arg = 'version') then begin
    Command := 'version';
    exit;
  end;

  Command := Arg;
  I := 2;
  while I <= ParamCount do begin
    Arg := ParamStr(I);

    if (Arg = '--') and (not StopOpts) then begin
      StopOpts := True;
      Inc(I);
      continue;
    end;

    if (not StopOpts) and (Length(Arg) > 0) and (Arg[1] = '-') and (not IsNegativeInt(Arg)) then begin
      if (Arg = '-l') or (Arg = '--locale') then begin
        if I >= ParamCount then WriteError('''' + Arg + ''' requires a value');
        Inc(I);
        OptLocale := ParamStr(I);
      end
      else if (Arg = '-d') or (Arg = '--as-of') then begin
        if I >= ParamCount then WriteError('''' + Arg + ''' requires a value');
        Inc(I);
        OptAsOf := ParamStr(I);
      end
      else if (Arg = '-g') or (Arg = '--gender') then begin
        if I >= ParamCount then WriteError('''' + Arg + ''' requires a value');
        Inc(I);
        OptGender := ParamStr(I);
      end
      else if Arg = '--short' then
        OptCompactness := 'short'
      else if Arg = '--compact' then
        OptCompactness := 'compact'
      else if Arg = '--with-year' then
        OptWithYear := True
      else if (Arg = '-h') or (Arg = '--help') then begin
        Command := 'help';
        exit;
      end
      else if (Arg = '-v') or (Arg = '--version') then begin
        Command := 'version';
        exit;
      end
      else
        WriteError('unknown option ''' + Arg + '''');
    end else begin
      Inc(PositionalCount);
      SetLength(Positionals, PositionalCount);
      Positionals[PositionalCount - 1] := Arg;
    end;

    Inc(I);
  end;
end;

function AgeCompactness: TCompactness;
begin
  if OptCompactness = 'short' then Result := csShort
  else if OptCompactness = 'compact' then Result := csCompact
  else Result := csNormal;
end;

function DateCompactness: TDateCompactness;
begin
  if OptCompactness = 'short' then Result := dcShort
  else if OptCompactness = 'compact' then Result := dcCompact
  else Result := dcNormal;
end;

function DurCompactness: TDurCompactness;
begin
  if OptCompactness = 'short' then Result := durShort
  else if OptCompactness = 'compact' then Result := durCompact
  else Result := durNormal;
end;

function TimeCompact: TTimeCompactness;
begin
  if OptCompactness = 'short' then Result := tcShort
  else if OptCompactness = 'compact' then Result := tcCompact
  else Result := tcNormal;
end;

procedure CmdAge;
var
  Loc: TAgeLocale;
  LPtr: TAgeLocalePtr;
  Dob, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('age requires a date-of-birth argument');

  LPtr := GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Dob := ''
  else
    Dob := Positionals[0];

  if OptAsOf <> '' then
    AsOf := Nullify(OptAsOf)
  else
    AsOf := GetTodayStr;

  Res := FormatAge(Loc, AgeCompactness, Dob, AsOf);
  if IsNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdStage;
var
  Loc: TAgeLocale;
  LPtr: TAgeLocalePtr;
  Dob, AsOf, Gender, Res: string;
begin
  if PositionalCount < 1 then WriteError('stage requires a date-of-birth argument');

  LPtr := GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Dob := ''
  else
    Dob := Positionals[0];

  if OptAsOf <> '' then
    AsOf := Nullify(OptAsOf)
  else
    AsOf := GetTodayStr;

  Gender := OptGender;
  Res := FormatStage(Loc, Dob, AsOf, Gender);
  if IsNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdDate;
var
  Loc: TDateLocale;
  LPtr: TDateLocalePtr;
  DateVal, Res: string;
begin
  if PositionalCount < 1 then WriteError('date requires a date argument');

  LPtr := GetDateLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    DateVal := ''
  else
    DateVal := Positionals[0];

  if OptWithYear then
    Res := FormatDateWithYear(Loc, DateCompactness, DateVal)
  else
    Res := SayableDate.FormatDate(Loc, DateCompactness, DateVal);

  if IsDateNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdRelative;
var
  Loc: TDateLocale;
  LPtr: TDateLocalePtr;
  DateVal, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('relative requires a date argument');

  if OptAsOf = '' then
    WriteError('relative requires --as-of / -d option');
  AsOf := Nullify(OptAsOf);

  LPtr := GetDateLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    DateVal := ''
  else
    DateVal := Positionals[0];

  Res := FormatRelative(Loc, DateCompactness, DateVal, AsOf);
  if IsDateNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdTime;
var
  Loc: TTimeLocale;
  LPtr: TTimeLocalePtr;
  TimeVal, Res: string;
begin
  if PositionalCount < 1 then WriteError('time requires a time argument');

  LPtr := GetTimeLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    TimeVal := ''
  else
    TimeVal := Positionals[0];

  Res := SayableTime.FormatTime(Loc, TimeCompact, TimeVal);
  if IsTimeNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdDuration;
var
  Loc: TDurationLocale;
  LPtr: TDurationLocalePtr;
  Value, EndVal, Res: string;
  Seconds: Int64;
begin
  if PositionalCount < 1 then WriteError('duration requires a value argument');

  LPtr := GetDurLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then begin
    Res := FormatDuration(Loc, DurCompactness, -1);
    if IsDurNullResult(Res) then Halt(1);
    WriteLn(Res);
    exit;
  end;

  Value := Positionals[0];

  if IsDigits(Value) then begin
    Seconds := StrToInt64(Value);
    Res := FormatDuration(Loc, DurCompactness, Seconds);
  end
  else if IsNegativeInt(Value) then begin
    Seconds := StrToInt64(Value);
    Res := FormatDuration(Loc, DurCompactness, Seconds);
  end
  else begin
    if PositionalCount < 2 then
      WriteError('duration with timestamps requires start and end arguments');
    EndVal := Positionals[1];
    if IsNullArg(EndVal) then EndVal := '';
    Res := FormatDurationISO(Loc, DurCompactness, Value, EndVal);
  end;

  if IsDurNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdSince;
var
  Loc: TDurationLocale;
  LPtr: TDurationLocalePtr;
  Start, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('since requires a start timestamp argument');

  if OptAsOf = '' then
    WriteError('since requires --as-of / -d option');
  AsOf := Nullify(OptAsOf);

  LPtr := GetDurLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Start := ''
  else
    Start := Positionals[0];

  Res := FormatSince(Loc, DurCompactness, Start, AsOf);
  if IsDurNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdUntil;
var
  Loc: TDurationLocale;
  LPtr: TDurationLocalePtr;
  Target, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('until requires a target timestamp argument');

  if OptAsOf = '' then
    WriteError('until requires --as-of / -d option');
  AsOf := Nullify(OptAsOf);

  LPtr := GetDurLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Target := ''
  else
    Target := Positionals[0];

  Res := FormatUntil(Loc, DurCompactness, Target, AsOf);
  if IsDurNullResult(Res) then
    Halt(1);
  WriteLn(Res);
end;

procedure CmdLocales;
var
  LPtr: TAgeLocalePtr;
  Codes: array of string;
  CodeCount, I: Integer;
  AllCodes: array[0..199] of string;
  AllCount: Integer;
begin
  CodeCount := 0;
  SetLength(Codes, 200);

  AllCodes[0] := 'af';
  AllCodes[1] := 'ak';
  AllCodes[2] := 'am';
  AllCodes[3] := 'ar';
  AllCodes[4] := 'ay';
  AllCodes[5] := 'az';
  AllCodes[6] := 'bci';
  AllCodes[7] := 'be';
  AllCodes[8] := 'bem';
  AllCodes[9] := 'bg';
  AllCodes[10] := 'bi';
  AllCodes[11] := 'bm';
  AllCodes[12] := 'bn';
  AllCodes[13] := 'br';
  AllCodes[14] := 'bs';
  AllCodes[15] := 'ca';
  AllCodes[16] := 'cak';
  AllCodes[17] := 'ceb';
  AllCodes[18] := 'cs';
  AllCodes[19] := 'cy';
  AllCodes[20] := 'da';
  AllCodes[21] := 'de';
  AllCodes[22] := 'din';
  AllCodes[23] := 'dje';
  AllCodes[24] := 'dv';
  AllCodes[25] := 'dyu';
  AllCodes[26] := 'dz';
  AllCodes[27] := 'ee';
  AllCodes[28] := 'el';
  AllCodes[29] := 'en';
  AllCodes[30] := 'es';
  AllCodes[31] := 'et';
  AllCodes[32] := 'eu';
  AllCodes[33] := 'fa';
  AllCodes[34] := 'fan';
  AllCodes[35] := 'ff';
  AllCodes[36] := 'fi';
  AllCodes[37] := 'fil';
  AllCodes[38] := 'fj';
  AllCodes[39] := 'fon';
  AllCodes[40] := 'fr';
  AllCodes[41] := 'ga';
  AllCodes[42] := 'gd';
  AllCodes[43] := 'gl';
  AllCodes[44] := 'gn';
  AllCodes[45] := 'gu';
  AllCodes[46] := 'gv';
  AllCodes[47] := 'ha';
  AllCodes[48] := 'he';
  AllCodes[49] := 'hi';
  AllCodes[50] := 'hmn';
  AllCodes[51] := 'hr';
  AllCodes[52] := 'ht';
  AllCodes[53] := 'hu';
  AllCodes[54] := 'hy';
  AllCodes[55] := 'id';
  AllCodes[56] := 'ig';
  AllCodes[57] := 'is';
  AllCodes[58] := 'it';
  AllCodes[59] := 'ja';
  AllCodes[60] := 'jv';
  AllCodes[61] := 'ka';
  AllCodes[62] := 'kbp';
  AllCodes[63] := 'kek';
  AllCodes[64] := 'ki';
  AllCodes[65] := 'kk';
  AllCodes[66] := 'kl';
  AllCodes[67] := 'km';
  AllCodes[68] := 'kn';
  AllCodes[69] := 'ko';
  AllCodes[70] := 'kpe';
  AllCodes[71] := 'kri';
  AllCodes[72] := 'ktu';
  AllCodes[73] := 'ku';
  AllCodes[74] := 'kw';
  AllCodes[75] := 'ky';
  AllCodes[76] := 'lb';
  AllCodes[77] := 'lg';
  AllCodes[78] := 'ln';
  AllCodes[79] := 'lo';
  AllCodes[80] := 'lt';
  AllCodes[81] := 'luo';
  AllCodes[82] := 'lv';
  AllCodes[83] := 'mam';
  AllCodes[84] := 'men';
  AllCodes[85] := 'mfe';
  AllCodes[86] := 'mg';
  AllCodes[87] := 'mi';
  AllCodes[88] := 'mk';
  AllCodes[89] := 'ml';
  AllCodes[90] := 'mn';
  AllCodes[91] := 'mnk';
  AllCodes[92] := 'mos';
  AllCodes[93] := 'mr';
  AllCodes[94] := 'ms';
  AllCodes[95] := 'mt';
  AllCodes[96] := 'my';
  AllCodes[97] := 'nb';
  AllCodes[98] := 'nd';
  AllCodes[99] := 'ne';
  AllCodes[100] := 'ng';
  AllCodes[101] := 'nl';
  AllCodes[102] := 'nr';
  AllCodes[103] := 'nso';
  AllCodes[104] := 'nus';
  AllCodes[105] := 'ny';
  AllCodes[106] := 'om';
  AllCodes[107] := 'or';
  AllCodes[108] := 'pa';
  AllCodes[109] := 'pis';
  AllCodes[110] := 'pl';
  AllCodes[111] := 'pov';
  AllCodes[112] := 'ps';
  AllCodes[113] := 'pt';
  AllCodes[114] := 'qu';
  AllCodes[115] := 'quc';
  AllCodes[116] := 'ro';
  AllCodes[117] := 'ru';
  AllCodes[118] := 'rw';
  AllCodes[119] := 'sar';
  AllCodes[120] := 'sd';
  AllCodes[121] := 'sg';
  AllCodes[122] := 'shi';
  AllCodes[123] := 'shn';
  AllCodes[124] := 'si';
  AllCodes[125] := 'sk';
  AllCodes[126] := 'sl';
  AllCodes[127] := 'sn';
  AllCodes[128] := 'snk';
  AllCodes[129] := 'so';
  AllCodes[130] := 'sq';
  AllCodes[131] := 'sr';
  AllCodes[132] := 'ss';
  AllCodes[133] := 'st';
  AllCodes[134] := 'su';
  AllCodes[135] := 'suk';
  AllCodes[136] := 'sv';
  AllCodes[137] := 'sw';
  AllCodes[138] := 'ta';
  AllCodes[139] := 'te';
  AllCodes[140] := 'tem';
  AllCodes[141] := 'tet';
  AllCodes[142] := 'tg';
  AllCodes[143] := 'th';
  AllCodes[144] := 'ti';
  AllCodes[145] := 'tig';
  AllCodes[146] := 'tk';
  AllCodes[147] := 'tn';
  AllCodes[148] := 'tpi';
  AllCodes[149] := 'tr';
  AllCodes[150] := 'ts';
  AllCodes[151] := 'tum';
  AllCodes[152] := 'tzm';
  AllCodes[153] := 'uk';
  AllCodes[154] := 'umb';
  AllCodes[155] := 'ur';
  AllCodes[156] := 'uz';
  AllCodes[157] := 've';
  AllCodes[158] := 'vi';
  AllCodes[159] := 'vmw';
  AllCodes[160] := 'wo';
  AllCodes[161] := 'xh';
  AllCodes[162] := 'yao';
  AllCodes[163] := 'yo';
  AllCodes[164] := 'yue';
  AllCodes[165] := 'zdj';
  AllCodes[166] := 'zh';
  AllCodes[167] := 'zu';
  AllCount := 168;

  for I := 0 to AllCount - 1 do begin
    LPtr := GetLocale(AllCodes[I]);
    if LPtr <> nil then begin
      Codes[CodeCount] := AllCodes[I];
      Inc(CodeCount);
    end;
  end;

  for I := 0 to CodeCount - 1 do
    WriteLn(Codes[I]);
end;

begin
  ParseArgs;

  if Command = '' then begin
    PrintHelp;
    Halt(2);
  end;

  if Command = 'help' then begin
    PrintHelp;
    Halt(0);
  end;

  if Command = 'version' then begin
    WriteLn('sayable ', CliVersion);
    Halt(0);
  end;

  if Command = 'locales' then begin
    CmdLocales;
    Halt(0);
  end;

  if Command = 'age' then CmdAge
  else if Command = 'stage' then CmdStage
  else if Command = 'date' then CmdDate
  else if Command = 'relative' then CmdRelative
  else if Command = 'time' then CmdTime
  else if Command = 'duration' then CmdDuration
  else if Command = 'since' then CmdSince
  else if Command = 'until' then CmdUntil
  else WriteError('unknown command ''' + Command + '''');
end.
