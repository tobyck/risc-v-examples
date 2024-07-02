OUT_DIR=./out

# without file extension
FILENAME="${1%.*}"

# create object file from assembly
riscv32-unknown-linux-gnu-as $1 -o $OUT_DIR/${FILENAME}.o

# compile object file into a binary
riscv32-unknown-linux-gnu-gcc $OUT_DIR/${FILENAME}.o -o $OUT_DIR/${FILENAME} -nostdlib -static

# emulate with qemu
qemu-riscv32 ${@:2} $OUT_DIR/${FILENAME}
