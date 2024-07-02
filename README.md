# RISC-V Assembly Examples

Requires the RISC-V toolchain and QEMU. This repo has a Nix flake for these dependencies:

```bash
nix develop --impure
./run.sh hello_world.S
```

All other arguments to `run.sh` will be passed to QEMU meaning you can do something like `./run.sh hello_world.S -d cpu,in_asm,strace` for debugging.
