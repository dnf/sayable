module Main (main) where

import Data.Char (isDigit)
import Data.List (sort)
import System.Environment (getArgs)
import System.Exit (ExitCode(..), exitWith, exitSuccess)
import System.IO (hPutStrLn, stderr)

import qualified SayableAge.Formatter as Age
import qualified SayableAge.Locales as AgeLocales
import qualified SayableAge.Types as AgeTypes

import qualified SayableDate.Formatter as Date
import qualified SayableDate.Locales as DateLocales
import qualified SayableDate.Types as DateTypes

import qualified SayableTime.Formatter as Time
import qualified SayableTime.Locales as TimeLocales
import qualified SayableTime.Types as TimeTypes

import qualified SayableDuration.Formatter as Duration
import qualified SayableDuration.Locales as DurationLocales
import qualified SayableDuration.Types as DurationTypes

cliVersion :: String
cliVersion = "0.5.0"

helpText :: String
helpText = unlines
    [ "Usage: sayable <command> [arguments] [options]"
    , ""
    , "Commands:"
    , "  age <dob>              Format an age"
    , "  stage <dob>            Get developmental stage"
    , "  date <date>            Format a calendar date"
    , "  relative <date>        Format a relative date"
    , "  time <time>            Format a clock time"
    , "  duration <value> [end] Format a duration"
    , "  since <start>          Format elapsed time"
    , "  until <target>         Format remaining time"
    , "  locales                List available locale codes"
    , "  version                Show version"
    , "  help                   Show this help"
    , ""
    , "Options:"
    , "  -l, --locale <code>    Locale code (default: en)"
    , "  -d, --as-of <value>    Reference date/timestamp"
    , "      --short            Short compactness"
    , "      --compact          Compact compactness"
    , "  -g, --gender <m|f>     Gender for stage labels"
    , "      --with-year        Include year (date only)"
    , "  -h, --help             Show this help"
    , "  -v, --version          Show version"
    ]

-- All supported locale codes (sorted)
allLocales :: [String]
allLocales =
    [ "af", "ak", "am", "ar", "az", "bci", "be", "bem", "bg", "bm"
    , "bn", "br", "bs", "ca", "ceb", "cs", "cy", "da", "de", "din"
    , "dje", "dyu", "ee", "el", "en", "es", "et", "eu", "fa", "fan"
    , "ff", "fi", "fil", "fon", "fr", "ga", "gd", "gl", "gn", "gu"
    , "gv", "ha", "he", "hi", "hr", "ht", "hu", "hy", "id", "ig"
    , "is", "it", "ja", "jv", "ka", "kbp", "kk", "km", "kn", "ko"
    , "kpe", "ktu", "ku", "kw", "ky", "lg", "ln", "lo", "lt", "lv"
    , "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr"
    , "ms", "mt", "my", "nb", "nd", "ne", "ng", "nl", "nso", "nus"
    , "ny", "om", "or", "pa", "pl", "pov", "ps", "pt", "qu", "ro"
    , "ru", "rw", "sar", "sd", "sg", "shi", "si", "sk", "sl", "sn"
    , "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw"
    , "ta", "te", "tem", "tg", "th", "ti", "tig", "tk", "tn", "tr"
    , "ts", "tzm", "uk", "umb", "ur", "uz", "vi", "vmw", "wo", "xh"
    , "yo", "yue", "zdj", "zh", "zu"
    ]

-- Parsed CLI options
data Options = Options
    { optLocale    :: String
    , optAsOf      :: Maybe String
    , optCompactness :: String  -- "normal", "short", "compact"
    , optGender    :: Maybe String
    , optWithYear  :: Bool
    }

defaultOptions :: Options
defaultOptions = Options
    { optLocale    = "en"
    , optAsOf      = Nothing
    , optCompactness = "normal"
    , optGender    = Nothing
    , optWithYear  = False
    }

-- Convert CLI "null" sentinel to Nothing
nullify :: String -> Maybe String
nullify "null" = Nothing
nullify s      = Just s

-- Print error to stderr and exit with code 2
usageError :: String -> IO a
usageError msg = do
    hPutStrLn stderr ("error: " ++ msg)
    hPutStrLn stderr "Run 'sayable help' for usage."
    exitWith (ExitFailure 2)

-- Print result or exit 1 for null
printResult :: Maybe String -> IO ()
printResult Nothing  = exitWith (ExitFailure 1)
printResult (Just s) = putStrLn s >> exitSuccess

-- Parse arguments into (command, positionals, options)
data ParseResult
    = ParsedHelp
    | ParsedVersion
    | ParsedCommand String [String] Options

parseArgs :: [String] -> IO ParseResult
parseArgs [] = return ParsedHelp
parseArgs (first:rest)
    | first `elem` ["-h", "--help", "help"]    = return ParsedHelp
    | first `elem` ["-v", "--version", "version"] = return ParsedVersion
    | otherwise = do
        (pos, opts) <- parseOpts rest False [] defaultOptions
        return (ParsedCommand first pos opts)

