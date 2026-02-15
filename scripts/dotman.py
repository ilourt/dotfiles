#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


IGNORE_CONFIG_NAMES = {".DS_Store"}
ROOT_EXCLUDE = {
    ".git",
    ".lexical",
    "config",
    "conversations",
    "functions",
    "prompts",
    "scripts",
    "themes",
    "README.md",
    ".gitignore",
    ".DS_Store",
}


@dataclass
class Ctx:
    dotfiles_root: Path
    config_home: Path
    dry_run: bool
    force: bool
    backup: bool
    absolute: bool
    color: str


ANSI_RESET = "\033[0m"
ANSI_COLORS = {
    "green": "\033[32m",
    "yellow": "\033[33m",
    "cyan": "\033[36m",
    "bold": "\033[1m",
}


def default_dotfiles_root() -> Path:
    return Path.home() / ".dotfiles"


def default_config_home() -> Path:
    env = os.environ.get("XDG_CONFIG_HOME")
    if env:
        return Path(env).expanduser()
    return Path.home() / ".config"


def resolve_path(path: Path) -> Path:
    return path.expanduser().resolve(strict=False)


def exists_lex(path: Path) -> bool:
    return os.path.lexists(path)


def info(level: str, name: str, message: str) -> None:
    print(f"{level:<4} {name}: {message}")


def should_use_color(mode: str) -> bool:
    if os.environ.get("NO_COLOR"):
        return False
    if mode == "always":
        return True
    if mode == "never":
        return False
    return sys.stdout.isatty()


def colorize(text: str, color: str, enabled: bool) -> str:
    if not enabled:
        return text
    code = ANSI_COLORS.get(color)
    if not code:
        return text
    return f"{code}{text}{ANSI_RESET}"


def absolute_link_target(link_path: Path) -> Path:
    raw = os.readlink(link_path)
    raw_path = Path(raw)
    if raw_path.is_absolute():
        return resolve_path(raw_path)
    return resolve_path(link_path.parent / raw_path)


def make_link_target(link_path: Path, target: Path, absolute: bool) -> str:
    if absolute:
        return str(target)
    return os.path.relpath(target, start=link_path.parent)


def backup_destination(path: Path, dry_run: bool) -> Path:
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    candidate = path.with_name(f"{path.name}.bak-{ts}")
    index = 1
    while exists_lex(candidate):
        candidate = path.with_name(f"{path.name}.bak-{ts}-{index}")
        index += 1
    if dry_run:
        return candidate
    path.rename(candidate)
    return candidate


def remove_path(path: Path, dry_run: bool) -> None:
    if dry_run:
        return
    if path.is_symlink() or path.is_file():
        path.unlink()
        return
    if path.is_dir():
        shutil.rmtree(path)
        return
    if exists_lex(path):
        path.unlink()


def ensure_parent(path: Path, dry_run: bool) -> None:
    if dry_run:
        return
    path.parent.mkdir(parents=True, exist_ok=True)


def ensure_link(
    link_path: Path,
    target: Path,
    ctx: Ctx,
    name: str,
    allow_missing_target: bool = False,
    replace_existing_symlink: bool = False,
) -> bool:
    target = resolve_path(target)
    if not target.exists():
        if allow_missing_target:
            info("OK", name, f"target will be created before linking: {target}")
        else:
            info("ERR", name, f"target missing in repo: {target}")
            return False

    if exists_lex(link_path):
        if link_path.is_symlink():
            current_target = absolute_link_target(link_path)
            if current_target == target and target.exists():
                info("OK", name, "already linked")
                return True
            if replace_existing_symlink:
                info("OK", name, "replace existing symlink")
                remove_path(link_path, ctx.dry_run)
                ensure_parent(link_path, ctx.dry_run)
                link_value = make_link_target(link_path, target, ctx.absolute)
                if ctx.dry_run:
                    info("OK", name, f"would link {link_path} -> {link_value}")
                    return True
                os.symlink(link_value, link_path)
                info("OK", name, f"linked {link_path} -> {link_value}")
                return True

        if ctx.backup:
            dst = backup_destination(link_path, ctx.dry_run)
            info("OK", name, f"backup existing path to {dst}")
        elif ctx.force:
            info("OK", name, "remove existing path (--force)")
            remove_path(link_path, ctx.dry_run)
        else:
            info("WARN", name, "destination exists, use --backup or --force")
            return False

    ensure_parent(link_path, ctx.dry_run)
    link_value = make_link_target(link_path, target, ctx.absolute)
    if ctx.dry_run:
        info("OK", name, f"would link {link_path} -> {link_value}")
        return True
    os.symlink(link_value, link_path)
    info("OK", name, f"linked {link_path} -> {link_value}")
    return True


