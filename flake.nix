{
  description = "ippl";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs =
    { self
    , flake-utils
    , nixpkgs
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "ippl";
        version = "main";
        doCheck = true;

        src = ./.;

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];

        buildInputs = with pkgs; [
          kokkos
          mpi
        ];

        configurePhase = ''
          cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_STANDARD=20 -DIPPL_ENABLE_TESTS=True -DKokkos_VERSION=4.2.00 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
        '';

        buildPhase = ''
          cmake --build build --parallel
        '';

        installPhase = ''
          cmake --install build --prefix $out
          cp build/compile_commands.json $out/
        '';

        checkPhase = ''
          ctest --test-dir build --output-on-failure
        '';
      };

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          # clangd
          cmake
          kokkos
          mpi
          pkg-config
          (pkgs.writeShellScriptBin "build" ''
            #!${pkgs.zsh}/bin/zsh
            set -eu -o pipefail
            nix build
            ln -sf result/compile_commands.json .
          '')
        ];

        shellHook = ''
        '';
      };
    });
}
