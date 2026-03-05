module SayableDate.Formatter
    ( formatDate
    , formatDateWithYear
    , formatRelative
    , version
    ) where

import SayableDate.Types

version :: String
version = "0.5.0"

formatDate :: DateLocale -> Compactness -> Maybe String -> Maybe String
formatDate _ _ Nothing = Nothing
formatDate loc compactness (Just date)
    | null date = Nothing
    | otherwise =
        case parseDate date of
            Nothing -> Nothing
            Just (y, m, d) ->
                let resolved = resolveLocale loc compactness
                in Just (formatAbsolute resolved y m d False)

formatDateWithYear :: DateLocale -> Compactness -> Maybe String -> Maybe String
formatDateWithYear _ _ Nothing = Nothing
formatDateWithYear loc compactness (Just date)
    | null date = Nothing
    | otherwise =
        case parseDate date of
            Nothing -> Nothing
            Just (y, m, d) ->
                let resolved = resolveLocale loc compactness
                in Just (formatAbsolute resolved y m d True)

formatRelative :: DateLocale -> Compactness -> Maybe String -> Maybe String -> Maybe String
formatRelative _ _ Nothing _ = Nothing
formatRelative _ _ _ Nothing = Nothing
formatRelative loc compactness (Just date) (Just asOf)
    | null date || null asOf = Nothing
    | otherwise = do
        (dy, dm, dd) <- parseDate date
        (ay, am', ad) <- parseDate asOf
        let dateJdn = toJdn dy dm dd
            asofJdn = toJdn ay am' ad
            diff = dateJdn - asofJdn
            resolved = resolveLocale loc compactness
            isCompact = compactness == Compact
        Just (formatRelativeInternal loc resolved dy dm dd ay diff isCompact)

data ResolvedLocale = ResolvedLocale
    { rlMonths              :: [String]
    , rlMonthsInDate        :: Maybe [String]
    , rlWeekdays            :: [String]
    , rlDayFormat           :: String
    , rlDayFormatExceptions :: [(String, String)]
    , rlDatePattern         :: String
    , rlDatePatternWithYear :: String
    , rlToday               :: String
    , rlTomorrow            :: String
    , rlYesterday           :: String
    }

resolveLocale :: DateLocale -> Compactness -> ResolvedLocale
resolveLocale loc compactness =
    let mOvr = case compactness of
            Normal  -> Nothing
            Short   -> localeShort loc
            Compact -> localeCompact loc
    in case mOvr of
        Nothing -> ResolvedLocale
            { rlMonths = localeMonths loc
            , rlMonthsInDate = localeMonthsInDate loc
            , rlWeekdays = localeWeekdays loc
            , rlDayFormat = localeDayFormat loc
            , rlDayFormatExceptions = localeDayFormatExceptions loc
            , rlDatePattern = localeDatePattern loc
            , rlDatePatternWithYear = localeDatePatternWithYear loc
            , rlToday = localeToday loc
            , rlTomorrow = localeTomorrow loc
            , rlYesterday = localeYesterday loc
            }
        Just ovr ->
            -- When override provides dayFormat but not dayFormatExceptions, clear exceptions
            let (df, dfe) = case (ovrDayFormat ovr, ovrDayFormatExceptions ovr) of
                    (Just f, Nothing) -> (f, [])
                    (Just f, Just e)  -> (f, e)
                    (Nothing, Just e) -> (localeDayFormat loc, e)
                    (Nothing, Nothing) -> (localeDayFormat loc, localeDayFormatExceptions loc)
            in ResolvedLocale
                { rlMonths = maybe (localeMonths loc) id (ovrMonths ovr)
                , rlMonthsInDate = case ovrMonthsInDate ovr of
                    Just mid -> Just mid
                    Nothing  -> localeMonthsInDate loc
                , rlWeekdays = maybe (localeWeekdays loc) id (ovrWeekdays ovr)
                , rlDayFormat = df
                , rlDayFormatExceptions = dfe
                , rlDatePattern = maybe (localeDatePattern loc) id (ovrDatePattern ovr)
                , rlDatePatternWithYear = maybe (localeDatePatternWithYear loc) id (ovrDatePatternWithYear ovr)
                , rlToday = maybe (localeToday loc) id (ovrToday ovr)
                , rlTomorrow = maybe (localeTomorrow loc) id (ovrTomorrow ovr)
                , rlYesterday = maybe (localeYesterday loc) id (ovrYesterday ovr)
                }

formatRelativeInternal :: DateLocale -> ResolvedLocale -> Int -> Int -> Int -> Int -> Int -> Bool -> String
formatRelativeInternal loc resolved dy dm dd ay diff isCompact
    -- Today
    | diff == 0 = rlToday resolved
    -- Tomorrow
    | diff == 1 = rlTomorrow resolved
    -- Yesterday
    | diff == -1 = rlYesterday resolved
    -- Day after tomorrow (optional, skipped in compact mode)
    | diff == 2 && not isCompact =
        case localeDayAfterTomorrow loc of
            Just s  -> s
            Nothing -> formatAbsolute resolved dy dm dd (dy /= ay)
    -- Day before yesterday (optional, skipped in compact mode)
    | diff == -2 && not isCompact =
        case localeDayBeforeYesterday loc of
            Just s  -> s
            Nothing -> formatAbsolute resolved dy dm dd (dy /= ay)
    -- Compact mode: skip weekday references, go straight to calendar date
    | isCompact = formatAbsolute resolved dy dm dd (dy /= ay)
    -- This weekday (+2 to +6)
    | diff >= 2 && diff <= 6 =
        case localeThisWeekday loc of
            Just template ->
                let dow = weekday dy dm dd
                    wdName = rlWeekdays resolved !! dow
                in replace "{weekday}" wdName template
            Nothing -> formatAbsolute resolved dy dm dd (dy /= ay)
    -- Last weekday (-6 to -2)
    | diff >= -6 && diff <= -2 =
        case localeLastWeekday loc of
            Just template ->
                let dow = weekday dy dm dd
                    wdName = rlWeekdays resolved !! dow
                in replace "{weekday}" wdName template
            Nothing -> formatAbsolute resolved dy dm dd (dy /= ay)
    -- Next weekday (+7 to +13)
    | diff >= 7 && diff <= 13 =
        case localeNextWeekday loc of
            Just template ->
                let dow = weekday dy dm dd
                    wdName = rlWeekdays resolved !! dow
                in replace "{weekday}" wdName template
            Nothing -> formatAbsolute resolved dy dm dd (dy /= ay)
    -- Calendar fallback
    | otherwise = formatAbsolute resolved dy dm dd (dy /= ay)

formatAbsolute :: ResolvedLocale -> Int -> Int -> Int -> Bool -> String
formatAbsolute resolved _year month day includeYear =
    let dayStr = show day
        fmt = case lookupAssoc dayStr (rlDayFormatExceptions resolved) of
            Just f  -> f
            Nothing -> rlDayFormat resolved
        formattedDay = replace "{n}" dayStr fmt
        monthsList = case rlMonthsInDate resolved of
            Just mid -> mid
            Nothing  -> rlMonths resolved
        monthName = monthsList !! (month - 1)
        pattern' = if includeYear
                   then rlDatePatternWithYear resolved
                   else rlDatePattern resolved
        result = replace "{day}" formattedDay
               $ replace "{month}" monthName
               $ replace "{d}" (show day)
               $ replace "{m}" (show month) pattern'
    in if includeYear
       then let yy = _year `mod` 100
            in replace "{yy}" (padLeft 2 '0' (show yy))
               $ replace "{year}" (show _year) result
       else result

-- Date parsing and arithmetic (zero-dependency)

parseDate :: String -> Maybe (Int, Int, Int)
parseDate s
    | null s    = Nothing
    | otherwise =
        let datePart = case indexOf 'T' s of
                i | i >= 0 -> take i s
                _          -> s
        in case splitOn '-' datePart of
            [ys, ms, ds] -> do
                y <- safeAtoi ys
                m <- safeAtoi ms
                d <- safeAtoi ds
                if m < 1 || m > 12 || d < 1 || d > 31
                    then Nothing
                    else Just (y, m, d)
            _ -> Nothing

toJdn :: Int -> Int -> Int -> Int
toJdn year month day =
    let a = (14 - month) `div` 12
        y = year + 4800 - a
        m = month + 12 * a - 3
    in day + (153 * m + 2) `div` 5 + 365 * y + y `div` 4 - y `div` 100 + y `div` 400 - 32045

weekday :: Int -> Int -> Int -> Int
weekday year month day = (toJdn year month day + 1) `mod` 7

-- String helpers

replace :: String -> String -> String -> String
replace _ _ [] = []
replace needle replacement haystack@(c:rest)
    | take nLen haystack == needle = replacement ++ replace needle replacement (drop nLen haystack)
    | otherwise = c : replace needle replacement rest
  where
    nLen = length needle

indexOf :: Char -> String -> Int
indexOf _ [] = -1
indexOf c (x:xs)
    | c == x    = 0
    | otherwise = let r = indexOf c xs
                  in if r < 0 then -1 else 1 + r

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

lookupAssoc :: String -> [(String, String)] -> Maybe String
lookupAssoc _ [] = Nothing
lookupAssoc key ((k,v):rest)
    | key == k  = Just v
    | otherwise = lookupAssoc key rest

padLeft :: Int -> Char -> String -> String
padLeft n c s = replicate (max 0 (n - length s)) c ++ s
