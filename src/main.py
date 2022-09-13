import argparse
import logging
from pathlib import Path

from formula import Context, Formula

logger = logging.getLogger(__name__)


def load_file(filename: Path) -> list[type[Formula]]:
    code = compile(filename.read_text(), filename=filename, mode="exec")
    scope = {"__name__": str(filename)}
    exec(code, scope, scope)
    formula_types = []
    for value in scope.values():
        if isinstance(value, type) and issubclass(value, Formula) and value.__module__ == scope["__name__"]:
            formula_types.append(value)
    if not formula_types:
        raise RuntimeError(f'could not find any formula types in "{filename}"')
    return formula_types


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("formula_file", type=Path)
    parser.add_argument("-o", "--override", metavar="KEY=VALUE", action="append")
    parser.add_argument("-d", "--dry-run", action="store_true")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(message)s")

    options = {}
    for item in args.override or ():
        key, sep, value = item.partition("=")
        if not sep:
            parser.error(f"invalid --override option value: {item!r}")
        if "." in key:
            parser.error(f"invalid key name: {key!r}")
        options[key] = value

    context = Context()
    formulae = [x(context) for x in load_file(args.formula_file)]

    context.vars.update(options)
    for formula in formulae:
        for key, value in options.items():
            if hasattr(formula, key):
                logger.info("override %s.%s = %r", type(formula).__name__, key, value)
                setattr(formula, key, value)

    if args.dry_run:
        return

    for formula in formulae:
        formula.install()
        formula.finalize()


if __name__ == "__main__":
    main()
