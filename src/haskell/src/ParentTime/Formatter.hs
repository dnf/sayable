module ParentTime.Formatter
    ( formatAgePure
    , formatStagePure
    , formatAge
    , formatStage
    ) where

import ParentTime.Internal (computeAge, today)
import ParentTime.Types

maxAgeMonths :: Int
maxAgeMonths = 6000

resolveUnit :: Int -> UnitForms -> Locale -> String -> String
resolveUnit count uf loc half =
    let baseN = show count
        n = if not (null half) && "{n}" `isInfixOf'` half
            then replace "{n}" baseN half
            else baseN
        template = case uf of
            Simple s -> s
            Pluralized forms -> lookupUnitForm (localePlural loc count) forms
        result = replace "{n}" n template
    in if not (null half) && "{0}" `isInfixOf'` half
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

stageKey :: Int -> String
stageKey months
    | months < 2   = "newborn"
    | months < 12  = "infant"
    | months < 36  = "toddler"
    | months < 156 = "child"
    | months < 216 = "teenager"
    | otherwise    = "adult"

resolveLocale :: Locale -> Compactness -> (UnitForms, UnitForms, UnitForms, UnitForms, String, String, String)
resolveLocale loc compactness =
    let mOvr = case compactness of
            Normal  -> Nothing
            Short   -> localeShort loc
            Compact -> localeCompact loc
        applyOvr ovr = ( maybe (localeDay loc) id (ovrDay ovr)
                       , maybe (localeWeek loc) id (ovrWeek ovr)
                       , maybe (localeMonth loc) id (ovrMonth ovr)
                       , maybe (localeYear loc) id (ovrYear ovr)
                       , maybe (localeHalf loc) id (ovrHalf ovr)
                       , maybe (localeDelimiter loc) id (ovrDelimiter ovr)
                       , maybe (localeJustBorn loc) id (ovrJustBorn ovr)
                       )
    in case mOvr of
        Nothing  -> (localeDay loc, localeWeek loc, localeMonth loc, localeYear loc, localeHalf loc, localeDelimiter loc, localeJustBorn loc)
        Just ovr -> applyOvr ovr

formatAgePure :: Locale -> Compactness -> String -> String -> Maybe String
formatAgePure loc compactness dob asOf
    | null dob  = Nothing
    | otherwise = do
        (months, diffDays) <- computeAge dob asOf
        if months > maxAgeMonths then Nothing
        else let (day', week', month', year', half', delim, justBorn) = resolveLocale loc compactness
             in Just (formatTier loc day' week' month' year' half' delim justBorn months diffDays)

formatTier :: Locale -> UnitForms -> UnitForms -> UnitForms -> UnitForms -> String -> String -> String -> Int -> Int -> String
formatTier loc day' week' month' year' half' delim justBorn months diffDays
    -- Tier 1: 0 days
    | diffDays == 0 = justBorn
    -- Tier 1b: 1-6 days
    | diffDays < 7 = resolveUnit diffDays day' loc ""
    -- Tier 2: weeks + days until 3 calendar months
    | months < 3 =
        let weeks = diffDays `div` 7
            days  = diffDays `mod` 7
            wStr  = resolveUnit weeks week' loc ""
        in if days > 0
           then wStr ++ delim ++ resolveUnit days day' loc ""
           else wStr
    -- Tier 3: 3-23 months
    | months < 24 = resolveUnit months month' loc ""
    -- Tier 4: 24-35 months -> years + months
    | months < 36 =
        let years = months `div` 12
            rem'  = months `mod` 12
            yStr  = resolveUnit years year' loc ""
        in if rem' == 0
           then yStr
           else yStr ++ delim ++ resolveUnit rem' month' loc ""
    -- Tier 5: 3-6 years -> years with half marker
    | months < 84 =
        let years = months `div` 12
            rem'  = months `mod` 12
        in if rem' >= 6
           then resolveUnit years year' loc half'
           else resolveUnit years year' loc ""
    -- Tier 6: 7+ years
    | otherwise =
        let years = months `div` 12
        in resolveUnit years year' loc ""

formatStagePure :: Locale -> String -> String -> Maybe Gender -> Maybe String
formatStagePure loc dob asOf gender
    | null dob  = Nothing
    | otherwise = do
        (months, _) <- computeAge dob asOf
        let stages' = localeStages loc
            label = case stageKey months of
                "newborn"  -> stageNewborn stages'
                "infant"   -> stageInfant stages'
                "toddler"  -> stageToddler stages'
                "child"    -> stageChild stages'
                "teenager" -> stageTeenager stages'
                "adult"    -> stageAdult stages'
                _          -> stageNewborn stages'
        Just (resolveStageLabel label gender)

showDate :: Int -> Int -> Int -> String
showDate y m d =
    let pad2 n = if n < 10 then '0' : show n else show n
        pad4 n = let s = show n in replicate (4 - length s) '0' ++ s
    in pad4 y ++ "-" ++ pad2 m ++ "-" ++ pad2 d

formatAge :: Locale -> Compactness -> String -> Maybe String -> IO (Maybe String)
formatAge loc compactness dob mAsOf = do
    asOf <- case mAsOf of
        Just s | not (null s) -> return s
        _ -> do
            (y, m, d) <- today
            return (showDate y m d)
    return (formatAgePure loc compactness dob asOf)

formatStage :: Locale -> String -> Maybe String -> Maybe Gender -> IO (Maybe String)
formatStage loc dob mAsOf gender = do
    asOf <- case mAsOf of
        Just s | not (null s) -> return s
        _ -> do
            (y, m, d) <- today
            return (showDate y m d)
    return (formatStagePure loc dob asOf gender)
