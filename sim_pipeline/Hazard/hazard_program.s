    .globl _start
_start:

# ---------- Data Hazard (EX-EX forwarding) ----------
    addi x1, x0, 10       # x1 = 10
    addi x2, x0, 5        # x2 = 5
    add  x3, x1, x2       # x3 = x1 + x2 = 15
    sub  x4, x3, x2       # x4 = x3 - x2 = 10 (forwarding from EX stage)

# ---------- Load-Use Hazard (may require stall if no forwarding) ----------
    lw   x5, 0(x1)        # x5 = Mem[x1] (load)
    add  x6, x5, x2       # x6 = x5 + x2 (depends on load result)
    addi x7, x6, 1        # further dependent instruction

# ---------- Control Hazard: Branch taken ----------
    addi x8, x0, 0        # x8 = 0
    addi x9, x0, 1        # x9 = 1
    beq  x8, x9, skip1    # branch not taken, no flush
    addi x10, x0, 123     # should execute

skip1:
    addi x10, x0, 456     # correct result after branch

# ---------- Control Hazard: Branch taken and flush ----------
    addi x11, x0, 2
    addi x12, x0, 2
    beq  x11, x12, skip2  # branch taken -> flush next instruction
    addi x13, x0, 999     # this should be flushed
skip2:
    addi x13, x0, 888     # correct value after flush

# ---------- Forwarding from MEM stage ----------
    addi x14, x0, 3
    addi x15, x0, 4
    add  x16, x14, x15    # x16 = 7
    add  x17, x16, x15    # x17 = 7 + 4 = 11 (forward from MEM)

# ---------- End: Infinite loop ----------
end:
    j end
