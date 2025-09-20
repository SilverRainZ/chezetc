=======
CHEZETC
=======

Extending chezmoi_ to manage files under ``/etc`` and other root-owned
directories.

For updates, please visit https://silverrainz.me/chezetc.

.. _chezmoi: https://www.chezmoi.io

Features
========

Chezetc enhances chezmoi, transforming it from a ``$HOME`` manager into a tool
that can seamlessly:

- Manage files in ``/etc`` and other directories owned by root.
- Manage multiple chezmoi repositories without manually specifying
  ``--config <PATH>``.

  .. note::

     This is particularly useful when managing files across different hosts,
     avoiding over-reliance on chezmoi's `templating`_ feature.

     .. _templating: https://chezmoi.io/user-guide/templating/

As chezetc is a wrapper around chezmoi, its usage is identical. Refer to the
Usage_ section for details.

Installation
============

Arch Linux users can install chezetc from the AUR or archlinuxcn::

   $ paru -S chezetc

For other distributions, ensure the following dependencies are installed:

- chezmoi
- sudo (must be properly configured; see `Sudo Configuration`_)
- coreutils
- bash
- gettext (provides ``envsubst``)

The following dependencies are optional but highly recommended. Without them,
you cannot customize the `Chezmoi Configuration`_:

- python >= 3.7
- python-tomli
- python-tomli-w

Then, clone the repository::

   $ git clone https://github.com/SilverRainZ/chezetc.git ~/.chezetc

Finally, add ``~/.chezetc`` to your ``$PATH``.

.. _Chezmoi Configuration: https://www.chezmoi.io/reference/configuration-file/
.. _Sudo Configuration: https://wiki.archlinux.org/title/Sudo#Configuration

Usage
=====

Quick Start
-----------

Key Differences with Chezmoi
----------------------------

Users should familiarize themselves with chezmoi before using chezetc.
Recommended starting points include the `Quick Start`_ guide and
`Chezmoi Configuration`_ documentation. However,
NOTE the following key differences:

- The chezetc CLI tool usage is identical to chezmoi; all flags are forwarded::

     $ chezetc --help
     Manage your dotfiles across multiple diverse machines, securely

     Usage:
       chezmoi [command]

     ...

  However, **DO NOT** pass flags such as ``--config``, ``--cache``, etc., to chezetc. Refer to the end of the `chezetc script`_ for a list of denied flags.
- The default configuration is read from ``~/.config/chezetc/chezetc.toml``. Only **TOML** format is supported. Avoid specifying items like ``sourceDir``, ``destDir``, etc. The full deny list is available in the `chezmoi.toml template`_.
- By default, chezetc manages ``/etc`` and stores the source files in
  ``~/.local/share/chezetc``::

     $ chezetc source-path
     ~/.local/share/chezetc
     $ chezetc target-path
     /etc

- The ``chezetc.toml`` file configures the wrapped chezmoi instance.
  Use `Environment Variables`_ to configure chezetc itself.

.. _Quick Start: https://www.chezmoi.io/quick-start/
.. _chezetc script: ./chezetc
.. _chezmoi.toml template: ./chezmoi.toml

Environment Variables
---------------------

``$ETC_SRC``
   :default: ``'~/.local/share/chezetc'``

   Overrides chezmoi's ``sourceDir`` configuration. Customize the source
   directory by setting this variable.

``$ETC_DST``
   :default: ``'/etc'``

   Overrides chezmoi's ``destDir`` configuration. Customize the target
   directory by setting this variable.

``$ETC_CFG``
   :default: ``'~/.config/chezetc/chezetc.toml'``

   Overrides chezmoi's ``--config`` flag. Customize the configuration file path by setting this variable.
``$ETC_MODE``
   :default: ``'CHEZMOI'``
   :choice: ``['CHEZMOI', 'BASH_COMPLETION', 'ZSH_COMPLETION']``

   Different modes affect the operating behavior of chezetc:

   :``CHEZMOI``: Run as chezmoi wrapper, this is the default behavior
   :``BASH_COMPLETION``: Print bash shell completion code,
                         see `Shell Completion`_ for more details
   :``ZSH_COMPLETION``: Print Z shell completion code,
                        see `Shell Completion`_ for more details

``$ETC_APP``
   :default: ``'chezetc'``

   The ID of the chezetc application.

   Set different application ID to run several chezmoi instances
   simultaneously without interfering with each other.

   See :

``$EDITOR``
   Overrides chezmoi's ``edit.command`` configuration. Customize the
   preferred editor by setting this variable.

Tips
====

Shell Completion
----------------

chezetc reuses the `Shell Completion of Chezmoi`_, so make sure your have
it properly configured first.

Bash:
   Generate completion code::

      $ mkdir -p ~/.bash_completions/
      $ ETC_MODE=BASH_COMPLETION chezetc > ~/.bash_completions/chezetc

   Source the generated file in your ``.bashrc``::

      source ~/.bash_completions/chezetc

Z shell
   Generate completion code::

      $ mkdir -p ~/.zsh/completions/
      $ ETC_MODE=ZSH_COMPLETION chezetc > ~/.zsh/completions/_chezetc

   Add the path to ``$fpath`` in your ``.zshrc``, note that the statement
   **MUST** be placed before ``compinit``::

      fpath=(~/.zsh/completions $fpath)

.. _Shell Completion of Chezmoi: https://www.chezmoi.io/reference/commands/completion/

Multi-application
-----------------

Acknowledgements
================

- Thanks to `@twpayne`_ and all chezmoi developers for creating such a powerful tool.
- Chezetc is heavily inspired by `Discussion #1510`_.

.. _@twpayne: https://github.com/twpayne
.. _Discussion #1510: https://github.com/twpayne/chezmoi/discussions/1510

License
=======

Copyright (c) 2025 `Shengyu Zhang`_

Like chezmoi, chezetc is released under the MIT license.

.. _Shengyu Zhang: https://silverrainz.me
