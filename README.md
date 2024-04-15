# Mojo syntax highlighting and indentation for VIM

This provides basic Mojo syntax highlighting for VIM. It's almost identical to
Python modulo several additions of Mojo-specific keywords. The additions are
marked with "Mojo addition" in the config files for convenience.

## How to setup Mojo syntax highlighting

1. Add Mojo config files to your VIM config:

    ```bash
    for FOLDER in autoload ftdetect ftplugin indent syntax; do mkdir -p ~/.vim/$FOLDER && ln -s $FOLDER/mojo.vim ~/.vim/$FOLDER/mojo.vim; done
    ```

2. Enjoy
