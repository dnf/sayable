module SayableTime.Formatter
    ( formatTime
    , version
    ) where

import SayableTime.Types

version :: String
version = "0.1.0"

formatTime :: TimeLocale -> Compactness -> Maybe String -> Maybe String
formatTime _ _ Nothing = Nothing
formatTime loc compactness (Just input)
    | null input = Nothing
    | otherwise =
        case parseTime input of
            Nothing -> Nothing
            Just (hour, minute) ->
                let mOvr = case compactness of
                        Normal  -> Nothing
                        Short   -> localeShort loc
                        Compact -> localeCompact loc
                    mShortClock = mOvr >>= ovrClock
                in case mShortClock of
                    Just sc -> Just (formatDigital sc hour minute)
                    Nothing -> Just (formatNatural (localeClock loc) hour minute)

formatNatural :: ClockConfig -> Int -> Int -> String
formatNatural clock hour minute =
    let rounded = roundTo5 minute
        (rounded', h) = if rounded == 60
                        then (0, (hour + 1) `mod` 24)
                        else (rounded, hour)
    in if rounded' == 0
       then if h == 0 then clockMidnight clock
            else if h == 12 then clockNoon clock
            else lookupPattern clock h rounded'
       else lookupPattern clock h rounded'

lookupPattern :: ClockConfig -> Int -> Int -> String
lookupPattern clock h rounded =
    let h12 = h `mod` 12
        nextH12 = (h + 1) `mod` 12
        hours = clockHours clock
        hName = hours !! h12
        nextHName = hours !! nextH12
        pattern' = case lookup rounded (clockPatterns clock) of
            Just p  -> p
            Nothing -> case lookup 0 (clockPatterns clock) of
                Just p  -> p
                Nothing -> "{h}"
    in replace "{next_h}" nextHName (replace "{h}" hName pattern')

formatDigital :: ShortClockConfig -> Int -> Int -> String
formatDigital sc hour minute =
    let fmt = shortFormat sc
    in if shortUse24h sc
       then replace "{mm}" (padLeft 2 '0' (show minute))
            (replace "{h}" (show hour) fmt)
       else let h12 = let r = hour `mod` 12 in if r == 0 then 12 else r
                (am, pm) = case shortAmPm sc of
                    Just pair -> pair
                    Nothing   -> ("AM", "PM")
                ampmStr = if hour < 12 then am else pm
            in replace "{ampm}" ampmStr
               (replace "{mm}" (padLeft 2 '0' (show minute))
               (replace "{h}" (show h12) fmt))

roundTo5 :: Int -> Int
roundTo5 m = ((m + 2) `div` 5) * 5

parseTime :: String -> Maybe (Int, Int)
parseTime input
    | null input = Nothing
    | otherwise =
        let t = case indexOf 'T' input of
                    i | i >= 0 -> drop (i + 1) input
                    _          -> input
            t' = stripTz t
        in case splitOn ':' t' of
            (hs:ms:_) -> do
                h <- safeAtoi hs
                m <- safeAtoi ms
                if h < 0 || h > 23 || m < 0 || m > 59
                    then Nothing
                    else Just (h, m)
            _ -> Nothing

-- String helpers (zero-dependency)

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

stripTz :: String -> String
stripTz [] = []
stripTz (c:rest)
    | c == '+' || c == 'Z' = []
    | otherwise = c : stripTz rest

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

padLeft :: Int -> Char -> String -> String
padLeft n c s = replicate (max 0 (n - length s)) c ++ s
