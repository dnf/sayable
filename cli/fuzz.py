#!/usr/bin/env python3
"""Cross-language fuzz tester for the sayable CLIs.

Generates random formatting requests (random command, locale, dates,
compactness, gender), sends the same batch to every implementation's
`sayable --repl` (see cli/SPEC.md), and reports every request on which
the implementations disagree. All implementations must produce identical
output, so any disagreement is a bug in at least one of them.

Answers are checked against a reference implementation (default:
python, whose CLI runs from source anywhere python3 does), so a single
language can be fuzzed on its own, e.g. in that language's CI job. The
reference is added to any --langs selection. With --reference none, the
implementations are compared only with each other (the majority answer
is shown as a hint), which needs at least two of them.

A language that answers a component probe with exit 2 does not
implement that component and is left out of the comparison for it.

Usage:
    python3 cli/fuzz.py                       # every CLI vs python, 2000 requests
    python3 cli/fuzz.py --langs go            # just Go, vs python
    python3 cli/fuzz.py --langs go,rust,zig   # a subset, vs python
    python3 cli/fuzz.py --reference none      # every CLI vs each other
    python3 cli/fuzz.py -n 10000 --seed 42    # reproducible run
    python3 cli/fuzz.py --report fuzz.json    # full details as JSON

Exit status: 0 when every implementation agrees, 1 on any disagreement
or failed CLI, 2 on usage errors.
"""

from __future__ import annotations

import argparse
import calendar
import datetime as dt
import json
import random
import subprocess
import sys
import time
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CLI_DIR = ROOT / "cli" / "impl"
COMPONENT_OF = {
    "age": "age", "stage": "age",
    "date": "date", "relative": "date",
    "time": "time",
    "duration": "duration", "since": "duration", "until": "duration",
}
COMPONENTS = ("age", "date", "time", "duration")
DEFAULT_REFERENCE = "python"
INVALID_VALUES = ["null", "", "2025-13-01", "2025-02-30", "0000-00-00", "abcd", "2025-6-1", "99:99"]


def locale_codes() -> list[str]:
    return sorted(p.stem for p in (ROOT / "age" / "locales" / "src").glob("*.json"))


def discover_clis() -> dict[str, Path]:
    return {d.name: d / "sayable" for d in sorted(CLI_DIR.iterdir())
            if (d / "sayable").is_file() and (d / "sayable").stat().st_mode & 0o111}


