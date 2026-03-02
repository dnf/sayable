module ParentTime.Internal
    ( parseDate
    , isLeapYear
    , daysInMonth
    , daysBetween
    , computeAge
    , today
    ) where

import Data.Char (isDigit)
import Foreign.C.Types (CTime(..))
import Foreign.Ptr (Ptr, nullPtr)

foreign import ccall unsafe "time" c_time :: Ptr CTime -> IO CTime

parseDate :: String -> Maybe (Int, Int, Int)
parseDate s
    | length s < 10          = Nothing
    | s !! 4 /= '-'          = Nothing
    | s !! 7 /= '-'          = Nothing
    | not (all isDigit yStr) = Nothing
    | not (all isDigit mStr) = Nothing
    | not (all isDigit dStr) = Nothing
    | y == 0 && m == 0 && d == 0 = Nothing
    | otherwise              = Just (y, m, d)
  where
    yStr = take 4 s
    mStr = take 2 (drop 5 s)
    dStr = take 2 (drop 8 s)
    y = read yStr :: Int
    m = read mStr :: Int
    d = read dStr :: Int

isLeapYear :: Int -> Bool
isLeapYear y = (y `mod` 4 == 0 && y `mod` 100 /= 0) || y `mod` 400 == 0

daysInMonth :: Int -> Int -> Int
daysInMonth y m = case m of
    1  -> 31; 3 -> 31; 5  -> 31; 7  -> 31
    8  -> 31; 10 -> 31; 12 -> 31
    4  -> 30; 6 -> 30; 9  -> 30; 11 -> 30
    2  -> if isLeapYear y then 29 else 28
    _  -> 30

toJDN :: Int -> Int -> Int -> Int
toJDN y m d =
    let a  = (14 - m) `div` 12
        yy = y + 4800 - a
        mm = m + 12 * a - 3
    in d + (153 * mm + 2) `div` 5 + 365 * yy + yy `div` 4 - yy `div` 100 + yy `div` 400 - 32045

daysBetween :: (Int, Int, Int) -> (Int, Int, Int) -> Int
daysBetween (y1, m1, d1) (y2, m2, d2) = toJDN y2 m2 d2 - toJDN y1 m1 d1

-- | Returns (months, diffDays) or Nothing if invalid/future.
computeAge :: String -> String -> Maybe (Int, Int)
computeAge dob asOf = do
    (dy, dm, dd) <- parseDate dob
    (ry, rm, rd) <- parseDate asOf
    let diffDays = daysBetween (dy, dm, dd) (ry, rm, rd)
    if diffDays < 0
        then Nothing
        else let lastDay = daysInMonth ry rm
                 clampedBirthday = min dd lastDay
                 months0 = (ry - dy) * 12 + (rm - dm)
                 months = if rd < clampedBirthday then months0 - 1 else months0
             in if months > 6000
                    then Nothing
                    else Just (months, diffDays)

-- | Get today's date using Hinnant's civil_from_days algorithm.
today :: IO (Int, Int, Int)
today = do
    CTime secs <- c_time nullPtr
    let days = fromIntegral secs `div` 86400 :: Int
        z = days + 719468
        era = (if z >= 0 then z else z - 146096) `div` 146097
        doe = z - era * 146097
        yoe = (doe - doe `div` 1460 + doe `div` 36524 - doe `div` 146096) `div` 365
        y0 = yoe + era * 400
        doy = doe - (365 * yoe + yoe `div` 4 - yoe `div` 100)
        mp = (5 * doy + 2) `div` 153
        d = doy - (153 * mp + 2) `div` 5 + 1
        m = if mp < 10 then mp + 3 else mp - 9
        y = if m <= 2 then y0 + 1 else y0
    return (y, m, d)
