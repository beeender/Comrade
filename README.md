# Comrade

[![Build Status](https://travis-ci.com/beeender/Comrade.svg?token=Jk7Uqc68DwnrEsRwJDp7&branch=master)](https://travis-ci.com/beeender/Comrade)
Brings JetBrains/IntelliJ IDEs magic to Neovim with minimal setup.

The whole idea behind this is creating a neovim client as an IntelliJ/JetBrains IDE plugin,
maintaining bi-directly synchronization of editing buffers between IDE and neovim, then
request the IDE for the code assistant information from neovim.

[ComradeNeovim](https://github.com/beeender/ComradeNeovim) is required to be installed in the
IDE to make this work.

- [Install](#install)
- [Usage](#usage)
- [Mapped Keys](#mapped-keys)
- [Supported IDEs](#supported-ides)
- [Supported Languages](#supported-languages)
- [Screenshots](#Screenshots)

# Install

**Note: Comrade requires Neovim (0.3.2+) with Python3.6.1+enabled.**
**Note: JetBrains IDEs (2018.3+) is required.**

- Search for `ComradeNeovim` in the IntelliJ plugin market and install it.
- Install [deoplete](https://github.com/Shougo/deoplete.nvim) for code completion.
```vim
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
```
- Install this plugin.
For vim-plug
```
Plug 'beeender/Comrade'
```

# Usage

1. Keep the project opened in the JetBrains IDE which contains the source file you want to
   edit in neovim.
2. Start using neovim to edit any files belong to that project.

By default, the IDE side plugin will automatically connect to any running neovim instance
it discovered and monitoring the current editing buffer. If it can find a neovim buffer
which is associated to any files in the project, the IDE plugin will connect to neovim and
start all the Comrade functionalities to that buffer.

When IDE and neovim get connected, the both editing activities will be synced to each other.
You would be able to see changes made in one window (either IDE or neovim) appears in the
other in a short time.

Also, the file write action (`:w`) will be taken over by the IDE to avoid content conflicts.

## Completion

If the [deoplete](https://github.com/Shougo/deoplete.nvim) is installed and enabled, the
completion should work out of box. It should support any types of languages which the IDE
supports.

## Linting

Comrade should be able to do linting on the fly just like what JetBrains IDE
is doing. You don't have to save the file to get the linting result. The linting
refresh will be triggered automatically whenever there is a change in the file
buffer.

The linting items are controlled by the IDE's inspection settings. Changing
inspection settings in the IDE side will result linting change in the neovim
side accordingly.

## Fixer

When a coding problem has been detected, Comrade can call into the
IDE's quick fix system to make a quick fix of it. To use this, just move the
cursor to the problem position and call `ComradeFix` command or use default
key binding `<LEADER><LEADER>f`.

IDE itself has a very large amount of quick fixes. Some of them require
user's interactions in the IDE. It is quite difficult to support all of them.
Although Comrade restricts the fixers in a small but most important range,
there still could be some issues with fixers like the neovim lost the focus.
Please see [this issue](https://github.com/beeender/Comrade/issues/1).


# Mapped Keys

- Quick fix at the current cursor

```
<LEADER><LEADER>f
```

To change the key map:

```
let g:comrade_key_fix = <your_mapped_keys>
```

# Supported IDEs

In theory, this plugin should support all JetBrains IDEs after version `2018.3`. Since not
all of them are free, only part of them have been verified by us.
Please let us know or send a PR to change the IDE support status below:

| IDE | Status | Remarks |
| --- |:------:| -------:|
| Android Studio | verified | |
| AppCode | unknown | |
| CLion | unknown | |
| GoLand | unknown | |
| IDEA | verified | |
| PhpStorm | unknown | |
| PyCharm | verified | |
| Rider| unknown | |
| RubyMine | unknown | |
| WebStorm | unknown | |


# Supported Languages

Same as the IDE support, this plugin should support all languages which your JetBrains IDE
support.
**This could also support files like xml layout in the Android project if the IDE supports it.**
Please let us know or send a PR to change the language support status below:

| Language | Status | Remarks |
| -------- |:------:| -------:|
| C | unknown | |
| C# | unknown | |
| C++ | unknown | |
| Dart | verified | with [IntelliJ Dart Plugin](https://plugins.jetbrains.com/plugin/6351-dart) |
| Java | verified | |
| Kotlin | verified | |
| ObjC | unknown | |
| PHP | unknown | |
| Python | verified | |
| Rust | verified | with [IntelliJ Rust](https://intellij-rust.github.io/) |
| Swift | unknown | |
| Go | unknown | |
| Ruby | unknown | |


## SCREENSHOTS

 ![Flutter in Android Studio](https://github.com/beeender/ComradeNeovim/blob/master/screenshot/android_studio_flutter.gif)