class RequestGenerator:
    """Random requests, biased toward the boundaries where bugs hide."""

    def __init__(self, rng: random.Random, locales: list[str], invalid_rate: float):
        self.rng = rng
        self.locales = locales
        self.invalid_rate = invalid_rate

    def date(self, lo: dt.date, hi: dt.date) -> dt.date:
        return lo + dt.timedelta(days=self.rng.randint(0, (hi - lo).days))

    def month_end_or_leap(self) -> dt.date:
        """The 1st or the 28th-31st of a month, often in a leap or century year."""
        year = self.rng.choice([1900, 2000, 2020, 2023, 2024, 2025, self.rng.randint(1600, 2030)])
        month = self.rng.randint(1, 12)
        last_day = calendar.monthrange(year, month)[1]
        return dt.date(year, month, self.rng.choice([1, last_day] + [min(d, last_day) for d in (28, 29, 30, 31)]))

    def as_of(self) -> dt.date:
        return self.date(dt.date(1990, 1, 1), dt.date(2035, 12, 31))

    def dob_for(self, ref: dt.date) -> dt.date:
        """A birth date at an interesting distance before (or just after) ref."""
        span_days = self.rng.choice([0, 1, 6, 7, 13, 14, 30, 60, 89, 90, 91, 92, 365, 730, 1095,
                                     1277, 1278, 2555, 2556, 4745, 6570, 182_500, 182_620, 183_000])
        jitter = self.rng.randint(-3, 3)
        if self.rng.random() < 0.3:
            span_days = self.rng.randint(0, 80 * 365)
        try:
            return ref - dt.timedelta(days=max(span_days + jitter, -5))
        except OverflowError:
            return ref

    def maybe_invalid(self, value: str) -> str:
        return self.rng.choice(INVALID_VALUES) if self.rng.random() < self.invalid_rate else value

    def common_options(self) -> list[str]:
        args = []
        if self.rng.random() < 0.95:
            args += ["-l", self.rng.choice(self.locales)]
        args += self.rng.choice([[], [], ["--short"], ["--compact"]])
        return args

    def timestamp(self, base: dt.datetime) -> str:
        return base.strftime("%Y-%m-%dT%H:%M:%S")

    def request(self) -> list[str]:
        command = self.rng.choices(
            ["age", "stage", "date", "relative", "time", "duration", "since", "until"],
            weights=[30, 15, 10, 10, 10, 10, 7, 8])[0]
        if command in ("age", "stage"):
            ref = self.month_end_or_leap() if self.rng.random() < 0.2 else self.as_of()
            dob = self.month_end_or_leap() if self.rng.random() < 0.15 else self.dob_for(ref)
            args = [command, self.maybe_invalid(dob.isoformat()), "-d", ref.isoformat()]
            if command == "stage" and self.rng.random() < 0.6:
                args += ["-g", self.rng.choice(["m", "f"])]
        elif command == "date":
            args = ["date", self.maybe_invalid(self.as_of().isoformat())]
            if self.rng.random() < 0.4:
                args.append("--with-year")
        elif command == "relative":
            ref = self.as_of()
            target = ref + dt.timedelta(days=self.rng.choice([0, 1, -1, 2, -2, 6, -6, 7, -7,
                                                              self.rng.randint(-400, 400)]))
            args = ["relative", self.maybe_invalid(target.isoformat()), "-d", ref.isoformat()]
        elif command == "time":
            value = f"{self.rng.randint(0, 23):02d}:{self.rng.choice([0, 1, 14, 15, 29, 30, 31, 44, 45, 59, self.rng.randint(0, 59)]):02d}"
            args = ["time", self.maybe_invalid(value)]
        elif command == "duration":
            if self.rng.random() < 0.6:
                seconds = self.rng.choice([0, 1, 59, 60, 61, 89, 90, 3599, 3600, 5400, 86399, 86400,
                                           604800, self.rng.randint(0, 10**8)])
                args = ["duration", self.maybe_invalid(str(seconds))]
            else:
                start = dt.datetime(2025, 1, 15, 10, 0, 0) + dt.timedelta(seconds=self.rng.randint(0, 10**7))
                end = start + dt.timedelta(seconds=self.rng.randint(0, 10**7))
                args = ["duration", self.timestamp(start), self.timestamp(end)]
        else:  # since / until
            ref = dt.datetime(2025, 1, 15, 10, 0, 0) + dt.timedelta(seconds=self.rng.randint(0, 10**7))
            delta = dt.timedelta(seconds=self.rng.choice([0, 1, 30, 59, 60, 90, 3600, 5400, 86400,
                                                          self.rng.randint(0, 10**7)]))
            other = ref - delta if command == "since" else ref + delta
            args = [command, self.maybe_invalid(self.timestamp(other)), "-d", self.timestamp(ref)]
        return args + self.common_options()


