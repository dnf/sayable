"""parent-time: Human-friendly age formatting the way parents actually talk."""

from parent_time.format_age import ParentTime, format_age, format_stage
from parent_time.locale import EN, AgeLocale
from parent_time.locales import (
    AR, BN, DE, ES, FA, FR, GU, HI, IT, JA, JV, KO,
    MR, MS, PA, PT, RU, TA, TE, TH, TR, UR, VI, ZH,
)

__all__ = [
    "AgeLocale", "EN", "ParentTime", "format_age", "format_stage",
    "AR", "BN", "DE", "ES", "FA", "FR", "GU", "HI",
    "IT", "JA", "JV", "KO", "MR", "MS", "PA", "PT",
    "RU", "TA", "TE", "TH", "TR", "UR", "VI", "ZH",
]