parseOpts :: [String] -> Bool -> [String] -> Options -> IO ([String], Options)
parseOpts [] _ pos opts = return (reverse pos, opts)
parseOpts ("--":rest) False pos opts = parseOpts rest True pos opts
parseOpts (arg:rest) stopOpts pos opts
    | stopOpts || not (isOption arg) = parseOpts rest stopOpts (arg:pos) opts
    | arg `elem` ["-l", "--locale"] = do
        case rest of
            []    -> usageError ("'" ++ arg ++ "' requires a value")
            (v:rest') -> parseOpts rest' False pos (opts { optLocale = v })
    | arg `elem` ["-d", "--as-of"] = do
        case rest of
            []    -> usageError ("'" ++ arg ++ "' requires a value")
            (v:rest') -> parseOpts rest' False pos (opts { optAsOf = Just v })
    | arg `elem` ["-g", "--gender"] = do
        case rest of
            []    -> usageError ("'" ++ arg ++ "' requires a value")
            (v:rest') -> parseOpts rest' False pos (opts { optGender = Just v })
    | arg == "--short"    = parseOpts rest False pos (opts { optCompactness = "short" })
    | arg == "--compact"  = parseOpts rest False pos (opts { optCompactness = "compact" })
    | arg == "--with-year" = parseOpts rest False pos (opts { optWithYear = True })
    | arg `elem` ["-h", "--help"]    = return ([], opts)  -- will become ParsedHelp
    | arg `elem` ["-v", "--version"] = return ([], opts)  -- will become ParsedVersion
    | otherwise = usageError ("unknown option '" ++ arg ++ "'")

isOption :: String -> Bool
isOption ('-':_) = True
isOption _       = False

-- Convert compactness string to age Compactness
toAgeCompactness :: String -> AgeTypes.Compactness
toAgeCompactness "short"   = AgeTypes.Short
toAgeCompactness "compact" = AgeTypes.Compact
toAgeCompactness _         = AgeTypes.Normal

-- Convert compactness string to date Compactness
toDateCompactness :: String -> DateTypes.Compactness
toDateCompactness "short"   = DateTypes.Short
toDateCompactness "compact" = DateTypes.Compact
toDateCompactness _         = DateTypes.Normal

-- Convert compactness string to time Compactness
toTimeCompactness :: String -> TimeTypes.Compactness
toTimeCompactness "short"   = TimeTypes.Short
toTimeCompactness "compact" = TimeTypes.Compact
toTimeCompactness _         = TimeTypes.Normal

-- Convert compactness string to duration Compactness
toDurationCompactness :: String -> DurationTypes.Compactness
toDurationCompactness "short"   = DurationTypes.Short
toDurationCompactness "compact" = DurationTypes.Compact
toDurationCompactness _         = DurationTypes.Normal

-- Convert gender string to age Gender
toGender :: Maybe String -> Maybe AgeTypes.Gender
toGender (Just "f") = Just AgeTypes.F
toGender (Just "m") = Just AgeTypes.M
toGender _          = Nothing

-- Check if a string is all digits (non-negative integer)
isAllDigits :: String -> Bool
isAllDigits [] = False
isAllDigits s  = all isDigit s

-- Check if a string is a negative integer
isNegativeInt :: String -> Bool
isNegativeInt ('-':rest) = isAllDigits rest
isNegativeInt _          = False

-- Safe integer parsing
readInt :: String -> Maybe Int
readInt s = case reads s of
    [(n, "")] -> Just n
    _         -> Nothing

-- Command handlers

cmdAge :: [String] -> Options -> IO ()
cmdAge [] _ = usageError "age requires a date-of-birth argument"
cmdAge (raw:_) opts = do
    let locCode = optLocale opts
    case AgeLocales.getLocale locCode of
        Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
        Just loc -> do
            let compactness = toAgeCompactness (optCompactness opts)
            case nullify raw of
                Nothing -> do
                    -- null input: formatAgePure with empty string returns Nothing
                    printResult Nothing
                Just dob -> do
                    let mAsOf = optAsOf opts >>= nullify
                    result <- Age.formatAge loc compactness dob mAsOf
                    printResult result

cmdStage :: [String] -> Options -> IO ()
cmdStage [] _ = usageError "stage requires a date-of-birth argument"
cmdStage (raw:_) opts = do
    let locCode = optLocale opts
    case AgeLocales.getLocale locCode of
        Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
        Just loc -> do
            let gender = toGender (optGender opts)
            case nullify raw of
                Nothing -> printResult Nothing
                Just dob -> do
                    let mAsOf = optAsOf opts >>= nullify
                    result <- Age.formatStage loc dob mAsOf gender
                    printResult result

cmdDate :: [String] -> Options -> IO ()
cmdDate [] _ = usageError "date requires a date argument"
cmdDate (raw:_) opts = do
    let locCode = optLocale opts
    case DateLocales.getLocale locCode of
        Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
        Just loc -> do
            let compactness = toDateCompactness (optCompactness opts)
                mDate = nullify raw
            if optWithYear opts
                then printResult (Date.formatDateWithYear loc compactness mDate)
                else printResult (Date.formatDate loc compactness mDate)

cmdRelative :: [String] -> Options -> IO ()
cmdRelative [] _ = usageError "relative requires a date argument"
cmdRelative (raw:_) opts = do
    case optAsOf opts of
        Nothing -> usageError "relative requires --as-of / -d option"
        Just asOfRaw -> do
            let locCode = optLocale opts
            case DateLocales.getLocale locCode of
                Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
                Just loc -> do
                    let compactness = toDateCompactness (optCompactness opts)
                        mDate = nullify raw
                        mAsOf = nullify asOfRaw
                    printResult (Date.formatRelative loc compactness mDate mAsOf)

cmdTime :: [String] -> Options -> IO ()
cmdTime [] _ = usageError "time requires a time argument"
cmdTime (raw:_) opts = do
    let locCode = optLocale opts
    case TimeLocales.getLocale locCode of
        Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
        Just loc -> do
            let compactness = toTimeCompactness (optCompactness opts)
                mTime = nullify raw
            printResult (Time.formatTime loc compactness mTime)

cmdDuration :: [String] -> Options -> IO ()
cmdDuration [] _ = usageError "duration requires a value argument"
cmdDuration (raw:rest) opts = do
    let locCode = optLocale opts
    case DurationLocales.getLocale locCode of
        Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
        Just loc -> do
            let compactness = toDurationCompactness (optCompactness opts)
            case nullify raw of
                Nothing -> printResult (Duration.formatDuration loc compactness (-1))
                Just val
                    | isAllDigits val -> do
                        case readInt val of
                            Nothing -> usageError "invalid integer for duration"
                            Just n  -> printResult (Duration.formatDuration loc compactness n)
                    | isNegativeInt val -> do
                        case readInt val of
                            Nothing -> usageError "invalid integer for duration"
                            Just n  -> printResult (Duration.formatDuration loc compactness n)
                    | otherwise -> do
                        -- Timestamp mode: need end argument
                        case rest of
                            [] -> usageError "duration with timestamps requires start and end arguments"
                            (endRaw:_) -> case nullify endRaw of
                                Nothing -> usageError "duration with timestamps requires start and end arguments"
                                Just endVal -> printResult (Duration.formatDurationIso loc compactness val endVal)

cmdSince :: [String] -> Options -> IO ()
cmdSince [] _ = usageError "since requires a start timestamp argument"
cmdSince (raw:_) opts = do
    case optAsOf opts of
        Nothing -> usageError "since requires --as-of / -d option"
        Just asOfRaw -> do
            let locCode = optLocale opts
            case DurationLocales.getLocale locCode of
                Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
                Just loc -> do
                    let compactness = toDurationCompactness (optCompactness opts)
                        mStart = nullify raw
                        mAsOf = nullify asOfRaw
                    printResult (Duration.formatSince loc compactness mStart mAsOf)

cmdUntil :: [String] -> Options -> IO ()
cmdUntil [] _ = usageError "until requires a target timestamp argument"
cmdUntil (raw:_) opts = do
    case optAsOf opts of
        Nothing -> usageError "until requires --as-of / -d option"
        Just asOfRaw -> do
            let locCode = optLocale opts
            case DurationLocales.getLocale locCode of
                Nothing -> usageError ("unknown locale '" ++ locCode ++ "'")
                Just loc -> do
                    let compactness = toDurationCompactness (optCompactness opts)
                        mTarget = nullify raw
                        mAsOf = nullify asOfRaw
                    printResult (Duration.formatUntil loc compactness mTarget mAsOf)

cmdLocales :: IO ()
cmdLocales = do
    mapM_ putStrLn (sort allLocales)
    exitSuccess

main :: IO ()
main = do
    args <- getArgs
    parsed <- parseArgs args
    case parsed of
        ParsedHelp -> do
            putStr helpText
            exitSuccess
        ParsedVersion -> do
            putStrLn ("sayable " ++ cliVersion)
            exitSuccess
        ParsedCommand cmd pos opts ->
            case cmd of
                "age"      -> cmdAge pos opts
                "stage"    -> cmdStage pos opts
                "date"     -> cmdDate pos opts
                "relative" -> cmdRelative pos opts
                "time"     -> cmdTime pos opts
                "duration" -> cmdDuration pos opts
                "since"    -> cmdSince pos opts
                "until"    -> cmdUntil pos opts
                "locales"  -> cmdLocales
                "help"     -> putStr helpText >> exitSuccess
                "version"  -> putStrLn ("sayable " ++ cliVersion) >> exitSuccess
                _          -> usageError ("unknown command '" ++ cmd ++ "'")
