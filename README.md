# Unix Utils

## Introduction

Are you dealing with an old and underpowered *nix system? Do you miss basic tools like `file` but can't compile them yourself? Then you've come to the right place! This repository contains a collection of utilities that can help you investigate old and obscure hardware. The utilities are written in sh (not bash) and make very few assumptions about what is available on the system.

## Usage

To use these utilities, you'll need to get them onto your system. Here are a few suggestions:

- Remove the storage from your target system, mount it on a more modern system, and copy the utilities over.
- Gain root access to the target system and use onboard utilities to upload or download the files.
- If the system lacks SSL support, you can use frogfind.com as an HTTPS to HTTP proxy. For example, you can download `file.sh` like this:
  wget https://frogfind.com/read.php?a=https://raw.githubusercontent.com/wulfderay/unix_utils/main/file.sh
  You'll need to remove the minimal HTML from either end of the file with `vi` or another editor.

## Contents

This repository contains the following utilities:

- `file.sh`: a script that determines the type of a file based on its contents, rather than relying on the file extension. This can be useful when dealing with files that have been mislabeled or modified in some way.
- `elfiinfo.sh`: a script prints information about elf executables. ***currently broken ***
- Other utilities to be added in the future.

## Thanks

Thanks to Action Retro for writing frogfind! If you have a retro computer that has no business on the modern web, head over to http://frogfind.com right away! 

## Contribution

Contributions are welcome! If you have a utility that you think would be helpful for investigating old and obscure hardware, please submit a pull request.

## License

These utilities are released under the MIT License. See the `LICENSE` file for details.
