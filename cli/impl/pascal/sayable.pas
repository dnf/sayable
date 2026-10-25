{$mode objfpc}{$H+}
{$codepage utf8}
program sayable;

uses SysUtils, StrUtils,
     SayableAgeTypes, SayableAge, SayableAgeLocales,
     SayableDateTypes, SayableDate, SayableDateLocales,
     SayableDurationTypes, SayableDuration, SayableDurationLocales,
     SayableTimeTypes, SayableTime, SayableTimeLocales;

const
  CliVersion = '0.5.0';

type
  { Raised after a usage error has been reported, so the request answers 2. }
  EUsageError = class(Exception);

var
  { The current request's arguments: the command line, or one REPL line. }
  Args: array of string;
  { Stdout of the current request, so the REPL can answer on one line. }
  OutText: string;
  Command: string;
  Positionals: array of string;
  PositionalCount: Integer;
  OptLocale: string;
  OptAsOf: string;
  HasAsOf: Boolean;
  OptCompactness: string;
  OptGender: string;
  OptWithYear: Boolean;

procedure WriteError(const AMsg: string);
begin
  WriteLn(StdErr, 'error: ', AMsg);
  WriteLn(StdErr, 'Run ''sayable help'' for usage.');
  raise EUsageError.Create(AMsg);
end;

procedure Emit(const ALine: string);
begin
  OutText := OutText + ALine + LineEnding;
end;

procedure PrintHelp;
begin
  Emit('Usage: sayable <command> [arguments] [options]');
  Emit('');
  Emit('Commands:');
  Emit('  age <dob>              Format an age');
  Emit('  stage <dob>            Get developmental stage');
  Emit('  date <date>            Format a calendar date');
  Emit('  relative <date>        Format a relative date');
  Emit('  time <time>            Format a clock time');
  Emit('  duration <value> [end] Format a duration');
  Emit('  since <start>          Format elapsed time');
  Emit('  until <target>         Format remaining time');
  Emit('  locales                List available locale codes');
  Emit('  version                Show version');
  Emit('  help                   Show this help');
  Emit('');
  Emit('Options:');
  Emit('  -l, --locale <code>    Locale code (default: en)');
  Emit('  -d, --as-of <value>    Reference date/timestamp');
  Emit('      --short            Short compactness');
  Emit('      --compact          Compact compactness');
  Emit('  -g, --gender <m|f>     Gender for stage labels');
  Emit('      --with-year        Include year (date only)');
  Emit('  -h, --help             Show this help');
  Emit('  -v, --version          Show version');
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

{ A (possibly negative) digit string as seconds. Longer digit strings
  are far beyond the 500-year ceiling, so they saturate instead of
  overflowing. }
function ParseSeconds(const S: string): Int64;
const
  MaxExactDigits = 18;
var
  Digits: string;
begin
  Digits := S;
  if Digits[1] = '-' then Delete(Digits, 1, 1);
  while (Length(Digits) > 1) and (Digits[1] = '0') do Delete(Digits, 1, 1);
  if Length(Digits) > MaxExactDigits then
    Result := High(Int64)
  else
    Result := StrToInt64(Digits);
  if S[1] = '-' then Result := -Result;
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
  HasAsOf := False;
  OptCompactness := 'normal';
  OptGender := '';
  OptWithYear := False;
  StopOpts := False;

  if Length(Args) = 0 then
    exit;

  Arg := Args[0];
  if (Arg = '-h') or (Arg = '--help') or (Arg = 'help') then begin
    Command := 'help';
    exit;
  end;
  if (Arg = '-v') or (Arg = '--version') or (Arg = 'version') then begin
    Command := 'version';
    exit;
  end;

  Command := Arg;
  I := 1;
  while I < Length(Args) do begin
    Arg := Args[I];

    if (Arg = '--') and (not StopOpts) then begin
      StopOpts := True;
      Inc(I);
      continue;
    end;

    if (not StopOpts) and (Length(Arg) > 0) and (Arg[1] = '-') and (not IsNegativeInt(Arg)) then begin
      if (Arg = '-l') or (Arg = '--locale') then begin
        if I >= High(Args) then WriteError('''' + Arg + ''' requires a value');
        Inc(I);
        OptLocale := Args[I];
      end
      else if (Arg = '-d') or (Arg = '--as-of') then begin
        if I >= High(Args) then WriteError('''' + Arg + ''' requires a value');
        Inc(I);
        OptAsOf := Args[I];
        HasAsOf := True;
      end
      else if (Arg = '-g') or (Arg = '--gender') then begin
        if I >= High(Args) then WriteError('''' + Arg + ''' requires a value');
        Inc(I);
        OptGender := Args[I];
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

function AgeCompactness: SayableAgeTypes.TCompactness;
begin
  if OptCompactness = 'short' then Result := SayableAgeTypes.csShort
  else if OptCompactness = 'compact' then Result := SayableAgeTypes.csCompact
  else Result := SayableAgeTypes.csNormal;
end;

function DateCompactness: SayableDateTypes.TCompactness;
begin
  if OptCompactness = 'short' then Result := SayableDateTypes.csShort
  else if OptCompactness = 'compact' then Result := SayableDateTypes.csCompact
  else Result := SayableDateTypes.csNormal;
end;

function DurCompactness: SayableDurationTypes.TCompactness;
begin
  if OptCompactness = 'short' then Result := SayableDurationTypes.csShort
  else if OptCompactness = 'compact' then Result := SayableDurationTypes.csCompact
  else Result := SayableDurationTypes.csNormal;
end;

function TimeCompact: SayableTimeTypes.TCompactness;
begin
  if OptCompactness = 'short' then Result := SayableTimeTypes.csShort
  else if OptCompactness = 'compact' then Result := SayableTimeTypes.csCompact
  else Result := SayableTimeTypes.csNormal;
end;

function CmdAge: Integer;
var
  Loc: TAgeLocale;
  LPtr: TAgeLocalePtr;
  Dob, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('age requires a date-of-birth argument');

  LPtr := SayableAge.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Dob := ''
  else
    Dob := Positionals[0];

  { A null or empty as-of means today, as in the reference. }
  if Nullify(OptAsOf) <> '' then
    AsOf := OptAsOf
  else
    AsOf := GetTodayStr;

  Res := FormatAge(Loc, AgeCompactness, Dob, AsOf);
  if SayableAge.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdStage: Integer;
var
  Loc: TAgeLocale;
  LPtr: TAgeLocalePtr;
  Dob, AsOf, Gender, Res: string;
begin
  if PositionalCount < 1 then WriteError('stage requires a date-of-birth argument');

  LPtr := SayableAge.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Dob := ''
  else
    Dob := Positionals[0];

  { A null or empty as-of means today, as in the reference. }
  if Nullify(OptAsOf) <> '' then
    AsOf := OptAsOf
  else
    AsOf := GetTodayStr;

  Gender := OptGender;
  Res := FormatStage(Loc, Dob, AsOf, Gender);
  if SayableAge.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdDate: Integer;
var
  Loc: TDateLocale;
  LPtr: TDateLocalePtr;
  DateVal, Res: string;
begin
  if PositionalCount < 1 then WriteError('date requires a date argument');

  LPtr := SayableDate.GetLocale(OptLocale);
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

  if SayableDate.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdRelative: Integer;
var
  Loc: TDateLocale;
  LPtr: TDateLocalePtr;
  DateVal, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('relative requires a date argument');

  if not HasAsOf then
    WriteError('relative requires --as-of / -d option');
  AsOf := Nullify(OptAsOf);

  LPtr := SayableDate.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    DateVal := ''
  else
    DateVal := Positionals[0];

  Res := FormatRelative(Loc, DateCompactness, DateVal, AsOf);
  if SayableDate.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdTime: Integer;
var
  Loc: TTimeLocale;
  LPtr: TTimeLocalePtr;
  TimeVal, Res: string;
begin
  if PositionalCount < 1 then WriteError('time requires a time argument');

  LPtr := SayableTime.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    TimeVal := ''
  else
    TimeVal := Positionals[0];

  Res := SayableTime.FormatTime(Loc, TimeCompact, TimeVal);
  if SayableTime.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdDuration: Integer;
var
  Loc: TDurationLocale;
  LPtr: TDurationLocalePtr;
  Value, EndVal, Res: string;
  Seconds: Int64;
begin
  if PositionalCount < 1 then WriteError('duration requires a value argument');

  LPtr := SayableDuration.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then begin
    Res := FormatDuration(Loc, DurCompactness, -1);
    if SayableDuration.IsNullResult(Res) then
      exit(1);
    Emit(Res);
    exit(0);
  end;

  Value := Positionals[0];

  if IsDigits(Value) or IsNegativeInt(Value) then begin
    Seconds := ParseSeconds(Value);
    Res := FormatDuration(Loc, DurCompactness, Seconds);
  end
  else begin
    if PositionalCount < 2 then
      WriteError('duration with timestamps requires start and end arguments');
    EndVal := Positionals[1];
    if IsNullArg(EndVal) then EndVal := '';
    Res := FormatDurationISO(Loc, DurCompactness, Value, EndVal);
  end;

  if SayableDuration.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdSince: Integer;
var
  Loc: TDurationLocale;
  LPtr: TDurationLocalePtr;
  Start, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('since requires a start timestamp argument');

  if not HasAsOf then
    WriteError('since requires --as-of / -d option');
  AsOf := Nullify(OptAsOf);

  LPtr := SayableDuration.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Start := ''
  else
    Start := Positionals[0];

  Res := FormatSince(Loc, DurCompactness, Start, AsOf);
  if SayableDuration.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
end;

function CmdUntil: Integer;
var
  Loc: TDurationLocale;
  LPtr: TDurationLocalePtr;
  Target, AsOf, Res: string;
begin
  if PositionalCount < 1 then WriteError('until requires a target timestamp argument');

  if not HasAsOf then
    WriteError('until requires --as-of / -d option');
  AsOf := Nullify(OptAsOf);

  LPtr := SayableDuration.GetLocale(OptLocale);
  if LPtr = nil then WriteError('unknown locale ''' + OptLocale + '''');
  Loc := LPtr^;

  if IsNullArg(Positionals[0]) then
    Target := ''
  else
    Target := Positionals[0];

  Res := FormatUntil(Loc, DurCompactness, Target, AsOf);
  if SayableDuration.IsNullResult(Res) then
    exit(1);
  Emit(Res);
  Result := 0;
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
    LPtr := SayableAge.GetLocale(AllCodes[I]);
    if LPtr <> nil then begin
      Codes[CodeCount] := AllCodes[I];
      Inc(CodeCount);
    end;
  end;

  for I := 0 to CodeCount - 1 do
    Emit(Codes[I]);
end;

{ Runs the request in Args, leaving its stdout in OutText; returns the exit
  code. Unexpected exceptions propagate, so one-shot runs fail as before. }
function Run: Integer;
begin
  OutText := '';
  Result := 0;
  try
    ParseArgs;
    if Command = '' then begin
      PrintHelp;
      Result := 2;
    end
    else if Command = 'help' then PrintHelp
    else if Command = 'version' then Emit('sayable ' + CliVersion)
    else if Command = 'locales' then CmdLocales
    else if Command = 'age' then Result := CmdAge
    else if Command = 'stage' then Result := CmdStage
    else if Command = 'date' then Result := CmdDate
    else if Command = 'relative' then Result := CmdRelative
    else if Command = 'time' then Result := CmdTime
    else if Command = 'duration' then Result := CmdDuration
    else if Command = 'since' then Result := CmdSince
    else if Command = 'until' then Result := CmdUntil
    else WriteError('unknown command ''' + Command + '''');
  except
    on EUsageError do
      Result := 2;
  end;
end;

procedure LoadCommandLine;
var
  I: Integer;
begin
  SetLength(Args, ParamCount);
  for I := 1 to ParamCount do
    Args[I - 1] := ParamStr(I);
end;

{ Splits a REPL request on tabs, keeping empty fields. }
procedure LoadRequest(const ALine: string);
var
  I, Start: Integer;
begin
  SetLength(Args, 0);
  Start := 1;
  for I := 1 to Length(ALine) + 1 do
    if (I > Length(ALine)) or (ALine[I] = #9) then begin
      SetLength(Args, Length(Args) + 1);
      Args[High(Args)] := Copy(ALine, Start, I - Start);
      Start := I + 1;
    end;
end;

function StripCarriageReturn(const ALine: string): string;
begin
  Result := ALine;
  if (Result <> '') and (Result[Length(Result)] = #13) then
    SetLength(Result, Length(Result) - 1);
end;

{ OutText as a single response field: no trailing newline, inner newlines as tabs. }
function ResponseText: string;
begin
  Result := OutText;
  if (Result <> '') and (RightStr(Result, Length(LineEnding)) = LineEnding) then
    SetLength(Result, Length(Result) - Length(LineEnding));
  Result := StringReplace(Result, LineEnding, #9, [rfReplaceAll]);
end;

procedure Repl;
var
  Line: string;
  Code: Integer;
begin
  while not EOF(Input) do begin
    ReadLn(Line);
    LoadRequest(StripCarriageReturn(Line));
    try
      Code := Run;
    except
      { A crash exits 1 in one-shot mode; report it and keep serving. }
      on E: Exception do begin
        WriteLn(StdErr, 'error: ', E.ClassName, ': ', E.Message);
        OutText := '';
        Code := 1;
      end;
    end;
    WriteLn(Code, #9, ResponseText);
    Flush(Output);
  end;
end;

begin
  if (ParamCount = 1) and (ParamStr(1) = '--repl') then begin
    Repl;
    Halt(0);
  end;

  LoadCommandLine;
  ExitCode := Run;
  Write(OutText);
  Halt(ExitCode);
end.
