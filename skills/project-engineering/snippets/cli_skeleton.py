import argparse
import json
import logging
import sys


LOGGER = logging.getLogger(__name__)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable diagnostic logging to stderr.",
    )

    subcommands = parser.add_subparsers(dest="command", required=True)

    solve = subcommands.add_parser("solve")
    solve.add_argument("--seed", type=int, default=0)
    solve.add_argument("--dtype", type=str, default="float32")
    solve.set_defaults(func=run_solve)

    check = subcommands.add_parser("check")
    check.set_defaults(func=run_check)
    return parser


def configure_logging(verbose: bool) -> None:
    level = logging.INFO if verbose else logging.WARNING
    logging.basicConfig(level=level, format="%(levelname)s %(name)s: %(message)s")


def run_solve(args: argparse.Namespace) -> int:
    # Boundary validation happens in CLI handlers, before entering numerics code.
    if args.seed < 0:
        raise ValueError("--seed must be >= 0")
    payload = {"seed": args.seed, "dtype": args.dtype}
    sys.stdout.write(json.dumps(payload) + "\n")
    return 0


def run_check(args: argparse.Namespace) -> int:
    LOGGER.info("running checks")
    _ = args
    return 0


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    configure_logging(args.verbose)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