def run_repl(cli: Path, requests: list[list[str]], timeout: float) -> tuple[list[str] | None, str]:
    """Send every request to one REPL process; returns (responses, error)."""
    payload = "".join("\t".join(r) + "\n" for r in requests).encode("utf-8")
    try:
        proc = subprocess.run([str(cli), "--repl"], input=payload, capture_output=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, f"timed out after {timeout:.0f}s"
    except OSError as exc:
        return None, str(exc)
    lines = proc.stdout.decode("utf-8", errors="replace").split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    if len(lines) != len(requests):
        stderr_tail = proc.stderr.decode("utf-8", errors="replace").strip().splitlines()[-3:]
        return None, f"answered {len(lines)} of {len(requests)} requests (exit {proc.returncode}) {' | '.join(stderr_tail)}"
    return lines, ""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-n", "--requests", type=int, default=2000, help="number of random requests (default 2000)")
    parser.add_argument("--seed", type=int, help="random seed (default: random, printed for reproduction)")
    parser.add_argument("--langs", help="comma-separated languages to compare (default: every CLI with a sayable executable)")
    parser.add_argument("--invalid-rate", type=float, default=0.05, help="fraction of malformed inputs (default 0.05)")
    parser.add_argument("--timeout", type=float, default=600, help="seconds allowed per language (default 600)")
    parser.add_argument("--show", type=int, default=20, help="disagreements to print (default 20)")
    parser.add_argument("--report", type=Path, help="write all disagreements as JSON to this file")
    parser.add_argument("--reference", default=DEFAULT_REFERENCE,
                        help=f"implementation whose answers are expected (default {DEFAULT_REFERENCE}); 'none' to compare by consensus")
    args = parser.parse_args()
    reference = None if args.reference == "none" else args.reference

    clis = discover_clis()
    wanted = [lang.strip() for lang in args.langs.split(",") if lang.strip()] if args.langs else list(clis)
    if reference and reference not in wanted:
        wanted.append(reference)
    missing = [lang for lang in wanted if lang not in clis]
    if missing:
        print(f"error: no runnable CLI for: {', '.join(missing)} (expected cli/impl/<lang>/sayable)", file=sys.stderr)
        return 2
    clis = {lang: clis[lang] for lang in wanted}
    if len(clis) < 2:
        print("error: need at least two CLIs to compare (pick a --reference, or more --langs)", file=sys.stderr)
        return 2

    seed = args.seed if args.seed is not None else random.randrange(2**32)
    gen = RequestGenerator(random.Random(seed), locale_codes(), args.invalid_rate)
    probes = [[component, "null"] for component in COMPONENTS]
    requests = probes + [gen.request() for _ in range(args.requests)]
    against = f"against {reference}" if reference else "by consensus"
    print(f"Fuzzing {', '.join(lang for lang in clis if lang != reference)} {against} "
          f"with {args.requests} requests (seed {seed})")

    started = time.monotonic()
    with ThreadPoolExecutor(max_workers=min(16, len(clis))) as pool:
        results = dict(zip(clis, pool.map(lambda c: run_repl(c, requests, args.timeout), clis.values())))
    elapsed = time.monotonic() - started

    failed = {lang: err for lang, (resp, err) in results.items() if resp is None}
    answers = {lang: resp for lang, (resp, _) in results.items() if resp is not None}
    supports = {lang: {c for c, resp in zip(COMPONENTS, answers[lang][:len(probes)]) if not resp.startswith("2\t")}
                for lang in answers}
    for lang, err in sorted(failed.items()):
        print(f"CLI FAILED {lang}: {err}")
    if reference in failed:
        print(f"error: the reference implementation ({reference}) failed; nothing to compare against", file=sys.stderr)
        return 1

    disagreements = []
    reference_outvoted = 0
    compared = 0
    for i, request in enumerate(requests[len(probes):], start=len(probes)):
        component = COMPONENT_OF[request[0]]
        voters = {lang: answers[lang][i] for lang in answers if component in supports[lang]}
        if len(voters) < 2:
            continue
        compared += 1
        tally = Counter(voters.values())
        if len(tally) == 1:
            continue
        majority = tally.most_common(1)[0][0]
        expected = voters.get(reference, majority)
        if reference in voters and expected != majority and len(voters) > 2:
            reference_outvoted += 1
        groups = {}
        for lang, response in voters.items():
            groups.setdefault(response, []).append(lang)
        disagreements.append({"request": request, "expected": expected, "majority": majority, "groups": groups})

    for d in disagreements[:args.show]:
        print(f"\nDISAGREE  sayable {' '.join(repr(a) if a == '' or ' ' in a else a for a in d['request'])}")
        for response, langs in sorted(d["groups"].items(), key=lambda kv: (response != d["expected"], -len(kv[1]))):
            marker = "expected" if response == d["expected"] else "        "
            print(f"  {marker} {response!r:45} {', '.join(sorted(langs))}")

    blame = Counter(lang for d in disagreements for resp, langs in d["groups"].items()
                    if resp != d["expected"] for lang in langs)
    print(f"\n{compared} requests compared across {len(answers)} languages {against} in {elapsed:.1f}s; "
          f"{len(disagreements)} disagreements; {len(failed)} CLIs failed")
    if blame:
        print(f"Languages that disagree with {reference or 'the majority'}: "
              + ", ".join(f"{lang} ({n})" for lang, n in blame.most_common()))
    if reference_outvoted:
        print(f"note: in {reference_outvoted} of those, {reference} itself is outside the majority "
              "and may be the implementation that's wrong")
    if args.report:
        args.report.write_text(json.dumps({"seed": seed, "requests": args.requests, "reference": reference,
                                           "failed": failed, "disagreements": disagreements},
                                          ensure_ascii=False, indent=2))
        print(f"Report written to {args.report}")
    if disagreements or failed:
        print(f"Reproduce with: python3 cli/fuzz.py -n {args.requests} --seed {seed}"
              + (f" --langs {args.langs}" if args.langs else "")
              + (f" --reference {args.reference}" if args.reference != DEFAULT_REFERENCE else ""))
    return 1 if disagreements or failed else 0


if __name__ == "__main__":
    sys.exit(main())
