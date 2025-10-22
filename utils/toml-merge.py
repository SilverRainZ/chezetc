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


def merge(src, dst):
    """Recursively merge two dicts instead of using ``d1 | d2``"""
    for key, value in src.items():
        if isinstance(value, dict):
            # get node or create one
            node = dst.setdefault(key, {})
            merge(value, node)
        else:
            dst[key] = value

    return dst

a = load(sys.argv[1])
b = load(sys.argv[2])
merge(a, b)
print(tomli_w.dumps(b))
