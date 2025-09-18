#!/usr/bin/env python3

import sys
from os import path
import tomli
import tomli_w


def load(fn):
    if path.isfile(fn):
        with open(fn, 'rb') as f:
            return tomli.load(f)
    else:
        return {}

a = load(sys.argv[1])
b = load(sys.argv[2])
c = a | b

with open(sys.argv[3], 'wb') as f:
    tomli_w.dump(c, f)
