{
	description = "Attempts at learning RISC-V assembly";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
		pkgs = import nixpkgs { inherit system; };
	in {
		devShell = let
			riscv-pkgs = import <nixpkgs> {
				crossSystem = (import <nixpkgs/lib>).systems.examples.riscv32;
			};
		in riscv-pkgs.mkShell {
			depsBuildBuild = [
				riscv-pkgs.coreutils
				pkgs.qemu
			];
		};
	});
}
