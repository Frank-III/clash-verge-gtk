{
  description = "Clash Verge with SolidJS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rust = (pkgs.rust-bin.nightly.latest.default.override {
          extensions = [ 
            "cargo"
            "clippy"
            "rust-src"
            "rust-analyzer"
            "rustc"
            "rustfmt"
          ];
        });
      shellInputs = with pkgs; [
        rust
        nodejs
        # rust-analyzer-unwrapped
      ];
      in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = shellInputs;

          RUST_SRC_PATH="${rust}/lib/rustlib/src/rust/library";

          shellHook = ''
            ln -fsT ${rust} ./.direnv/rust
          '';
        };
      }
    );
}