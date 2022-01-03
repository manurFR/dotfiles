# add "export PYTHONSTARTUP=~/.startup.py" in .bashrc
# make a "python -m pip install rich" to enable rich features

print("(.startup.py)")

import collections, datetime, itertools, math, os, pprint, re, sys, time
print("(imported collections, datetime, itertools, math, os, pprint as pp, re, sys, time)")

try:
    from rich import print
    from rich import pretty
    pretty.install()
    from rich import inspect
    from rich.pretty import pprint as pp
    print("(imported rich print, pprint and inspect)")
except ImportError:
    from pprint import pprint as pp