def classify_config(name: str, ctx: Ctx) -> str:
    entry = ctx.config_home / name
    expected_new = resolve_path(ctx.dotfiles_root / "config" / name)
    expected_old = resolve_path(ctx.dotfiles_root / name)

    if not exists_lex(entry):
        return "missing"
    if not entry.is_symlink():
        return "regular"

    target = absolute_link_target(entry)
    if not target.exists():
        return "symlink_broken"
    if target == expected_new:
        return "symlink_new"
    if target == expected_old:
        return "symlink_old"
    if str(target).startswith(str(resolve_path(ctx.dotfiles_root))):
        return "symlink_dotfiles_other"
    return "symlink_other"


def cmd_create(args: argparse.Namespace, ctx: Ctx) -> int:
    name = args.name
    repo_path = ctx.dotfiles_root / "config" / name
    link_path = ctx.config_home / name
    repo_will_be_created = False

    if not repo_path.exists() and exists_lex(repo_path):
        info("ERR", name, "repo path exists but is invalid")
        return 1

    if not repo_path.exists():
        repo_will_be_created = True
        if ctx.dry_run:
            info("OK", name, f"would create directory {repo_path}")
        else:
            repo_path.mkdir(parents=True, exist_ok=True)
            info("OK", name, f"created directory {repo_path}")
    else:
        info("OK", name, f"repo directory exists: {repo_path}")

    return (
        0
        if ensure_link(
            link_path,
            repo_path,
            ctx,
            name,
            allow_missing_target=(ctx.dry_run and repo_will_be_created),
        )
        else 1
    )


def cmd_link(args: argparse.Namespace, ctx: Ctx) -> int:
    name = args.name
    repo_path = ctx.dotfiles_root / "config" / name
    old_path = ctx.dotfiles_root / name
    link_path = ctx.config_home / name

    if not repo_path.exists() and old_path.exists():
        info("WARN", name, f"old layout detected at {old_path}; run migrate-layout")
        return 2
    if not repo_path.exists():
        info("ERR", name, f"repo path not found: {repo_path}")
        return 1
    return 0 if ensure_link(link_path, repo_path, ctx, name) else 1


def cmd_adopt(args: argparse.Namespace, ctx: Ctx) -> int:
    name = args.name
    link_path = ctx.config_home / name
    repo_path = ctx.dotfiles_root / "config" / name
    state = classify_config(name, ctx)

    if state == "symlink_new":
        info("OK", name, "already managed in new layout")
        return 0

    if state == "symlink_old":
        info("WARN", name, "linked to old layout; run migrate-layout")
        return 2

    if repo_path.exists() and state == "regular":
        info("WARN", name, f"repo target exists: {repo_path}; cannot adopt local path")
        return 1

    if state == "regular":
        if ctx.dry_run:
            info("OK", name, f"would move {link_path} -> {repo_path}")
            link_value = make_link_target(
                link_path, resolve_path(repo_path), ctx.absolute
            )
            info("OK", name, f"would link {link_path} -> {link_value}")
            return 0
        else:
            repo_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(link_path), str(repo_path))
            info("OK", name, f"moved {link_path} -> {repo_path}")
        return (
            0
            if ensure_link(
                link_path,
                repo_path,
                ctx,
                name,
                allow_missing_target=ctx.dry_run,
            )
            else 1
        )

    if state in {
        "missing",
        "symlink_broken",
        "symlink_other",
        "symlink_dotfiles_other",
    }:
        if repo_path.exists():
            return 0 if ensure_link(link_path, repo_path, ctx, name) else 1
        info("ERR", name, f"nothing to adopt from {link_path}")
        return 1

    info("ERR", name, f"unsupported state: {state}")
    return 1


def list_config_entries(config_home: Path) -> list[str]:
    if not config_home.exists():
        return []
    names = []
    for entry in config_home.iterdir():
        if entry.name in IGNORE_CONFIG_NAMES:
            continue
        names.append(entry.name)
    return sorted(names)


