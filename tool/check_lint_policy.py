#!/usr/bin/env python3
"""Prove the preset and inherited rules reject synthetic violations in each scope."""

from pathlib import Path
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
from check_publication import command, snapshot_source


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="handcrafted-lint-policy-") as temporary:
        directory = Path(temporary)
        snapshot_source(repo, directory)
        command(["flutter", "pub", "get", "--enforce-lockfile"], directory)
        contexts = {
            "lib/lint_guard_probe.dart": [
                "avoid_print", "curly_braces_in_flow_control_structures",
                "avoid_dynamic_calls", "invalid_assignment",
                "public_member_api_docs",
            ],
            "example/lib/lint_guard_probe.dart": [
                "avoid_print", "curly_braces_in_flow_control_structures",
                "avoid_dynamic_calls", "invalid_assignment",
                "public_member_api_docs",
            ],
            # API docs apply to library entrypoints, not standalone CLI scripts.
            "tool/lint_guard_probe.dart": [
                "avoid_print", "curly_braces_in_flow_control_structures",
                "avoid_dynamic_calls", "invalid_assignment",
            ],
        }
        for name in contexts:
            probe = directory / name
            if probe.exists():
                raise RuntimeError(f"Synthetic probe collides with source: {name}")
            probe.write_text(
                "void lintGuardProbe(bool enabled, dynamic receiver) {\n"
                "  if (enabled)\n"
                "    print('Synthetic lint guard');\n"
                "  final int typed = receiver;\n"
                "  receiver.invokeSyntheticGuard(typed);\n"
                "}\n"
            )
        result = subprocess.run(
            ["flutter", "analyze", "--fatal-infos"], cwd=directory,
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            check=False,
        )
        if result.returncode == 0:
            raise RuntimeError("Analyzer accepted synthetic lint violations")
        for name, rules in contexts.items():
            diagnostics = [
                line for line in result.stdout.splitlines()
                if f" • {name}:" in line
            ]
            for rule in rules:
                if not any(line.rstrip().endswith(f" • {rule}") for line in diagnostics):
                    raise RuntimeError(f"Missing {rule} guard in {name}")
    print("Lint policy guards passed in library, example and tools; source unchanged.")


if __name__ == "__main__":
    main()
