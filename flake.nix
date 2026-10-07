{
  description = "Rabbit presentation tool runtime";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    # 動作確認済みのプラットフォームのみ
    flake-utils.lib.eachSystem [ "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        # macOS の glib.pc は sysprof-capture-4 を参照するが、sysprof は Linux 専用
        sysprofCaptureStub = pkgs.writeTextDir "lib/pkgconfig/sysprof-capture-4.pc" ''
          Name: sysprof-capture-4
          Description: stub
          Version: 0
        '';
        typelibPackages = with pkgs; [
          glib
          gobject-introspection
          gdk-pixbuf
          pango
          harfbuzz
          at-spi2-core
          graphene
          gtk3
          gtk4
          poppler_gi
          librsvg
        ];
        fontsConf = pkgs.makeFontsConf {
          fontDirectories = [
            pkgs.noto-fonts-cjk-sans
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            "/System/Library/Fonts"
            "/Library/Fonts"
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages =
            with pkgs;
            [
              ruby_3_3
              pkg-config
              cairo
              # Ruby の pkg-config gem は Requires.private まで解決するため必要
              libepoxy
              dav1d
              libthai
              libdatrie
            ]
            ++ typelibPackages
            ++ lib.optional stdenv.hostPlatform.isDarwin sysprofCaptureStub;

          GI_TYPELIB_PATH = lib.makeSearchPath "lib/girepository-1.0" (map lib.getLib typelibPackages);
          FONTCONFIG_FILE = fontsConf;

          shellHook = ''
            export GEM_HOME="$PWD/.gem"
            export GEM_PATH="$GEM_HOME"
            export PATH="$GEM_HOME/bin:$PATH"
            command -v rabbit >/dev/null || gem install rabbit --no-document
          '';
        };
      }
    );
}
