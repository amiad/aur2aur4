# aur2aur4
Import packages from aur3 to aur4 by packages list or aur user

## Usage
`./aur2aur4.sh -a [-o <outdir>]` - get list of empty reps from aur4 and import them automatically.

OR

`./aur2aur4.sh -l "pack1 pack2 pack3" [-f] [-o <outdir>]` - import by packages list.

OR

`./aur2aur4.sh -u username [-f] [-o <outdir>]` - import by AUR username.

`-f` - force override aur4 exists package

`-o <outdir>` - download packages into outdir

## Dependencies

* git
* pkgbuild-introspection
* wget
