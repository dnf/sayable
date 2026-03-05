module SayableDuration.Formatter
    ( formatDuration
    , formatDurationIso
    , formatSince
    , formatUntil
    , version
    ) where

import SayableDuration.Types

version :: String
version = "0.1.0"

resolveUnit :: Int -> UnitForms -> DurationLocale -> String -> String
resolveUnit count uf loc half =
    let baseN = show count
        n = if not (null half) && isInfixOf' "{n}" half
            then replace "{n}" baseN half
            else baseN
        -- Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
        template = case uf of
            Simple s -> s
            Pluralized forms ->
                let cat = if not (null half) then Other else localePlural loc count
                in lookupUnitForm cat forms
        result = replace "{n}" n template
    in if not (null half) && isInfixOf' "{0}" half
       then replace "{0}" result half
       else result

isInfixOf' :: String -> String -> Bool
isInfixOf' needle haystack = go haystack
  where
    nLen = length needle
    go [] = False
    go s@(_:rest)
        | take nLen s == needle = True
        | otherwise = go rest

replace :: String -> String -> String -> String
replace _ _ [] = []
replace needle replacement haystack@(c:rest)
    | take nLen haystack == needle = replacement ++ replace needle replacement (drop nLen haystack)
    | otherwise = c : replace needle replacement rest
  where
    nLen = length needle

resolveLocale :: DurationLocale -> Compactness -> (UnitForms, UnitForms, UnitForms, UnitForms, UnitForms, UnitForms, UnitForms, String, String, String, String)
resolveLocale loc compactness =
    let u = localeUnits loc
        mOvr = case compactness of
            Normal  -> Nothing
            Short   -> localeShort loc
            Compact -> localeCompact loc
        apply ovr =
            ( maybe (unitSecond u) id (ovrSecond ovr)
            , maybe (unitMinute u) id (ovrMinute ovr)
            , maybe (unitHour u) id (ovrHour ovr)
            , maybe (unitDay u) id (ovrDay ovr)
            , maybe (unitWeek u) id (ovrWeek ovr)
            , maybe (unitMonth u) id (ovrMonth ovr)
            , maybe (unitYear u) id (ovrYear ovr)
            , maybe (localeHalf loc) id (ovrHalf ovr)
            , maybe (localeDelimiter loc) id (ovrDelimiter ovr)
            , maybe (localeAgo loc) id (ovrAgo ovr)
            , maybe (localeInFuture loc) id (ovrInFuture ovr)
            )
    in case mOvr of
        Nothing  -> (unitSecond u, unitMinute u, unitHour u, unitDay u, unitWeek u, unitMonth u, unitYear u, localeHalf loc, localeDelimiter loc, localeAgo loc, localeInFuture loc)
        Just ovr -> apply ovr

