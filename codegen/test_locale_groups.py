"""Tests for locale subsetting (locale_groups + generate --locales)."""

from __future__ import annotations

import os
import subprocess
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class TestResolveLocales(unittest.TestCase):
    """Unit tests for locale_groups.resolve_locales."""

    def setUp(self):
        from codegen.locale_groups import GROUPS
        from codegen.generate import load_locales

        self.all_codes = {loc["code"] for loc in load_locales()}
        self.groups = GROUPS

    def test_single_group(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("core", self.all_codes)
        self.assertEqual(result, sorted(self.groups["core"]))

    def test_single_locale_code(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("fr", self.all_codes)
        self.assertEqual(result, ["en", "fr"])

    def test_en_always_included(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("ja", self.all_codes)
        self.assertIn("en", result)
        self.assertIn("ja", result)

    def test_combine_group_and_code(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("cjk,fr", self.all_codes)
        self.assertIn("zh", result)
        self.assertIn("ja", result)
        self.assertIn("ko", result)
        self.assertIn("fr", result)
        self.assertIn("en", result)

    def test_combine_two_groups(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("cjk,nordic", self.all_codes)
        for code in self.groups["cjk"]:
            self.assertIn(code, result)
        for code in self.groups["nordic"]:
            self.assertIn(code, result)
        self.assertIn("en", result)

    def test_duplicates_collapsed(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("core,en,ja", self.all_codes)
        self.assertEqual(len(result), len(set(result)))
        self.assertEqual(result, sorted(self.groups["core"]))

    def test_unknown_token_raises(self):
        from codegen.locale_groups import resolve_locales

        with self.assertRaises(ValueError) as ctx:
            resolve_locales("bogus", self.all_codes)
        self.assertIn("bogus", str(ctx.exception))

    def test_result_is_sorted(self):
        from codegen.locale_groups import resolve_locales

        result = resolve_locales("european", self.all_codes)
        self.assertEqual(result, sorted(result))

    def test_all_group_members_are_valid_locales(self):
        for name, members in self.groups.items():
            for code in members:
                self.assertIn(
                    code, self.all_codes,
                    f"Group '{name}' contains '{code}' which is not a valid locale",
                )


class TestListGroups(unittest.TestCase):
    """Test the list_groups() output."""

    def test_list_groups_output(self):
        from codegen.locale_groups import GROUPS, list_groups

        output = list_groups()
        for name in GROUPS:
            self.assertIn(name, output)
        self.assertIn("en", output)


class TestGenerateSubset(unittest.TestCase):
    """Integration tests: run codegen with --locales and verify output."""

    def _run_generate(self, *extra_args: str) -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, "-m", "codegen.generate", *extra_args],
            capture_output=True, text=True, cwd=ROOT,
        )

    def test_subset_then_check_passes(self):
        """Generate a subset, then --check on the same subset passes."""
        result = self._run_generate("--locales", "cjk", "--lang", "go")
        self.assertEqual(result.returncode, 0, result.stderr)

        result = self._run_generate("--locales", "cjk", "--lang", "go", "--check")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_per_file_cleanup(self):
        """Subsetting removes stale per-file locale files."""
        # Generate full set for Go
        self._run_generate("--lang", "go")
        go_dir = os.path.join(ROOT, "src", "go", "locales")
        full_count = len([f for f in os.listdir(go_dir) if f.startswith("locale_") and f.endswith(".go") and f != "locale_registry.go"])
        self.assertEqual(full_count, 71)

        # Generate subset
        self._run_generate("--locales", "cjk", "--lang", "go")
        subset_files = sorted(f for f in os.listdir(go_dir) if f.startswith("locale_") and f.endswith(".go") and f != "locale_registry.go")
        self.assertEqual(len(subset_files), 4)  # en, ja, ko, zh
        expected = ["locale_en.go", "locale_ja.go", "locale_ko.go", "locale_zh.go"]
        self.assertEqual(subset_files, expected)

    def test_monolithic_language_subset(self):
        """Kotlin (monolithic) only contains selected locales."""
        self._run_generate("--locales", "nordic", "--lang", "kotlin")
        kt_path = os.path.join(ROOT, "src", "kotlin", "src", "main", "kotlin", "parenttime", "locales", "Locales.kt")
        with open(kt_path) as f:
            content = f.read()

        # Nordic = da, fi, nb, sv; plus required en
        for code in ["EN", "DA", "FI", "NB", "SV"]:
            self.assertIn(f"val {code}: AgeLocale", content)

        # Should NOT contain non-selected locales
        for code in ["FR", "AR", "JA", "ZH"]:
            self.assertNotIn(f"val {code}: AgeLocale", content)

    def test_check_detects_stale_files(self):
        """--check mode flags stale files from a previous full generation."""
        # Generate full Go, then check with subset — should detect stale files
        self._run_generate("--lang", "go")
        result = self._run_generate("--locales", "cjk", "--lang", "go", "--check")
        self.assertEqual(result.returncode, 1)
        self.assertIn("out of date", result.stdout)

    def test_invalid_locale_exits_nonzero(self):
        result = self._run_generate("--locales", "nonexistent")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unknown locale or group", result.stderr)

    def test_list_groups_flag(self):
        result = self._run_generate("--list-groups")
        self.assertEqual(result.returncode, 0)
        self.assertIn("core", result.stdout)
        self.assertIn("european", result.stdout)

    def tearDown(self):
        """Restore full generation for all languages touched by tests."""
        self._run_generate("--lang", "go")
        self._run_generate("--lang", "kotlin")


if __name__ == "__main__":
    unittest.main()
