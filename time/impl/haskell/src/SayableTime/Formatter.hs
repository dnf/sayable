module SayableTime.Formatter
    ( formatTime
    , version
    ) where

import Control.Monad (guard)
import Data.Char (isDigit)
import SayableTime.Types

version :: String
version = "0.5.0"

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

-- | A clock time alone, or after the T of an ISO datetime whose date part
-- is a real calendar day.
parseTime :: String -> Maybe (Int, Int)
parseTime input = case break (== 'T') input of
    (clock, []) -> parseClock clock
    (date, _ : clock) -> do
        guard (isRealDate date)
        parseClock clock

-- | H:MM or HH:MM, then optional :SS with optional .fraction, then an
-- optional zone suffix (validated, never applied).
parseClock :: String -> Maybe (Int, Int)
parseClock s = do
    let (hs, afterHour) = span isDigit s
    guard (length hs == 1 || length hs == 2)
    ':' : m1 : m2 : afterMinute <- Just afterHour
    guard (isDigit m1 && isDigit m2)
    let (second, zone) = case afterMinute of
            ':' : s1 : s2 : rest | isDigit s1 && isDigit s2 -> (digitsValue [s1, s2], dropFraction rest)
            rest -> (0, rest)
        hour = digitsValue hs
        minute = digitsValue [m1, m2]
    guard (null zone || isZoneSuffix zone)
    guard (hour <= 23 && minute <= 59 && second <= 59)
    Just (hour, minute)
  where
    dropFraction ('.' : d : rest) | isDigit d = dropWhile isDigit rest
    dropFraction rest = rest

isZoneSuffix :: String -> Bool
isZoneSuffix "Z" = True
isZoneSuffix [sign, h1, h2, ':', m1, m2] = sign `elem` "+-" && all isDigit [h1, h2, m1, m2]
isZoneSuffix _ = False

-- | YYYY-MM-DD naming a real calendar day.
isRealDate :: String -> Bool
isRealDate [y1, y2, y3, y4, '-', m1, m2, '-', d1, d2]
    | all isDigit [y1, y2, y3, y4, m1, m2, d1, d2] =
        let y = digitsValue [y1, y2, y3, y4]
            m = digitsValue [m1, m2]
            d = digitsValue [d1, d2]
        in m >= 1 && m <= 12 && d >= 1 && d <= daysInMonth y m
isRealDate _ = False

daysInMonth :: Int -> Int -> Int
daysInMonth y m
    | m == 2 = if isLeap then 29 else 28
    | m `elem` [4, 6, 9, 11] = 30
    | otherwise = 31
  where
    isLeap = (y `mod` 4 == 0 && y `mod` 100 /= 0) || y `mod` 400 == 0

-- | The value of a string of ASCII digits.
digitsValue :: String -> Int
digitsValue = foldl (\n c -> n * 10 + fromEnum c - fromEnum '0') 0

-- String helpers (zero-dependency)

replace :: String -> String -> String -> String
replace _ _ [] = []
replace needle replacement haystack@(c:rest)
    | take nLen haystack == needle = replacement ++ replace needle replacement (drop nLen haystack)
    | otherwise = c : replace needle replacement rest
  where
    nLen = length needle

padLeft :: Int -> Char -> String -> String
padLeft n c s = replicate (max 0 (n - length s)) c ++ s