formatDuration :: DurationLocale -> Compactness -> Int -> Maybe String
formatDuration loc compactness seconds
    | seconds < 0 = Nothing
    | otherwise =
        let (sec, mn, hr, dy, wk, mo, yr, hf, del', _ago, _inf) = resolveLocale loc compactness
        in Just (formatInternal loc sec mn hr dy wk mo yr hf del' seconds)

formatDurationIso :: DurationLocale -> Compactness -> String -> String -> Maybe String
formatDurationIso loc compactness start end
    | null start || null end = Nothing
    | otherwise = do
        s <- parseIsoToSeconds start
        e <- parseIsoToSeconds end
        let total = abs (e - s)
            (sec, mn, hr, dy, wk, mo, yr, hf, del', _ago, _inf) = resolveLocale loc compactness
        Just (formatInternal loc sec mn hr dy wk mo yr hf del' total)

formatSince :: DurationLocale -> Compactness -> Maybe String -> Maybe String -> Maybe String
formatSince loc compactness mStart mAsOf = do
    start <- mStart
    asOf <- mAsOf
    if null start || null asOf then Nothing
    else do
        s <- parseIsoToSeconds start
        a <- parseIsoToSeconds asOf
        let diff = a - s
            (sec, mn, hr, dy, wk, mo, yr, hf, del', ago', _inf) = resolveLocale loc compactness
        if diff < 0 then Nothing
        else if diff == 0 then Just (localeJustNow loc)
        else let dur = formatInternal loc sec mn hr dy wk mo yr hf del' diff
             in Just (replace "{0}" dur ago')

formatUntil :: DurationLocale -> Compactness -> Maybe String -> Maybe String -> Maybe String
formatUntil loc compactness mTarget mAsOf = do
    target <- mTarget
    asOf <- mAsOf
    if null target || null asOf then Nothing
    else do
        t <- parseIsoToSeconds target
        a <- parseIsoToSeconds asOf
        let diff = t - a
            (sec, mn, hr, dy, wk, mo, yr, hf, del', _ago, inf') = resolveLocale loc compactness
        if diff < 0 then Nothing
        else if diff == 0 then Just (localeJustNow loc)
        else let dur = formatInternal loc sec mn hr dy wk mo yr hf del' diff
             in Just (replace "{0}" dur inf')

formatInternal :: DurationLocale -> UnitForms -> UnitForms -> UnitForms -> UnitForms -> UnitForms -> UnitForms -> UnitForms -> String -> String -> Int -> String
formatInternal loc sec mn hr dy wk mo yr hf del' total
    -- 0 seconds
    | total == 0 = localeJustNow loc
    -- 1-59 seconds
    | total < 60 = resolveUnit total sec loc ""
    -- 1-4 minutes: minutes + seconds
    | totalMinutes < 5 =
        let result = resolveUnit totalMinutes mn loc ""
        in if remainderSeconds > 0
           then result ++ del' ++ resolveUnit remainderSeconds sec loc ""
           else result
    -- 5-59 minutes
    | totalMinutes < 60 = resolveUnit totalMinutes mn loc ""
    -- 1-5 hours: hours + minutes (with half marker)
    | totalHours <= 5 =
        if remainderMinutes == 30
        then resolveUnit totalHours hr loc hf
        else let result = resolveUnit totalHours hr loc ""
             in if remainderMinutes > 0
                then result ++ del' ++ resolveUnit remainderMinutes mn loc ""
                else result
    -- 6-23 hours
    | totalHours < 24 = resolveUnit totalHours hr loc ""
    -- 1-2 days: days + hours (with half marker)
    | totalDays <= 2 =
        if remainderHours == 12
        then resolveUnit totalDays dy loc hf
        else let result = resolveUnit totalDays dy loc ""
             in if remainderHours > 0
                then result ++ del' ++ resolveUnit remainderHours hr loc ""
                else result
    -- 3-6 days
    | totalDays < 7 = resolveUnit totalDays dy loc ""
    -- 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
    | totalDays < 30 =
        let result = resolveUnit totalWeeks wk loc ""
        in if remainderDays > 0
           then result ++ del' ++ resolveUnit remainderDays dy loc ""
           else result
    -- Approximate months (30.44 days average)
    | totalMonths < 12 =
        let m = if totalMonths == 0 then 1 else totalMonths
        in resolveUnit m mo loc ""
    -- 12+ months: years + months
    | otherwise =
        let totalYears = totalMonths `div` 12
            remMonths = totalMonths `mod` 12
            result = resolveUnit totalYears yr loc ""
        in if remMonths > 0
           then result ++ del' ++ resolveUnit remMonths mo loc ""
           else result
  where
    totalMinutes = total `div` 60
    remainderSeconds = total `mod` 60
    totalHours = total `div` 3600
    remainderMinutes = (total `mod` 3600) `div` 60
    totalDays = total `div` 86400
    remainderHours = (total `mod` 86400) `div` 3600
    totalWeeks = totalDays `div` 7
    remainderDays = totalDays `mod` 7
    totalMonths = roundToInt (fromIntegral totalDays / 30.44 :: Double)

roundToInt :: Double -> Int
roundToInt x = floor (x + 0.5)

parseIsoToSeconds :: String -> Maybe Int
parseIsoToSeconds iso
    | null iso  = Nothing
    | otherwise =
        let tIdx = indexOf 'T' iso
        in if tIdx < 0 then Nothing
           else do
               let datePart = take tIdx iso
                   timePart = stripTz (drop (tIdx + 1) iso)
               (year, month, day) <- parseDatePart datePart
               (hour, minute, second) <- parseTimePart timePart
               let days = daysSinceEpoch year month day
               Just (days * 86400 + hour * 3600 + minute * 60 + second)

indexOf :: Char -> String -> Int
indexOf _ [] = -1
indexOf c (x:xs)
    | c == x    = 0
    | otherwise = let r = indexOf c xs
                  in if r < 0 then -1 else 1 + r

stripTz :: String -> String
stripTz [] = []
stripTz (c:rest)
    | c == '+' || c == 'Z' = []
    | otherwise = c : stripTz rest

parseDatePart :: String -> Maybe (Int, Int, Int)
parseDatePart s =
    case splitOn '-' s of
        [ys, ms, ds] -> do
            y <- safeAtoi ys
            m <- safeAtoi ms
            d <- safeAtoi ds
            Just (y, m, d)
        _ -> Nothing

parseTimePart :: String -> Maybe (Int, Int, Int)
parseTimePart s =
    case splitOn ':' s of
        [hs]       -> do h <- safeAtoi hs; Just (h, 0, 0)
        [hs, ms]   -> do h <- safeAtoi hs; m <- safeAtoi ms; Just (h, m, 0)
        (hs:ms:ss:_) -> do
            h <- safeAtoi hs
            m <- safeAtoi ms
            sec <- safeAtoi (takeWhile (\c -> c >= '0' && c <= '9') ss)
            Just (h, m, sec)
        _ -> Nothing

splitOn :: Char -> String -> [String]
splitOn _ [] = [""]
splitOn sep (c:rest)
    | c == sep  = "" : splitOn sep rest
    | otherwise = case splitOn sep rest of
        (x:xs) -> (c:x) : xs
        []     -> [[c]]

safeAtoi :: String -> Maybe Int
safeAtoi [] = Nothing
safeAtoi s  = go 0 s
  where
    go n [] = Just n
    go n (c:rest')
        | c >= '0' && c <= '9' = go (n * 10 + fromEnum c - fromEnum '0') rest'
        | otherwise = Nothing

isLeapYear :: Int -> Bool
isLeapYear y = (y `mod` 4 == 0 && y `mod` 100 /= 0) || y `mod` 400 == 0

daysInMonth :: Int -> Int -> Int
daysInMonth y m = case m of
    1  -> 31; 3  -> 31; 5  -> 31; 7  -> 31; 8  -> 31; 10 -> 31; 12 -> 31
    4  -> 30; 6  -> 30; 9  -> 30; 11 -> 30
    2  -> if isLeapYear y then 29 else 28
    _  -> 30

daysSinceEpoch :: Int -> Int -> Int -> Int
daysSinceEpoch year month day =
    let yDays = if year >= 2000
                then sum [if isLeapYear y then 366 else 365 | y <- [2000..year-1]]
                else negate (sum [if isLeapYear y then 366 else 365 | y <- [year..1999]])
        mDays = sum [daysInMonth year m | m <- [1..month-1]]
    in yDays + mDays + day - 1
