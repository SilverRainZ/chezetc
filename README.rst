=======
chezetc
=======

Extending chezmoi_ to manage files under ``/etc``.

Please check out https:/silverrainz.me/chezetc for updates.

.. _chezmoi: https://www.chezmoi.io

Features
========

Chezetc is a wrapper for chezmoi that makes it more than just a ``$HOME`` manager,
allowing chezmoi to seamlessly:

- Manage files in ``/etc`` and any other root-owned directories
- Manage multiple chezmoi repositories without specifiing ``--config <PATH>``
  manaully

  .. note::

     This is quite useful when you have file to manage on different host,
     and you don't want to heaviely use the `template`_  of chezmoi.

     .. _template: https://chezmoi.io/user-guide/templating/

As chezetc is a chezmoi wrapper, The Usage_ of chezetc is exactly the same as
chezmoi.

Installion
==========

Arch Linux users can install chezetc from AUR or archlinuxcn::

   $ paru -S chezetc

For other users, make sure you have the following dependencies installed:

- chzemoi
- sudo (MUST be properly configured, see also `Sudo Configuration`_)
- coreutils
- bash
- gettext (providing ``envsubst``)

The following dependencies are optional but highly recommanded, without them you
CAN NOT customize the `Chzemoi Configuration`_.

- python >= 3.7
- python-tomli
- python-tomli-w

Then, clone the repository::

   $ git clone https://github.com/SilverRainZ/chezetc.git ~/.chezetc

Finally, add `~/.chezetc`` to your ``$PATH``.

.. _Chzemoi Configuration: https://www.chezmoi.io/reference/configuration-file/
.. _Sudo Configuration: https://wiki.archlinux.org/title/Sudo#Configuration

Usage
=====

Users should first learn to use chezmoi before using chezetc.
You can start by reading Chzemoi's documentation like `Quick Start`_ and
`Configuration File`_, but there are some key differences to note:

- Usage of chezetc CLI tool is exactly the same as chezmoi,
  flags passed to chezetc will be forwarded to chezmoi::

     $ chezetc --help
     Manage your dotfiles across multiple diverse machines, securely

     Usage:
       chezmoi [command]

     ...

  But user **MUST NOT** pass flags ``--config``, ``--cache`` and etc. to chezetc,
  refer to end of `chezetc script`_ for a deny flag list
- The default configuration will be read from
  ``~/.config/chezetc/chezetc.toml``, only **TOML** format is supported.
  Please **DON'T** specifing item like ``sourceDir``, ``destDir`` and etc.
  The full deny list is mentioned in `chezmoi.toml template`_,
- By default, chezetc manage ``/etc`` and store source path under
  ``~/.local/share/chezetc``::

     $ chezetc source-path
     ~/.local/share/chezetc
     $ chezetc target-path
     /etc

- ``chezetc.toml`` only configurre the wrapped chezmoi, use
  `Enviroment Variables` to configurate chezetc itself

.. _Quick Start: https://www.chezmoi.io/quick-start/
.. _Configuration File: https://www.chezmoi.io/reference/configuration-file/
.. _chezetc script: ./chezetc
.. _chezmoi.toml template: ./chezmoi.toml

By default, chezetc manage ``/etc`` and store source st::

   $ chezetc source-path
   ~/etcfiles
   $ chezetc target-path
   /etc

Enviroment Variables
--------------------

``$ETC_APP``
   :default: ``chezetc``

``$ETC_SRC``
   :default: ``~/.local/share/chezetc``

   As chezmoi configuration item ``sourceDir`` is hooked, user can customize
   source path by setting this env var.
``$ETC_DST``
   :default: ``/etc``

   As chezmoi configuration item ``destDir`` is hooked, user can customize
   managed directory (A.K.A. target path) by setting this env var.
``$ETC_CFG``
   :default: ``~/.config/chezetc/chezetc.toml``

   As chezmoi flag ``--config`` is hooked, user can customize
   path of configuration file by setting this env var.
``$EDITOR``
   As chezmoi configuration item ``[edit.command]`` is hooked, user can customize
   prefered editor by this env var.


Multi source path
-----------------

TODO

Shell Completion
----------------

TODO

Acknowledgements
================

- Thanks to `@twpayne`_ and all the chezmoi developers for creating such a great tool
- chezetc is highly insprtion from the `Discussion #1510`_

.. _@twpayne: https://github.com/twpayne
.. _Discussion #1510: https://github.com/twpayne/chezmoi/discussions/1510

License
=======

Copyright (c) 2025 `Shengyu Zhang`_

Same as chezmoi, chezetc is released under the MIT license.

.. _Shengyu Zhang: https://silverrainz.me
