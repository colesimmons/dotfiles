module.exports = {
  brew: [
    'ag', // http://conqueringthecommandline.com/book/ack_ag
    // Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
    'coreutils', // Install GNU core utilities (those that come with macOS are outdated)
    'dos2unix',
    'elasticsearch',
    'elixir',
    'erlang',
    'findutils', // Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
    'readline', // ensure gawk gets good readline
    'gawk',

    // Install GNU `sed`, overwriting the built-in `sed`
    // so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
    'gnu-sed --with-default-names',

    'homebrew/dupes/grep', // better, more recent grep
    'httpie', // https://github.com/jkbrzt/httpie
    'jq', // jq is a sort of JSON grep
    'moreutils', // Install some other useful utilities like `sponge`
    'neovim',
    'nmap',
    'openconnect',
    'reattach-to-user-namespace',
    // better/more recent version of screen
    'homebrew/dupes/screen',
    'postgresql',
    'python3',
    'tmux',
    'tree',
    'ttyrec',
    'vim --with-override-system-vi', // better, more recent vim
    'watch',
    'wget --enable-iri', // Install wget with IRI support
    'yarn',
    'openssl',
    'sqlite3',
    'xz',
    'zlib'
  ],
  cask: [
    'anki',
    'dashlane',
    'docker',
    'firefox-developer-edition',
    'flux',
    'google-chrome',
    'google-cloud-sdk',
    'homebrew/cask-versions/adoptopenjdk8',
    'ireadfast',
    'iterm2',
    'mullvadvpn',
    'postman',
    'sketch',
    'slack',
    'spotify',
    'tableplus',
    'telegram',
    'the-unarchiver',
    'vlc',
    'zoom'
  ],
  gem: [],
  npm: [
    'eslint',
    'elm',
    'elm-test',
    'elm-oracle',
    'elm-format',
    'npm-check',
    'trash',
    'vtop'
  ]
};
