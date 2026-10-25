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
    | diff == 2 && not isCompact, Just s <- localeDayAfterTomorrow loc = s
    -- Day before yesterday (optional, skipped in compact mode)
    | diff == -2 && not isCompact, Just s <- localeDayBeforeYesterday loc = s
    -- Compact mode: skip weekday references, go straight to calendar date
    | isCompact = calendarDate
    -- This weekday (+2 to +6)
    | diff >= 2 && diff <= 6, Just template <- localeThisWeekday loc = withWeekday template
    -- Last weekday (-6 to -2)
    | diff >= -6 && diff <= -2, Just template <- localeLastWeekday loc = withWeekday template
    -- Next weekday (+7 to +13)
    | diff >= 7 && diff <= 13, Just template <- localeNextWeekday loc = withWeekday template
    -- Calendar fallback
    | otherwise = calendarDate
  where
    calendarDate = formatAbsolute resolved dy dm dd (dy /= ay)
    withWeekday = replace "{weekday}" (rlWeekdays resolved !! weekday dy dm dd)

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

-- | YYYY-MM-DD naming a real calendar day, optionally followed by T and a
-- time (only the date part is read).
parseDate :: String -> Maybe (Int, Int, Int)
parseDate s = case splitAt 10 s of
    ([y1, y2, y3, y4, '-', m1, m2, '-', d1, d2], rest)
        | null rest || take 1 rest == "T" -> do
            y <- safeAtoi [y1, y2, y3, y4]
            m <- safeAtoi [m1, m2]
            d <- safeAtoi [d1, d2]
            if m < 1 || m > 12 || d < 1 || d > daysInMonth y m
                then Nothing
                else Just (y, m, d)
    _ -> Nothing

daysInMonth :: Int -> Int -> Int
daysInMonth y m
    | m == 2 = if isLeap then 29 else 28
    | m `elem` [4, 6, 9, 11] = 30
    | otherwise = 31
  where
    isLeap = (y `mod` 4 == 0 && y `mod` 100 /= 0) || y `mod` 400 == 0

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
