# AHK v2.0 auto update template

![](logo.png)

`logo.png`(modified) from https://www.pngrepo.com/ 

`icon.ico` is converted from the `logo.png`  at https://cloudconvert.com/png-to-ico with `48x48` dimension

> tested on Autohotkey 2.0-beta.3

## how it works

When publish release on Github, upload a additional `version.txt` file.

Then the script would download the file and check if there is newer version. If there is, then download it.

## Setup

### `update.ahk`
- the `update_log` would be shown once through the `msgbox` after success update

### `meta.ahk`
- set `version`
- set `ahkFilename` to your script name, it would compile `%ahkFilename%.ahk` to `%binaryFilename%.exe`
- set `downloadUrl` to your github release URL

### `distribution.ahk`
> The **requirements** of using the `distribution.ahk` is:  
  ~~; # ahk2exe.exe in PATH [1.1.34.00_Beta_8]~~  
  ~~; # AutoHotkey64.exe in PATH [v2.0-beta.3]~~  
  ~~; # mpress in ahk2exe path~~  

Since these binaries have been added to the project, there is no longer any need to reference external binaries.

### `icon.ico`
- put your icon in the same directory.

### notice
version is compared by `(\d+)\.(\d+)\.(\d+)`

## Usage
1. Run `distribution.ahk`, is will compile your script into binary, and then compress it into zip. At the same time, it will genarate the `version.txt`. And then, this two file would be moved into `dist` directory.
2. Upload the two files in the `dist` directory to your release.
3. Everything would work.

## Template Usage

Click [Use this template](https://github.com/Nigh/ahk-autoupdate-template/generate)

