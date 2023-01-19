# nvim-classy
nvim-classy hides your HTML `class` attributes so your code goes from looking
like this:
```html
<div class="centered flex popout bring-to-front hover-effect">
  <p class="whitespace main-paragraph">Text</p>
</div>
```
to this:
```html
<div class=".">
  <p class=".">Text</p>
</div>
```
Of course, when you put your cursor on one of lines, the `"."`s will expand
into their normal form.

Multiple filetypes are supported and its incredibly easy to configure your own!

This plugin was heavily inspired by the VSCode plugin,
[Inline Fold](https://github.com/moalamri/vscode-inline-fold).

## Installation
Install with your favorite package manager!

For example, with [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
  'dzfrias/nvim-classy',
  requires = 'nvim-treesitter/nvim-treesitter',
}
```
This plugin has out-of-the-box configuration, so just install it and it should
work!

### Treesitter
It will not work without
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and the 
appropriate grammar must be installed.

For example, to use it with HTML, make sure treesitter is installed and run
`:TSInstall html`.

## Commands
nvim-classy has two main commands:
- `:ClassyConceal`
- `:ClassyUnconceal`
- `:ClassyToggleConceal`

These commands allow for fine-grained control over the plugin.

### ClassyConceal
ClassyConceal turns on concealing for the current file. It is updated every
time the buffer is modified. This is run automatically by classy if the
`auto_start` option is set to `true` (the default).

### ClassyUnconceal
This command wipes every conceal set by nvim-classy from the buffer.

### ClassyToggleConceal
Toggles concealing for the individual class under the cursor.

## Configuration
The behavior of nvim-classy can be fully customized.

Run `require("classy").setup { <OPTIONS> }` to get access to the configuration.

Here are the available options and their default values:
```lua
{
  conceal_char = ".",
  conceal_hl_group = "",
  min_length = 0,
  auto_start = true,
  filetypes = {
    html = [[ ((attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value (attribute_value) @attr_value)) ]],
    javascript = [[
      ;; jsx
      ((property_identifier) @attr_name (#eq? @attr_name "class") [(jsx_expression (_)?) (string)] @attr_value) ]],
    svelte = [[ ((attribute_name) @attr_name (#eq? @attr_name "class") (quoted_attribute_value (attribute_value) @attr_value)) ]],
  },
}
```
**conceal_char**:
The character to conceal the classes. Note that this can only be a single
character due to the limitations of nvim, so setting it to a string will use
the first character.

**conceal_hl_group**:
The highlight group of the conceal character. Set it to `string` if you'd like
the `conceal_char` to be the same color as the expanded classes.

**min_length**:
The minimum length that the class must be in order to be concealed.

**auto_start**:
If `true`, runs `:ClassyConceal` when you start editing the file.

**filetypes**:
Contains queries of the filetypes that classy supports. To write your own, make
sure to include an `@attr_value` capture so classy knows what to conceal!
Make sure to read about writing treesitter queries!

On a side note, if you'd like to contribute, it would be nice to have more
filetypes supported.

## License
This plugin is licensed under the MIT license.
