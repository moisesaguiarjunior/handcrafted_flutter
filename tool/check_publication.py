#!/usr/bin/env python3
"""Validate the actual pub payload in a disposable source snapshot, without upload."""

from pathlib import Path
import shutil
import subprocess
import tempfile


def snapshot_source(repo: Path, destination: Path) -> None:
    """Copy source (including new files) without Git/build caches or local notes."""
    names = subprocess.check_output(
        ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
        cwd=repo,
    ).decode().split("\0")
    for name in set(names) - {""}:
        source = repo / name
        if name.endswith(".local.md") or not (source.exists() or source.is_symlink()):
            continue
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target, follow_symlinks=False)


def command(arguments: list[str], directory: Path) -> str:
    result = subprocess.run(
        arguments, cwd=directory, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, check=False,
    )
    print(result.stdout, end="", flush=True)
    if result.returncode:
        raise RuntimeError(f"{' '.join(arguments)} failed ({result.returncode})")
    return result.stdout


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="handcrafted-publication-") as temporary:
        directory = Path(temporary)
        snapshot_source(repo, directory)
        # Synthetic data only: real local checkpoint content is never copied.
        probes = [
            "WORKTREE.local.md",
            "example/publication-probe.local.md",
            "example/tool/generated-capture-publication-probe.txt",
            "build/generated-publication-probe.txt",
            "coverage/generated-coverage-probe.info",
        ]
        for name in probes:
            target = directory / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("Synthetic archive exclusion probe.\n")
        output = command(["dart", "pub", "publish", "--dry-run"], directory)
        for name in probes:
            if Path(name).name in output:
                raise RuntimeError(f"Excluded probe entered the pub payload: {name}")
        if "Package has 0 warnings." not in output:
            raise RuntimeError("Publication validation did not report zero warnings")
        output = command(["dart", "doc", "--dry-run"], directory)
        if "Found 0 warnings and 0 errors." not in output:
            raise RuntimeError("API documentation validation did not report zero issues")
    print("Publication checks passed; local/generated probes excluded; no upload performed.")


if __name__ == "__main__":
    main()
