#!/bin/bash

PKGNAME=${PKGNAME:-chezetc}
SRCDIR=${SRCDIR:-.}
DESTDIR=${DESTDIR:-}
PREFIX=${PREFIX:-/usr}

BINDIR="$DESTDIR$PREFIX/bin/"
LIBDIR="$DESTDIR$PREFIX/lib/$PKGNAME"

# Install shim script.
install -Dm775 <(echo '') "$BINDIR/$PKGNAME"
cat <<EOF >> "$BINDIR/$PKGNAME"
#!/bin/bash
exec $PREFIX/lib/chezetc/chezetc "$@"
EOF

# Install the real script.
install -Dm775 "$SRCDIR/chezetc" "$LIBDIR/$PKGNAME"

# Install other files which need +x premission.
EXEC_FILES=(
    commands/cd
    commands/editor
    utils/toml-merge.py
    hooks/post-add-chown.sh
)
for i in ${EXEC_FILES[@]}; do
    install -Dm775 $SRCDIR/$i "$LIBDIR/$i"
done

# Install other files which do not need +x premission.
NON_EXEC_FILES=(
    README.rst
    chezmoi.toml
    utils/completion.sh
    completions/chezetc.zsh
    completions/chezetc.sh
)
for i in ${NON_EXEC_FILES[@]}; do
    install -Dm644 $SRCDIR/$i "$LIBDIR/$i"
done

install -Dm644 $SRCDIR/LICENSE "$DESTDIR$PREFIX/share/licenses/$PKGNAME/LICENSE"