def cmd_list_unlinked(_args: argparse.Namespace, ctx: Ctx) -> int:
    names = list_config_entries(ctx.config_home)
    count = 0
    for name in names:
        state = classify_config(name, ctx)
        if state == "regular":
            info("WARN", name, "local path is not symlinked")
            count += 1
        elif state == "symlink_broken":
            info("WARN", name, "symlink is broken")
            count += 1
        elif state in {"symlink_other", "symlink_dotfiles_other"}:
            info("WARN", name, "symlink points outside managed target")
            count += 1
    if count == 0:
        print("OK   all entries are managed symlinks")
        return 0
    print(f"WARN found {count} unlinked/problematic entries")
    return 2


def cmd_doctor(_args: argparse.Namespace, ctx: Ctx) -> int:
    names = set(list_config_entries(ctx.config_home))
    repo_config = ctx.dotfiles_root / "config"
    if repo_config.exists():
        for entry in repo_config.iterdir():
            names.add(entry.name)

    color = should_use_color(ctx.color)
    buckets: dict[str, list[str]] = {
        "ok": [],
        "old_layout": [],
        "regular": [],
        "broken": [],
        "outside_managed": [],
        "missing_in_config_home": [],
    }

    for name in sorted(names):
        state = classify_config(name, ctx)
        if state == "symlink_new":
            buckets["ok"].append(name)
        elif state == "missing":
            if (ctx.dotfiles_root / "config" / name).exists():
                buckets["missing_in_config_home"].append(name)
        elif state == "regular":
            buckets["regular"].append(name)
        elif state == "symlink_old":
            target = absolute_link_target(ctx.config_home / name)
            buckets["old_layout"].append(f"{name} -> {target}")
        elif state == "symlink_broken":
            raw = os.readlink(ctx.config_home / name)
            buckets["broken"].append(f"{name} -> {raw}")
        else:
            target = absolute_link_target(ctx.config_home / name)
            buckets["outside_managed"].append(f"{name} -> {target}")

    print(colorize("Doctor report", "bold", color))
    print(f"Dotfiles root: {ctx.dotfiles_root}")
    print(f"Config home  : {ctx.config_home}")
    print("")

    print(colorize("Summary", "cyan", color))
    print(f"- {colorize('OK', 'green', color)} managed symlinks: {len(buckets['ok'])}")
    print(
        f"- {colorize('WARN', 'yellow', color)} old-layout symlinks: "
        f"{len(buckets['old_layout'])}"
    )
    print(
        f"- {colorize('WARN', 'yellow', color)} local not symlinked: "
        f"{len(buckets['regular'])}"
    )
    print(
        f"- {colorize('WARN', 'yellow', color)} broken symlinks: "
        f"{len(buckets['broken'])}"
    )
    print(
        f"- {colorize('WARN', 'yellow', color)} symlinks outside managed target: "
        f"{len(buckets['outside_managed'])}"
    )
    print(
        f"- {colorize('WARN', 'yellow', color)} repo entries missing in config home: "
        f"{len(buckets['missing_in_config_home'])}"
    )

    print("")
    print(colorize("Recommended actions", "cyan", color))
    step = 1
    if buckets["old_layout"]:
        print(f"{step}) ./scripts/dotman.py migrate-layout --dry-run")
        step += 1
        print(f"{step}) ./scripts/dotman.py migrate-layout")
        step += 1
    if buckets["regular"]:
        print(f"{step}) Adopt local configs you want to version:")
        print("   ./scripts/dotman.py adopt <name> --dry-run")
        step += 1
    if buckets["missing_in_config_home"]:
        print(f"{step}) Link repo configs that are missing locally:")
        print("   ./scripts/dotman.py link <name>")
        step += 1
    if buckets["outside_managed"] or buckets["broken"]:
        print(f"{step}) Repair links when needed:")
        print("   ./scripts/dotman.py link <name> --force")
        step += 1
    print(f"{step}) Re-run audit: ./scripts/dotman.py doctor")

    def print_section(
        title: str, items: list[str], section_color: str = "yellow"
    ) -> None:
        if not items:
            return
        print("")
        print(colorize(title, section_color, color))
        for item in items:
            print(f"- {item}")

    print_section("Old-layout symlinks", buckets["old_layout"])
    print_section("Local entries not symlinked", buckets["regular"])
    print_section("Broken symlinks", buckets["broken"])
    print_section("Symlinks outside managed target", buckets["outside_managed"])
    print_section(
        "Repo entries missing in config home", buckets["missing_in_config_home"]
    )

    has_warn = any(
        buckets[key]
        for key in (
            "old_layout",
            "regular",
            "broken",
            "outside_managed",
            "missing_in_config_home",
        )
    )
    return 2 if has_warn else 0


