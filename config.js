module.exports = {
  brew: [
    'svn', // For Abstract PDF Export
    'autojump', // For Abstract PDF export
    'ag', // http://conqueringthecommandline.com/book/ack_ag
    'cairo', // For Abstract PDF export
    'coreutils', // Install GNU core utilities (those that come with macOS are outdated)
    'elasticsearch',
    'elixir',
    'erlang',
    'findutils', // Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
    'readline', // ensure gawk gets good readline
    'gawk',

    // Install GNU `sed`, overwriting the built-in `sed`
    // so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
    'gnu-sed',

    'homebrew/core/grep', // better, more recent grep
    'httpie', // https://github.com/jkbrzt/httpie
    'jq', // jq is a sort of JSON grep
    'moreutils', // Install some other useful utilities like `sponge`
    'neovim',
    'nmap',
    'openconnect',
    'reattach-to-user-namespace',
    'homebrew/core/screen', // better/more recent version of screen
    'pango', // For Abstract PDF Export
    'postgresql',
    'python@3.7',
    'tmux',
    'tree',
    'ttyrec',
    'vim', // better, more recent vim
    'watch',
    'wget',
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
  npm: [
    'eslint',
    'elm',
    'elm-test',
    'elm-oracle',
    'elm-format',
    'firebase-tools',
    'npm-check',
    'trash',
    'vtop'
  ]
};
