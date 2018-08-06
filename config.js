module.exports = {
  brew: [
    // http://conqueringthecommandline.com/book/ack_ag
    'ag',
    // Install GNU core utilities (those that come with macOS are outdated)
    // Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
    'coreutils',
    'dos2unix',
    // Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
    'findutils',
    'fortune',
    'readline', // ensure gawk gets good readline
    'gawk',
    // Install GNU `sed`, overwriting the built-in `sed`
    // so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
    'gnu-sed --with-default-names',
    // better, more recent grep
    'homebrew/dupes/grep',
    // https://github.com/jkbrzt/httpie
    'httpie',
    // jq is a sort of JSON grep
    'jq',
    // Install some other useful utilities like `sponge`
    'moreutils',
    'nmap',
    'openconnect',
    'reattach-to-user-namespace',
    // better/more recent version of screen
    'homebrew/dupes/screen',
    'postgres',
    'python3',
    'tmux',
    'tree',
    'ttyrec',
    // better, more recent vim
    'vim --with-override-system-vi',
    'watch',
    // Install wget with IRI support
    'wget --enable-iri'
  ],
  cask: [
    'gpgtools',
    'ireadfast',
    'iterm2',
    //'little-snitch',
    'micro-snitch',
    //'macvim',
    'slack',
    'the-unarchiver',
    //'torbrowser',
    'transmission',
    'vlc',
  ],
  gem: [
    'git-up'
  ],
  npm: [
    // 'eslint',
    // 'instant-markdown-d',
    // 'generator-dockerize',
    'gulp',
    'npm-check',
    'prettyjson',
    'trash',
    'webpack',
    'vtop'
    // ,'yo'
  ]
};