def infer_migrate_candidates(ctx: Ctx) -> list[str]:
    names = []
    for name in list_config_entries(ctx.config_home):
        if classify_config(name, ctx) == "symlink_old":
            names.append(name)

    for entry in ctx.dotfiles_root.iterdir():
        name = entry.name
        if name in ROOT_EXCLUDE or name.startswith("."):
            continue
        if not entry.exists() or not entry.is_dir():
            continue
        old = resolve_path(ctx.dotfiles_root / name)
        new = resolve_path(ctx.dotfiles_root / "config" / name)
        cfg = ctx.config_home / name
        if new.exists():
            continue
        if exists_lex(cfg) and cfg.is_symlink():
            try:
                if absolute_link_target(cfg) == old and name not in names:
                    names.append(name)
            except OSError:
                continue
    return sorted(set(names))


def cmd_migrate_layout(_args: argparse.Namespace, ctx: Ctx) -> int:
    candidates = infer_migrate_candidates(ctx)
    if not candidates:
        print("OK   no old-layout symlinks found")
        return 0

    warn = False
    for name in candidates:
        old_repo = ctx.dotfiles_root / name
        new_repo = ctx.dotfiles_root / "config" / name
        link_path = ctx.config_home / name

        if not old_repo.exists() and not new_repo.exists():
            info("WARN", name, "both old and new repo paths are missing")
            warn = True
            continue

        if new_repo.exists() and old_repo.exists():
            info(
                "WARN", name, "both old and new repo paths exist; manual cleanup needed"
            )
            warn = True
            continue

        if old_repo.exists() and not new_repo.exists():
            if ctx.dry_run:
                info("OK", name, f"would move {old_repo} -> {new_repo}")
            else:
                new_repo.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(old_repo), str(new_repo))
                info("OK", name, f"moved {old_repo} -> {new_repo}")

        allow_missing = ctx.dry_run and old_repo.exists() and not new_repo.exists()
        if not ensure_link(
            link_path,
            new_repo,
            ctx,
            name,
            allow_missing_target=allow_missing,
            replace_existing_symlink=True,
        ):
            warn = True

    return 2 if warn else 0


def build_parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--dotfiles-root", default=str(default_dotfiles_root()))
    common.add_argument("--config-home", default=str(default_config_home()))
    common.add_argument("--dry-run", action="store_true", help="Show actions only")
    common.add_argument(
        "--force", action="store_true", help="Replace existing destination"
    )
    common.add_argument(
        "--backup", action="store_true", help="Backup existing destination"
    )
    common.add_argument(
        "--absolute",
        action="store_true",
        help="Create absolute symlinks (default: relative)",
    )
    common.add_argument(
        "--color",
        choices=("auto", "always", "never"),
        default="auto",
        help="Color output mode (default: auto)",
    )

    parser = argparse.ArgumentParser(
        description="Manage dotfiles symlinks", parents=[common]
    )

    sub = parser.add_subparsers(dest="command", required=True)

    for command in ("adopt", "create", "link"):
        p = sub.add_parser(command, parents=[common])
        p.add_argument("name")

    sub.add_parser("list-unlinked", parents=[common])
    sub.add_parser("doctor", parents=[common])
    sub.add_parser("migrate-layout", parents=[common])
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    ctx = Ctx(
        dotfiles_root=resolve_path(Path(args.dotfiles_root)),
        config_home=resolve_path(Path(args.config_home)),
        dry_run=args.dry_run,
        force=args.force,
        backup=args.backup,
        absolute=args.absolute,
        color=args.color,
    )

    if args.command == "create":
        return cmd_create(args, ctx)
    if args.command == "link":
        return cmd_link(args, ctx)
    if args.command == "adopt":
        return cmd_adopt(args, ctx)
    if args.command == "list-unlinked":
        return cmd_list_unlinked(args, ctx)
    if args.command == "doctor":
        return cmd_doctor(args, ctx)
    if args.command == "migrate-layout":
        return cmd_migrate_layout(args, ctx)

    parser.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
